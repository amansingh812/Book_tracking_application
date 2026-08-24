import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:readora/core/error/error_mapper.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

/// Offline-first library.
///
/// The pattern every repository in Readora follows:
///   1. write to Isar
///   2. enqueue the change on the outbox
///   3. return — never await the network
///   4. nudge the sync engine (fire and forget)
class LibraryRepositoryImpl implements LibraryRepository {
  LibraryRepositoryImpl({
    required Isar isar,
    required Outbox outbox,
    required SyncEngine syncEngine,
    required SupabaseClient supabase,
    required AuthRepository auth,
  })  : _isar = isar,
        _outbox = outbox,
        _sync = syncEngine,
        _supabase = supabase,
        _auth = auth;

  static const _uuid = Uuid();

  final Isar _isar;
  final Outbox _outbox;
  final SyncEngine _sync;
  final SupabaseClient _supabase;
  final AuthRepository _auth;

  /// Guests are anonymous Supabase users, so there is always a real uid here
  /// once the app is past the auth gate. The fallback only exists so a stray
  /// call during sign-out cannot throw — it should never match any row.
  String get _userId => _auth.current?.id ?? '__no_session__';

  // -------------------------------------------------------------------------
  // Reads — always local
  // -------------------------------------------------------------------------
  @override
  Stream<List<LibraryBook>> watchLibrary({ReadingStatus? status}) {
    final query = status == null
        ? _isar.userBookEntitys.filter().userIdEqualTo(_userId)
        : _isar.userBookEntitys.filter().userIdEqualTo(_userId).statusEqualTo(status);

    return query
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .asyncMap(_join);
  }

  @override
  Stream<List<LibraryBook>> watchCurrentlyReading() =>
      watchLibrary(status: ReadingStatus.reading);

  Future<List<LibraryBook>> _join(List<UserBookEntity> rows) async {
    if (rows.isEmpty) return const [];
    final books = await _isar.bookEntitys
        .getAllByUuid(rows.map((r) => r.bookUuid).toList());
    final byUuid = {for (final b in books.whereType<BookEntity>()) b.uuid: b};
    return rows.map((r) => LibraryBook.from(r, byUuid[r.bookUuid])).toList();
  }

  // -------------------------------------------------------------------------
  // Catalogue search — the one online call in this repository
  // -------------------------------------------------------------------------
  @override
  Future<List<BookEntity>> searchCatalogue({String? query, String? isbn}) {
    return guard(() async {
      final response = await _supabase.functions.invoke(
        'book-search',
        body: {if (query != null) 'q': query, if (isbn != null) 'isbn': isbn},
      );
      final rows = ((response.data as Map)['books'] as List).cast<Map<String, dynamic>>();
      final entities = rows.map(BookEntity.fromJson).toList();

      // Cache locally so the same search works offline next time.
      await _isar.writeTxn(() => _isar.bookEntitys.putAllByUuid(entities));
      return entities;
    });
  }

  // -------------------------------------------------------------------------
  // Writes — local first, queued for upload
  // -------------------------------------------------------------------------
  @override
  Future<LibraryBook> addToLibrary(
    BookEntity book, {
    ReadingStatus status = ReadingStatus.wantToRead,
  }) async {
    final existing = await _isar.userBookEntitys
        .filter()
        .userIdEqualTo(_userId)
        .bookUuidEqualTo(book.uuid)
        .findFirst();
    if (existing != null) return LibraryBook.from(existing, book);

    final entity = UserBookEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..bookUuid = book.uuid
      ..status = status
      ..startedAt = status == ReadingStatus.reading ? DateTime.now().toUtc() : null
      ..createdAt = DateTime.now().toUtc();

    await _isar.writeTxn(() async {
      await _isar.bookEntitys.putByUuid(book);
      await _isar.userBookEntitys.putByUuid(entity);
    });

    await _enqueue(entity.uuid, OutboxOp.insert, entity.toInsertJson());
    return LibraryBook.from(entity, book);
  }

  @override
  Future<void> updateProgress(String userBookId, int page) async {
    await _patch(userBookId, (e) {
      e
        ..currentPage = page < 0 ? 0 : page
        ..status = e.status == ReadingStatus.wantToRead && page > 0
            ? ReadingStatus.reading
            : e.status
        ..startedAt ??= page > 0 ? DateTime.now().toUtc() : null;
    }, (e) => {
          'current_page': e.currentPage,
          'status': e.status.wire,
          'started_at': e.startedAt?.toIso8601String(),
        });
  }

  @override
  Future<void> setStatus(String userBookId, ReadingStatus status) async {
    await _patch(userBookId, (e) {
      e.status = status;
      if (status == ReadingStatus.reading) e.startedAt ??= DateTime.now().toUtc();
      if (status == ReadingStatus.finished) e.finishedAt = DateTime.now().toUtc();
    }, (e) => {
          'status': e.status.wire,
          'started_at': e.startedAt?.toIso8601String(),
          'finished_at': e.finishedAt?.toIso8601String(),
        });
  }

  @override
  Future<void> rate(String userBookId, {required int halfStars, String? review}) async {
    await _patch(userBookId, (e) {
      e
        ..rating = halfStars.clamp(1, 10)
        ..review = review;
    }, (e) => {'rating': e.rating, 'review': e.review});
  }

  @override
  Future<void> removeFromLibrary(String userBookId) async {
    final entity = await _isar.userBookEntitys.getByUuid(userBookId);
    if (entity == null) return;

    await _isar.writeTxn(() => _isar.userBookEntitys.deleteByUuid(userBookId));
    await _outbox.enqueue(
      entity: 'user_books',
      entityId: userBookId,
      op: OutboxOp.delete,
      payload: const {},
    );
    unawaited(_sync.syncNow());
  }

  /// Applies a local mutation and queues ONLY the fields it touched.
  Future<void> _patch(
    String userBookId,
    void Function(UserBookEntity) mutate,
    Map<String, dynamic> Function(UserBookEntity) changedFields,
  ) async {
    final entity = await _isar.userBookEntitys.getByUuid(userBookId);
    if (entity == null) return;

    mutate(entity);
    await _isar.writeTxn(() => _isar.userBookEntitys.putByUuid(entity));
    await _enqueue(userBookId, OutboxOp.update, changedFields(entity));
  }

  Future<void> _enqueue(String id, OutboxOp op, Map<String, dynamic> payload) async {
    await _outbox.enqueue(
      entity: 'user_books',
      entityId: id,
      op: op,
      payload: payload,
    );
    unawaited(_sync.syncNow());
  }
}

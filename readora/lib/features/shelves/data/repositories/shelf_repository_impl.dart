import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/shelves/data/models/shelf_models.dart';
import 'package:readora/features/shelves/domain/entities/shelf.dart';
import 'package:readora/features/shelves/domain/repositories/shelf_repository.dart';
import 'package:uuid/uuid.dart';

class ShelfRepositoryImpl implements ShelfRepository {
  ShelfRepositoryImpl({
    required Isar isar,
    required Outbox outbox,
    required SyncEngine syncEngine,
    required AuthRepository auth,
  })  : _isar = isar,
        _outbox = outbox,
        _sync = syncEngine,
        _auth = auth;

  static const _uuid = Uuid();
  final Isar _isar;
  final Outbox _outbox;
  final SyncEngine _sync;
  final AuthRepository _auth;

  String get _userId => _auth.current?.id ?? '__no_session__';

  @override
  Stream<List<Shelf>> watchShelves() {
    return _isar.shelfEntitys
        .filter()
        .userIdEqualTo(_userId)
        .sortBySortOrder()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toShelf).toList());
  }

  @override
  Stream<List<LibraryBook>> watchShelfBooks(String shelfId) {
    return _isar.shelfItemEntitys
        .filter()
        .shelfUuidEqualTo(shelfId)
        .sortByAddedAtDesc()
        .watch(fireImmediately: true)
        .asyncMap(_joinItems);
  }

  @override
  Stream<List<String>> watchBookShelfIds(String userBookId) {
    return _isar.shelfItemEntitys
        .filter()
        .userBookUuidEqualTo(userBookId)
        .watch(fireImmediately: true)
        .map((items) => items.map((i) => i.shelfUuid).toList());
  }

  @override
  Future<Shelf> createShelf(String name) async {
    final entity = ShelfEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..name = name.trim()
      ..sortOrder = await _nextSortOrder()
      ..createdAt = DateTime.now().toUtc();

    await _isar.writeTxn(() => _isar.shelfEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'shelves',
      entityId: entity.uuid,
      op: OutboxOp.insert,
      payload: entity.toInsertJson(),
    );
    unawaited(_sync.syncNow());
    return _toShelf(entity);
  }

  @override
  Future<void> renameShelf(String shelfId, String name) async {
    final entity = await _isar.shelfEntitys.getByUuid(shelfId);
    if (entity == null) return;
    entity
      ..name = name.trim()
      ..updatedAt = DateTime.now().toUtc();
    await _isar.writeTxn(() => _isar.shelfEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'shelves',
      entityId: shelfId,
      op: OutboxOp.update,
      payload: {'name': entity.name, 'updated_at': entity.updatedAt?.toIso8601String()},
    );
    unawaited(_sync.syncNow());
  }

  @override
  Future<void> deleteShelf(String shelfId) async {
    await _isar.writeTxn(() async {
      await _isar.shelfEntitys.deleteByUuid(shelfId);
      final items = await _isar.shelfItemEntitys
          .filter()
          .shelfUuidEqualTo(shelfId)
          .findAll();
      for (final item in items) {
        await _isar.shelfItemEntitys.deleteByUuid(item.uuid);
      }
    });
    await _outbox.enqueue(
      entity: 'shelves',
      entityId: shelfId,
      op: OutboxOp.delete,
      payload: const {},
    );
    unawaited(_sync.syncNow());
  }

  @override
  Future<void> addBookToShelf(String shelfId, String userBookId) async {
    final existing = await _isar.shelfItemEntitys
        .filter()
        .userBookUuidEqualTo(userBookId)
        .shelfUuidEqualTo(shelfId)
        .findFirst();
    if (existing != null) return;

    final item = ShelfItemEntity()
      ..uuid = _uuid.v4()
      ..userBookUuid = userBookId
      ..shelfUuid = shelfId
      ..addedAt = DateTime.now().toUtc()
      ..createdAt = DateTime.now().toUtc();

    await _isar.writeTxn(() => _isar.shelfItemEntitys.putByUuid(item));
    await _outbox.enqueue(
      entity: 'shelf_items',
      entityId: item.uuid,
      op: OutboxOp.insert,
      payload: item.toInsertJson(),
    );
    unawaited(_sync.syncNow());
  }

  @override
  Future<void> removeBookFromShelf(String shelfId, String userBookId) async {
    final item = await _isar.shelfItemEntitys
        .filter()
        .userBookUuidEqualTo(userBookId)
        .shelfUuidEqualTo(shelfId)
        .findFirst();
    if (item == null) return;

    await _isar.writeTxn(() => _isar.shelfItemEntitys.deleteByUuid(item.uuid));
    await _outbox.enqueue(
      entity: 'shelf_items',
      entityId: item.uuid,
      op: OutboxOp.delete,
      payload: const {},
    );
    unawaited(_sync.syncNow());
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Shelf _toShelf(ShelfEntity e) => Shelf(
        id: e.uuid,
        name: e.name,
        sortOrder: e.sortOrder,
        createdAt: e.createdAt,
      );

  Future<int> _nextSortOrder() async {
    final last = await _isar.shelfEntitys
        .filter()
        .userIdEqualTo(_userId)
        .sortBySortOrderDesc()
        .findFirst();
    return (last?.sortOrder ?? -1) + 1;
  }

  Future<List<LibraryBook>> _joinItems(List<ShelfItemEntity> items) async {
    if (items.isEmpty) return const [];
    final userBooks = await _isar.userBookEntitys
        .getAllByUuid(items.map((i) => i.userBookUuid).toList());
    final valid = userBooks.whereType<UserBookEntity>().toList();
    if (valid.isEmpty) return const [];
    final books = await _isar.bookEntitys
        .getAllByUuid(valid.map((ub) => ub.bookUuid).toList());
    final byUuid = {for (final b in books.whereType<BookEntity>()) b.uuid: b};
    return valid.map((ub) => LibraryBook.from(ub, byUuid[ub.bookUuid])).toList();
  }
}

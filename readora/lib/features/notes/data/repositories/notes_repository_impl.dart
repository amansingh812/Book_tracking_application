import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/domain/entities/note.dart';
import 'package:readora/features/notes/domain/repositories/notes_repository.dart';
import 'package:uuid/uuid.dart';

class NotesRepositoryImpl implements NotesRepository {
  NotesRepositoryImpl({
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
  Stream<List<Note>> watchForBook(String userBookId) {
    return _isar.noteEntitys
        .filter()
        .userIdEqualTo(_userId)
        .userBookUuidEqualTo(userBookId)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toNote).toList());
  }

  @override
  Stream<List<Note>> watchAll() {
    return _isar.noteEntitys
        .filter()
        .userIdEqualTo(_userId)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toNote).toList());
  }

  @override
  Future<Note> create({
    required String userBookId,
    required NoteKind kind,
    required String content,
    int? page,
    String? chapter,
    String? color,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now().toUtc();
    final entity = NoteEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..userBookUuid = userBookId
      ..kind = kind
      ..content = content.trim()
      ..page = page
      ..chapter = chapter
      ..color = color
      ..tags = tags
      ..createdAt = now;

    await _isar.writeTxn(() => _isar.noteEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'notes',
      entityId: entity.uuid,
      op: OutboxOp.insert,
      payload: entity.toInsertJson(),
    );
    unawaited(_sync.syncNow());
    return _toNote(entity);
  }

  @override
  Future<void> update(Note note) async {
    final entity = await _isar.noteEntitys.getByUuid(note.id);
    if (entity == null) return;

    final now = DateTime.now().toUtc();
    entity
      ..kind = note.kind
      ..content = note.content.trim()
      ..page = note.page
      ..chapter = note.chapter
      ..color = note.color
      ..tags = note.tags
      ..isFavorite = note.isFavorite
      ..updatedAt = now;

    await _isar.writeTxn(() => _isar.noteEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'notes',
      entityId: entity.uuid,
      op: OutboxOp.update,
      payload: {
        'kind': entity.kind.wire,
        'content': entity.content,
        'page': entity.page,
        'chapter': entity.chapter,
        'color': entity.color,
        'tags': entity.tags,
        'is_favorite': entity.isFavorite,
        'updated_at': now.toIso8601String(),
      },
    );
    unawaited(_sync.syncNow());
  }

  @override
  Future<void> delete(String noteId) async {
    await _isar.writeTxn(() => _isar.noteEntitys.deleteByUuid(noteId));
    await _outbox.enqueue(
      entity: 'notes',
      entityId: noteId,
      op: OutboxOp.delete,
      payload: const {},
    );
    unawaited(_sync.syncNow());
  }

  @override
  Future<void> toggleFavorite(String noteId, {required bool isFavorite}) async {
    final entity = await _isar.noteEntitys.getByUuid(noteId);
    if (entity == null) return;

    final now = DateTime.now().toUtc();
    entity
      ..isFavorite = isFavorite
      ..updatedAt = now;

    await _isar.writeTxn(() => _isar.noteEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'notes',
      entityId: entity.uuid,
      op: OutboxOp.update,
      payload: {'is_favorite': isFavorite, 'updated_at': now.toIso8601String()},
    );
    unawaited(_sync.syncNow());
  }

  Note _toNote(NoteEntity e) => Note(
        id: e.uuid,
        userBookId: e.userBookUuid,
        kind: e.kind,
        content: e.content,
        page: e.page,
        chapter: e.chapter,
        color: e.color,
        tags: e.tags,
        isFavorite: e.isFavorite,
        createdAt: e.createdAt,
      );
}

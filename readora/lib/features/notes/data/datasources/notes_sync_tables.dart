import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/notes/data/models/note_models.dart';

class NotesSyncTable implements SyncableTable {
  @override
  String get table => 'notes';

  @override
  String get columns =>
      'id, user_id, user_book_id, kind, content, page, chapter, color, tags, '
      'is_favorite, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(NoteEntity.fromJson).toList();
    await isar.writeTxn(() => isar.noteEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.noteEntitys.deleteAllByUuid(uuids));
  }
}

import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/flashcards/data/models/flashcard_models.dart';

class FlashcardsSyncTable implements SyncableTable {
  @override
  String get table => 'flashcards';

  @override
  String get columns =>
      'id, user_id, user_book_id, note_id, front, back, ease, interval_days, '
      'reps, lapses, due_at, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(FlashcardEntity.fromJson).toList();
    await isar.writeTxn(() => isar.flashcardEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.flashcardEntitys.deleteAllByUuid(uuids));
  }
}

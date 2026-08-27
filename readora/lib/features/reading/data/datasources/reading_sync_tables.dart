import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/reading/data/models/reading_models.dart';

class ReadingSessionsSyncTable implements SyncableTable {
  @override
  String get table => 'reading_sessions';

  @override
  String get columns =>
      'id, user_id, user_book_id, started_at, ended_at, duration_seconds, pages_read, device_id, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(
      Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(ReadingSessionEntity.fromJson).toList();
    await isar.writeTxn(() => isar.readingSessionEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(
        () => isar.readingSessionEntitys.deleteAllByUuid(uuids));
  }
}

class ReadingDaysSyncTable implements SyncableTable {
  @override
  String get table => 'reading_days';

  @override
  String get columns =>
      'id, user_id, day_date, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(
      Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(ReadingDayEntity.fromJson).toList();
    await isar.writeTxn(() => isar.readingDayEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.readingDayEntitys.deleteAllByUuid(uuids));
  }
}

class GoalsSyncTable implements SyncableTable {
  @override
  String get table => 'goals';

  @override
  String get columns =>
      'id, user_id, period, metric, target, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(
      Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(GoalEntity.fromJson).toList();
    await isar.writeTxn(() => isar.goalEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.goalEntitys.deleteAllByUuid(uuids));
  }
}

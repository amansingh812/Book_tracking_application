import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/shelves/data/models/shelf_models.dart';

class ShelvesSyncTable implements SyncableTable {
  @override
  String get table => 'shelves';

  @override
  String get columns =>
      'id, user_id, name, sort_order, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(
      Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(ShelfEntity.fromJson).toList();
    await isar.writeTxn(() => isar.shelfEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.shelfEntitys.deleteAllByUuid(uuids));
  }
}

class ShelfItemsSyncTable implements SyncableTable {
  @override
  String get table => 'shelf_items';

  @override
  String get columns =>
      'id, user_book_id, shelf_id, added_at, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(
      Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(ShelfItemEntity.fromJson).toList();
    await isar.writeTxn(() => isar.shelfItemEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.shelfItemEntitys.deleteAllByUuid(uuids));
  }
}

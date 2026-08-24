import 'package:isar_community/isar.dart';

/// Contract every synced feature implements once, in its data layer.
///
/// The [SyncEngine] knows nothing about books, notes, or sessions — it only
/// knows how to move rows. A new synced table is added by writing one of these
/// and registering it in `core/di/injector.dart`; no engine changes.
abstract interface class SyncableTable {
  /// Supabase table name. Must match the `entity` written to the outbox.
  String get table;

  /// Columns to request on pull. Keep it explicit — `select('*')` will happily
  /// pull an embedding column down onto a phone.
  String get columns;

  /// Write server rows into Isar (upsert by uuid).
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows);

  /// Remove rows the server has tombstoned.
  Future<void> removeLocal(Isar isar, List<String> uuids);
}

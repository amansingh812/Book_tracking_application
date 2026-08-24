import 'package:isar_community/isar.dart';

part 'sync_models.g.dart';

/// What kind of change is waiting to reach the server.
enum OutboxOp { insert, update, delete }

/// A pending local change.
///
/// The key design choice: [payloadJson] holds ONLY the fields that changed, not
/// the whole row. The server applies it as a partial UPDATE, so two devices that
/// edited different fields of the same note both keep their edit. That gives us
/// field-level last-write-wins without storing a timestamp per column.
@collection
class OutboxEntry {
  Id id = Isar.autoIncrement;

  /// Supabase table name, e.g. `user_books`.
  @Index(composite: [CompositeIndex('queuedAt')])
  late String entity;

  /// Client-generated uuid of the affected row.
  late String entityId;

  @enumerated
  late OutboxOp op;

  /// JSON object of changed fields only.
  late String payloadJson;

  late DateTime queuedAt;

  int attempts = 0;

  String? lastError;

  /// Set when a retry is backed off. The engine skips entries until this passes.
  DateTime? nextAttemptAt;
}

/// How far we have pulled each table. Compared against the server's
/// `updated_at`, which is always stamped by a Postgres trigger — never by the
/// device — so clock skew cannot make us skip rows.
@collection
class SyncCursor {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String entity;

  DateTime? pulledThrough;
}

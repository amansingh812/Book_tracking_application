import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/sync_models.dart';

/// The write-ahead log between the app and Supabase.
///
/// Repositories call [enqueue] immediately after writing to Isar and then
/// return. Nothing in the presentation layer ever waits for the network.
class Outbox {
  Outbox(this._isar);

  final Isar _isar;

  Future<void> enqueue({
    required String entity,
    required String entityId,
    required OutboxOp op,
    required Map<String, dynamic> payload,
  }) async {
    await _isar.writeTxn(() async {
      // Collapse consecutive updates to the same row: merge the new changed
      // fields into the pending patch instead of queueing a second round trip.
      final pending = await _isar.outboxEntrys
          .filter()
          .entityEqualTo(entity)
          .entityIdEqualTo(entityId)
          .findAll();

      final mergeable = pending
          .where((e) => e.op == OutboxOp.update && op == OutboxOp.update)
          .firstOrNull;

      if (mergeable != null) {
        final merged = <String, dynamic>{
          ...jsonDecode(mergeable.payloadJson) as Map<String, dynamic>,
          ...payload,
        };
        mergeable
          ..payloadJson = jsonEncode(merged)
          ..queuedAt = DateTime.now().toUtc()
          ..attempts = 0
          ..lastError = null
          ..nextAttemptAt = null;
        await _isar.outboxEntrys.put(mergeable);
        return;
      }

      await _isar.outboxEntrys.put(
        OutboxEntry()
          ..entity = entity
          ..entityId = entityId
          ..op = op
          ..payloadJson = jsonEncode(payload)
          ..queuedAt = DateTime.now().toUtc(),
      );
    });
  }

  /// Entries ready to send, oldest first. Backed-off entries are skipped.
  Future<List<OutboxEntry>> ready({int limit = 100}) async {
    final now = DateTime.now().toUtc();
    final all = await _isar.outboxEntrys.where().sortByQueuedAt().limit(limit).findAll();
    return all
        .where((e) => e.nextAttemptAt == null || e.nextAttemptAt!.isBefore(now))
        .toList();
  }

  Future<int> pendingCount() => _isar.outboxEntrys.count();

  Future<void> markSent(OutboxEntry entry) async {
    await _isar.writeTxn(() => _isar.outboxEntrys.delete(entry.id));
  }

  /// Exponential backoff: 2s, 8s, 32s, ... capped at 30 minutes.
  Future<void> markFailed(OutboxEntry entry, Object error) async {
    final attempts = entry.attempts + 1;
    final delaySeconds = (2 << (2 * (attempts - 1)).clamp(0, 10)).clamp(2, 1800);
    await _isar.writeTxn(() async {
      entry
        ..attempts = attempts
        ..lastError = error.toString()
        ..nextAttemptAt = DateTime.now().toUtc().add(Duration(seconds: delaySeconds));
      await _isar.outboxEntrys.put(entry);
    });
  }

  Stream<int> watchPending() =>
      _isar.outboxEntrys.watchLazy().asyncMap((_) => pendingCount());
}

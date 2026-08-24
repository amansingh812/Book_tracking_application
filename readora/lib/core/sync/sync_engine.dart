import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:isar_community/isar.dart';
import 'package:readora/core/logging/app_logger.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/core/sync/sync_status.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Moves rows between Isar and Supabase. Feature-agnostic on purpose.
///
/// Push before pull, always. Pushing first means our own writes come back in the
/// same pull with a server `updated_at`, so the cursor advances past them and we
/// never re-download our own change on the next cycle.
class SyncEngine {
  SyncEngine({
    required Isar isar,
    required SupabaseClient supabase,
    required Outbox outbox,
    required List<SyncableTable> tables,
    Connectivity? connectivity,
  })  : _isar = isar,
        _supabase = supabase,
        _outbox = outbox,
        _tables = tables,
        _connectivity = connectivity ?? Connectivity();

  final Isar _isar;
  final SupabaseClient _supabase;
  final Outbox _outbox;
  final List<SyncableTable> _tables;
  final Connectivity _connectivity;

  final _statusController = StreamController<SyncStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodic;
  bool _running = false;
  SyncStatus _status = const SyncStatus();

  Stream<SyncStatus> get status => _statusController.stream;
  SyncStatus get currentStatus => _status;

  /// Starts the background loop: on reconnect, on new outbox entries, and every
  /// five minutes as a safety net.
  Future<void> start() async {
    _connectivitySub = _connectivity.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) {
        unawaited(syncNow());
      } else {
        _emit(_status.copyWith(state: SyncState.offline));
      }
    });

    _periodic = Timer.periodic(const Duration(minutes: 5), (_) => unawaited(syncNow()));
    unawaited(syncNow());
  }

  Future<void> dispose() async {
    _periodic?.cancel();
    await _connectivitySub?.cancel();
    await _statusController.close();
  }

  /// One full cycle. Safe to call from anywhere; overlapping calls are ignored.
  Future<void> syncNow() async {
    if (_running) return;
    if (_supabase.auth.currentUser == null) return; // guest mode: local only

    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity.every((r) => r == ConnectivityResult.none)) {
      _emit(_status.copyWith(
        state: SyncState.offline,
        pending: await _outbox.pendingCount(),
      ));
      return;
    }

    _running = true;
    _emit(_status.copyWith(state: SyncState.syncing));

    try {
      await _push();
      await _pull();
      _emit(SyncStatus(
        state: SyncState.synced,
        pending: await _outbox.pendingCount(),
        lastSyncedAt: DateTime.now(),
      ));
    } catch (error, stack) {
      AppLogger.error('sync failed', error, stack);
      _emit(_status.copyWith(
        state: SyncState.failed,
        pending: await _outbox.pendingCount(),
        message: 'Changes are saved on this device and will sync when possible.',
      ));
    } finally {
      _running = false;
    }
  }

  // -------------------------------------------------------------------------
  // Push
  // -------------------------------------------------------------------------
  Future<void> _push() async {
    final entries = await _outbox.ready();
    for (final entry in entries) {
      try {
        final payload = jsonDecode(entry.payloadJson) as Map<String, dynamic>;
        switch (entry.op) {
          case OutboxOp.insert:
            await _supabase.from(entry.entity).upsert(payload, onConflict: 'id');
          case OutboxOp.update:
            // Partial update: only the changed fields travel, so a concurrent
            // edit to a different field on another device survives.
            await _supabase.from(entry.entity).update(payload).eq('id', entry.entityId);
          case OutboxOp.delete:
            // Soft delete. Tombstones must reach other devices, so we never
            // issue a hard DELETE from the client.
            await _supabase
                .from(entry.entity)
                .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
                .eq('id', entry.entityId);
        }
        await _outbox.markSent(entry);
      } catch (error) {
        AppLogger.warn('outbox push failed for ${entry.entity}/${entry.entityId}', error);
        await _outbox.markFailed(entry, error);
        // Keep going: one poisoned row must not block the whole queue.
      }
    }
  }

  // -------------------------------------------------------------------------
  // Pull
  // -------------------------------------------------------------------------
  Future<void> _pull() async {
    for (final table in _tables) {
      final cursor = await _cursorFor(table.table);
      final since = cursor.pulledThrough ?? DateTime.utc(1970);

      final rows = await _supabase
          .from(table.table)
          .select(table.columns)
          .gt('updated_at', since.toIso8601String())
          .order('updated_at')
          .limit(1000);

      final list = (rows as List).cast<Map<String, dynamic>>();
      if (list.isEmpty) continue;

      final live = <Map<String, dynamic>>[];
      final tombstoned = <String>[];
      for (final row in list) {
        if (row['deleted_at'] != null) {
          tombstoned.add(row['id'] as String);
        } else {
          live.add(row);
        }
      }

      await table.upsertFromServer(_isar, live);
      if (tombstoned.isNotEmpty) await table.removeLocal(_isar, tombstoned);

      final newest = DateTime.parse(list.last['updated_at'] as String).toUtc();
      await _saveCursor(table.table, newest);
    }
  }

  Future<SyncCursor> _cursorFor(String entity) async {
    final existing = await _isar.syncCursors.filter().entityEqualTo(entity).findFirst();
    return existing ?? (SyncCursor()..entity = entity);
  }

  Future<void> _saveCursor(String entity, DateTime pulledThrough) async {
    final cursor = await _cursorFor(entity);
    cursor.pulledThrough = pulledThrough;
    await _isar.writeTxn(() => _isar.syncCursors.put(cursor));
  }

  /// Clears every cursor so the next sync re-downloads everything. Used after
  /// sign-in on a new device and after the guest-to-account migration.
  Future<void> resetCursors() async {
    await _isar.writeTxn(() => _isar.syncCursors.clear());
  }

  void _emit(SyncStatus next) {
    _status = next;
    if (!_statusController.isClosed) _statusController.add(next);
  }
}

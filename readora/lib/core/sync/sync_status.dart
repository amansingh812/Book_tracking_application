import 'package:equatable/equatable.dart';

enum SyncState {
  /// Everything local has reached the server.
  synced,

  /// A push or pull is in flight.
  syncing,

  /// No connection. Local edits are queued and the app keeps working.
  offline,

  /// The last attempt failed and will be retried with backoff.
  failed,
}

class SyncStatus extends Equatable {
  const SyncStatus({
    this.state = SyncState.synced,
    this.pending = 0,
    this.lastSyncedAt,
    this.message,
  });

  final SyncState state;

  /// Number of queued outbox entries — what the badge in the app bar shows.
  final int pending;

  final DateTime? lastSyncedAt;
  final String? message;

  SyncStatus copyWith({
    SyncState? state,
    int? pending,
    DateTime? lastSyncedAt,
    String? message,
  }) {
    return SyncStatus(
      state: state ?? this.state,
      pending: pending ?? this.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [state, pending, lastSyncedAt, message];
}

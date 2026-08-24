import 'package:flutter/material.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_status.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';

/// Small, honest indicator of where the user's data currently lives.
///
/// Being offline is NOT an error state in Readora — people read on planes and
/// in basements. The badge stays quiet when synced, and when offline it
/// reassures rather than warns. Nothing here is ever red.
///
/// Shape follows the artboard: a hairline pill with a dot and a wide-tracked
/// uppercase label.
class SyncBadge extends StatelessWidget {
  const SyncBadge({required this.engine, super.key});

  final SyncEngine engine;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncStatus>(
      stream: engine.status,
      initialData: engine.currentStatus,
      builder: (context, snapshot) {
        final status = snapshot.data ?? const SyncStatus();
        if (status.state == SyncState.synced && status.pending == 0) {
          return const SizedBox.shrink();
        }

        final (color, text) = switch (status.state) {
          SyncState.syncing => (context.gold, 'Syncing'),
          SyncState.offline => (context.ink3, 'Offline'),
          SyncState.failed => (context.gold, 'Will retry'),
          SyncState.synced => (context.success, 'Saved'),
        };

        return Tooltip(
          message: status.pending > 0
              ? '${status.pending} change${status.pending == 1 ? '' : 's'} saved on this device'
              : 'Everything is saved',
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Radii.pill),
              border: Border.all(color: context.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: Spacing.xs + 2),
                Text(
                  text.toUpperCase(),
                  semanticsLabel: text,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: context.ink3),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

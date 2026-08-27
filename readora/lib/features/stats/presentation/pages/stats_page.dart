import 'package:flutter/material.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/reading/domain/entities/reading_session.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        title: const Text('Reading stats'),
      ),
      body: StreamBuilder<ReadingStats>(
        stream: sl<ReadingRepository>().watchStats(),
        builder: (context, snap) {
          final stats = snap.data;
          return ListView(
            padding: const EdgeInsets.all(Spacing.gutter),
            children: [
              // Streak card
              PaperCard(
                child: Row(
                  children: [
                    Icon(Icons.local_fire_department, color: context.gold, size: 36),
                    const SizedBox(width: Spacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stats == null ? '—' : '${stats.currentStreak}',
                          style: ReadoraType.stat.copyWith(fontSize: 36, color: context.gold),
                        ),
                        Text('day streak', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          stats == null ? '—' : '${stats.longestStreak}',
                          style: theme.textTheme.titleLarge,
                        ),
                        Text('longest', style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // Today card
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today', style: theme.textTheme.labelSmall),
                    const SizedBox(height: Spacing.sm),
                    _StatRow(
                      label: 'Minutes read',
                      value: stats == null ? '—' : '${stats.totalMinutesToday}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),

              // All-time card
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('All time', style: theme.textTheme.labelSmall),
                    const SizedBox(height: Spacing.sm),
                    _StatRow(
                      label: 'Pages read',
                      value: stats == null ? '—' : '${stats.totalPagesRead}',
                    ),
                    const Divider(height: Spacing.xl),
                    _StatRow(
                      label: 'Books finished',
                      value: stats == null ? '—' : '${stats.totalBooksRead}',
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: ReadoraType.stat.copyWith(fontSize: 22, color: context.ink),
        ),
      ],
    );
  }
}

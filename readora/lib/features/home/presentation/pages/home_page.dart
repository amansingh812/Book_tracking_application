import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/design_system/widgets/progress_ring.dart';
import 'package:readora/design_system/widgets/sync_badge.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';
import 'package:readora/features/library/presentation/widgets/progress_update_sheet.dart';
import 'package:readora/features/reading/domain/entities/reading_session.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';
import 'package:readora/features/reading/presentation/widgets/goal_setup_sheet.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static String greeting(DateTime now) {
    if (now.hour < 12) return 'Good morning';
    if (now.hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = context.select((AuthBloc b) => b.state.user?.greetingName ?? 'reader');

    return Scaffold(
      body: AmbientBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(Spacing.gutter),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      '${greeting(DateTime.now())}, $name',
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.sm),
                    child: SyncBadge(engine: sl<SyncEngine>()),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.xl),
              const _ContinueReading(),
              const SizedBox(height: Spacing.lg),
              const _StreakCard(),
              const SizedBox(height: Spacing.lg),
              const _TodaysGoal(),
              const SizedBox(height: Spacing.lg),
              PaperCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your reading insight', style: theme.textTheme.labelSmall),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      'Once you have a few books and notes saved, Readora will '
                      'start noticing the themes you keep returning to.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueReading extends StatelessWidget {
  const _ContinueReading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        final reading = state.books
            .where((b) => b.status == ReadingStatus.reading)
            .toList();

        if (reading.isEmpty) {
          return PaperCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nothing in progress', style: theme.textTheme.titleMedium),
                const SizedBox(height: Spacing.sm),
                Text(
                  'Pick something from your library and mark it as reading.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (final book in reading.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: Spacing.md),
                child: _CurrentBookCard(book: book),
              ),
          ],
        );
      },
    );
  }
}

class _CurrentBookCard extends StatelessWidget {
  const _CurrentBookCard({required this.book});

  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard(
      onTap: () => context.push('/library/${book.id}'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(title: book.title, coverUrl: book.coverUrl, width: 64),
          const SizedBox(width: Spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Continue reading', style: theme.textTheme.labelSmall),
                const SizedBox(height: Spacing.xs),
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  book.pageCount == null
                      ? 'Page ${book.currentPage}'
                      : '${book.currentPage} / ${book.pageCount} pages',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (book.pageCount != null) ProgressRing(progress: book.progress),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<ReadingStats>(
      stream: sl<ReadingRepository>().watchStats(),
      builder: (context, snap) {
        final streak = snap.data?.currentStreak ?? 0;
        if (streak == 0) return const SizedBox.shrink();
        return PaperCard(
          onTap: () => context.push('/profile/stats'),
          child: Row(
            children: [
              Icon(Icons.local_fire_department, color: context.gold, size: 28),
              const SizedBox(width: Spacing.md),
              Text(
                '$streak day streak',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: context.ink3, size: 20),
            ],
          ),
        );
      },
    );
  }
}

class _TodaysGoal extends StatelessWidget {
  const _TodaysGoal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<ActiveGoal?>(
      stream: sl<ReadingRepository>().watchTodayGoal(),
      builder: (context, snap) {
        final goal = snap.data;

        if (goal == null) {
          return PaperCard(
            child: Row(
              children: [
                Icon(Icons.flag_outlined, color: context.gold),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Today's goal", style: theme.textTheme.labelSmall),
                      const SizedBox(height: Spacing.xxs),
                      Text('Set a daily reading goal', style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => GoalSetupSheet.show(context),
                  child: const Text('Set'),
                ),
              ],
            ),
          );
        }

        return PaperCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    goal.isComplete ? Icons.check_circle : Icons.local_fire_department,
                    color: context.gold,
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Today's goal", style: theme.textTheme.labelSmall),
                        const SizedBox(height: Spacing.xxs),
                        Text(
                          goal.isComplete
                              ? 'Goal complete!'
                              : '${goal.minutesToday} of ${goal.targetMinutes} min',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => GoalSetupSheet.show(
                      context,
                      currentMinutes: goal.targetMinutes,
                    ),
                    child: const Text('Edit'),
                  ),
                ],
              ),
              if (!goal.isComplete) ...[
                const SizedBox(height: Spacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Radii.pill),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 6,
                    backgroundColor: context.hairline,
                    valueColor: AlwaysStoppedAnimation(context.gold),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

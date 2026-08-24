import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/design_system/widgets/progress_ring.dart';
import 'package:readora/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';
import 'package:readora/features/library/presentation/widgets/progress_update_sheet.dart';

/// Home answers one question: *what should I do right now?*
///
/// It is deliberately personal rather than analytical — the numbers live in
/// Analytics. If a section here does not help the reader start reading in the
/// next thirty seconds, it belongs on another tab.
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
              Text(
                '${greeting(DateTime.now())}, $name',
                style: theme.textTheme.displayMedium,
              ),
              const SizedBox(height: Spacing.xl),
              const _ContinueReading(),
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
      onTap: () => ProgressUpdateSheet.show(context, book: book),
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

class _TodaysGoal extends StatelessWidget {
  const _TodaysGoal();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // M2 wires this to reading_sessions + goals. Until then it shows the shape
    // of the thing rather than a fake number.
    return PaperCard(
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: context.gold),
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
          TextButton(onPressed: () {}, child: const Text('Set')),
        ],
      ),
    );
  }
}

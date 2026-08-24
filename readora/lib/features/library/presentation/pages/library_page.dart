import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/design_system/widgets/progress_ring.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';
import 'package:readora/features/library/presentation/widgets/progress_update_sheet.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryBloc, LibraryState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Library')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/library/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add a book'),
          ),
          body: AmbientBackground(
            child: Column(
              children: [
                _StatusFilter(selected: state.filter),
                Expanded(
                  child: switch (state.view) {
                    LibraryStatusView.loading =>
                      const Center(child: CircularProgressIndicator()),
                    LibraryStatusView.ready when state.books.isEmpty =>
                      const _EmptyLibrary(),
                    LibraryStatusView.ready => ListView.separated(
                        padding: const EdgeInsets.all(Spacing.gutter),
                        itemCount: state.books.length,
                        separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                        itemBuilder: (_, i) => _LibraryTile(book: state.books[i]),
                      ),
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({this.selected});

  final ReadingStatus? selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.gutter),
        children: [
          _chip(context, null, 'All'),
          for (final status in ReadingStatus.values)
            _chip(context, status, status.label),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, ReadingStatus? status, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: Spacing.sm),
      child: ChoiceChip(
        label: Text(label),
        selected: selected == status,
        onSelected: (_) =>
            context.read<LibraryBloc>().add(LibraryFilterChanged(status)),
      ),
    );
  }
}

class _LibraryTile extends StatelessWidget {
  const _LibraryTile({required this.book});

  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard.flat(
      padding: const EdgeInsets.all(Spacing.md),
      onTap: () => ProgressUpdateSheet.show(context, book: book),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookCover(title: book.title, coverUrl: book.coverUrl, width: 56),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: Spacing.xxs),
                Text(
                  book.authorLine,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Text(
                      book.pageCount == null
                          ? book.status.label
                          : '${book.currentPage} / ${book.pageCount} pages',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (book.status == ReadingStatus.reading && book.pageCount != null) ...[
            const SizedBox(width: Spacing.sm),
            GestureDetector(
              onTap: () => ProgressUpdateSheet.show(context, book: book),
              child: ProgressRing(progress: book.progress, size: 44),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: Spacing.lg),
            Text('Nothing here yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              'Search for a book or scan its barcode to start tracking it.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

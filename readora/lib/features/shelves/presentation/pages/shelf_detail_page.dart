import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/design_system/widgets/progress_ring.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/shelves/presentation/bloc/shelves_bloc.dart';

class ShelfDetailPage extends StatefulWidget {
  const ShelfDetailPage({super.key, required this.shelfId, required this.shelfName});
  final String shelfId;
  final String shelfName;

  @override
  State<ShelfDetailPage> createState() => _ShelfDetailPageState();
}

class _ShelfDetailPageState extends State<ShelfDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShelfDetailBloc>().add(ShelfDetailStarted(widget.shelfId));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShelfDetailBloc, ShelfDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.bg,
          appBar: AppBar(
            backgroundColor: context.bg,
            foregroundColor: context.ink,
            elevation: 0,
            title: Text(widget.shelfName),
          ),
          body: switch (state) {
            ShelfDetailLoading() => const Center(child: CircularProgressIndicator()),
            ShelfDetailLoaded(books: final books) when books.isEmpty => _EmptyShelf(
                shelfName: widget.shelfName,
              ),
            ShelfDetailLoaded(books: final books) => ListView.separated(
                padding: const EdgeInsets.all(Spacing.gutter),
                itemCount: books.length,
                separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                itemBuilder: (_, i) => _ShelfBookTile(
                  book: books[i],
                  onRemove: () => context
                      .read<ShelfDetailBloc>()
                      .add(ShelfDetailBookRemoved(books[i].id)),
                ),
              ),
          },
        );
      },
    );
  }
}

class _ShelfBookTile extends StatelessWidget {
  const _ShelfBookTile({required this.book, required this.onRemove});
  final LibraryBook book;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard.flat(
      padding: const EdgeInsets.all(Spacing.md),
      onTap: () => context.push('/library/${book.id}'),
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
                const SizedBox(height: Spacing.xs),
                Text(
                  book.status.label,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          if (book.status == ReadingStatus.reading && book.pageCount != null)
            Padding(
              padding: const EdgeInsets.only(right: Spacing.sm),
              child: ProgressRing(progress: book.progress, size: 40),
            ),
          IconButton(
            icon: Icon(Icons.bookmark_remove_outlined, color: context.ink3, size: 20),
            tooltip: 'Remove from shelf',
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

class _EmptyShelf extends StatelessWidget {
  const _EmptyShelf({required this.shelfName});
  final String shelfName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_border, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: Spacing.lg),
            Text('"$shelfName" is empty', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              'Add books from the book detail page.',
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/progress_ring.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/book_detail/bloc/book_detail_bloc.dart';
import 'package:readora/features/library/presentation/widgets/progress_update_sheet.dart';
import 'package:readora/features/shelves/presentation/widgets/add_to_shelf_sheet.dart';

class BookDetailPage extends StatelessWidget {
  const BookDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BookDetailBloc, BookDetailState>(
      listener: (context, state) {
        if (state is BookDetailRemoved_) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removed from library')),
          );
        }
        if (state is BookDetailLoaded && state.failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.failure!.message),
              backgroundColor: context.danger,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is BookDetailLoading) {
          return Scaffold(
            backgroundColor: context.bg,
            appBar: AppBar(backgroundColor: context.bg),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (state is BookDetailLoaded) {
          final book = state.book;
          if (book == null) {
            return Scaffold(
              backgroundColor: context.bg,
              appBar: AppBar(backgroundColor: context.bg),
              body: Center(
                child: Text(
                  'Book not found',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            );
          }
          return _BookDetailView(book: book);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// ── Main view ────────────────────────────────────────────────────────────────

class _BookDetailView extends StatelessWidget {
  const _BookDetailView({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: book.isFavorite ? 'Remove from favourites' : 'Add to favourites',
            icon: Icon(
              book.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: book.isFavorite ? context.gold : null,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<BookDetailBloc>().add(const BookDetailFavoriteToggled());
            },
          ),
          IconButton(
            tooltip: 'Remove from library',
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmRemove(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          0,
          Spacing.gutter,
          Spacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CoverHeader(book: book),
            const SizedBox(height: Spacing.xl),

            _eyebrow(context, 'Reading status'),
            const SizedBox(height: Spacing.sm),
            _StatusChips(current: book.status),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push(
                      '/library/${book.id}/read',
                      extra: book,
                    ),
                    icon: const Icon(Icons.menu_book_outlined, size: 18),
                    label: const Text('Read'),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                  ),
                  onPressed: () => AddToShelfSheet.show(context, userBookId: book.id),
                  child: const Icon(Icons.bookmark_add_outlined, size: 20),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xl),

            if (book.status == ReadingStatus.reading || book.currentPage > 0) ...[
              _eyebrow(context, 'Progress'),
              const SizedBox(height: Spacing.sm),
              _ProgressRow(book: book),
              const SizedBox(height: Spacing.xl),
            ],

            _eyebrow(context, 'Your rating'),
            const SizedBox(height: Spacing.sm),
            _StarRating(
              halfStars: book.rating,
              onRate: (halfStars) {
                HapticFeedback.selectionClick();
                context.read<BookDetailBloc>().add(
                      BookDetailRated(halfStars, review: book.review),
                    );
              },
            ),

            if (book.rating != null) ...[
              const SizedBox(height: Spacing.md),
              OutlinedButton.icon(
                onPressed: () => _showReviewSheet(context, book),
                icon: const Icon(Icons.edit_note, size: 18),
                label: Text(
                  book.review?.isNotEmpty == true ? 'Edit review' : 'Write a review',
                ),
              ),
            ],

            if (book.review?.isNotEmpty == true) ...[
              const SizedBox(height: Spacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(Radii.md),
                ),
                child: Text(
                  book.review!,
                  style: ReadoraType.reading.copyWith(color: context.ink2),
                ),
              ),
            ],

            const SizedBox(height: Spacing.xl),

            _eyebrow(context, 'Book details'),
            const SizedBox(height: Spacing.sm),
            _MetadataTable(book: book),
          ],
        ),
      ),
    );
  }

  Widget _eyebrow(BuildContext context, String label) => Text(
        label.toUpperCase(),
        style: ReadoraType.eyebrow.copyWith(color: context.ink3),
      );

  void _showReviewSheet(BuildContext context, LibraryBook book) {
    final bloc = context.read<BookDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ReviewSheet(
        initial: book.review ?? '',
        rating: book.rating ?? 0,
        onSave: (review) {
          bloc.add(BookDetailRated(book.rating ?? 0, review: review));
        },
      ),
    );
  }

  void _confirmRemove(BuildContext context) {
    final bloc = context.read<BookDetailBloc>();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Remove from library?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.sm),
              Text(
                'Your rating and review will also be removed.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.ink2),
              ),
              const SizedBox(height: Spacing.xl),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: context.danger),
                onPressed: () {
                  Navigator.pop(ctx);
                  bloc.add(const BookDetailRemoved());
                },
                child: const Text('Remove'),
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Review bottom sheet (TextField lives here, NOT in page body) ─────────────

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet({
    required this.initial,
    required this.rating,
    required this.onSave,
  });
  final String initial;
  final int rating;
  final void Function(String? review) onSave;

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.md,
            Spacing.gutter,
            Spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: Spacing.md),
                  decoration: BoxDecoration(
                    color: context.hairline,
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                ),
              ),
              Text(
                'Your review',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _ctrl,
                maxLines: 5,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'What did you think?',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: () {
                  final review = _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim();
                  widget.onSave(review);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Review saved')),
                  );
                },
                child: const Text('Save review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _CoverHeader extends StatelessWidget {
  const _CoverHeader({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BookCover(
          title: book.title,
          author: book.authorLine,
          coverUrl: book.coverUrl,
          width: 100,
        ),
        const SizedBox(width: Spacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.xs),
              Text(
                book.title,
                style: Theme.of(context).textTheme.titleLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (book.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  book.subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.ink2),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                book.authorLine,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: context.ink3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusChips extends StatelessWidget {
  const _StatusChips({required this.current});
  final ReadingStatus current;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: ReadingStatus.values.map((s) {
        final selected = s == current;
        return FilterChip(
          selected: selected,
          label: Text(s.label),
          onSelected: (_) {
            if (!selected) {
              context.read<BookDetailBloc>().add(BookDetailStatusChanged(s));
            }
          },
        );
      }).toList(),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ProgressRing(progress: book.progress, size: 52),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.pageCount != null
                    ? 'p. ${book.currentPage} of ${book.pageCount}'
                    : 'p. ${book.currentPage}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (book.pagesLeft != null)
                Text(
                  '${book.pagesLeft} pages left',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.ink3),
                ),
            ],
          ),
        ),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          ),
          onPressed: () => ProgressUpdateSheet.show(context, book: book),
          child: const Text('Update'),
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  const _StarRating({required this.halfStars, required this.onRate});
  final int? halfStars;
  final void Function(int halfStars) onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(10, (i) {
        final filled = halfStars != null && i < halfStars!;
        return GestureDetector(
          onTap: () => onRate(i + 1),
          child: Icon(
            i.isEven ? Icons.star_half : Icons.star,
            color: filled ? context.gold : context.hairline,
            size: 30,
          ),
        );
      }),
    );
  }
}

class _MetadataTable extends StatelessWidget {
  const _MetadataTable({required this.book});
  final LibraryBook book;

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      if (book.publisher != null) MapEntry('Publisher', book.publisher!),
      if (book.publishedDate != null) MapEntry('Published', book.publishedDate!),
      if (book.pageCount != null) MapEntry('Pages', book.pageCount.toString()),
      if (book.isbn13 != null) MapEntry('ISBN-13', book.isbn13!),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((e) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  e.key,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.ink3),
                ),
              ),
              Expanded(
                child: Text(
                  e.value,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: context.ink),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/book_cover.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/search_add/presentation/bloc/search_bloc.dart';
import 'package:readora/features/search_add/presentation/widgets/status_picker_sheet.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SearchBloc, SearchState>(
      listenWhen: (a, b) =>
          a.addedMessage != b.addedMessage || a.failure != b.failure,
      listener: (context, state) {
        final msg = state.addedMessage ?? state.failure?.message;
        if (msg != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(msg)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Title, author, or ISBN…',
                border: InputBorder.none,
              ),
              onChanged: (q) =>
                  context.read<SearchBloc>().add(SearchQueryChanged(q)),
            ),
            actions: [
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    context.read<SearchBloc>().add(const SearchCleared());
                  },
                ),
            ],
          ),
          body: AmbientBackground(
            child: _Body(state: state),
          ),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return switch (state.view) {
      SearchView.idle => _centreMessage(
          context,
          icon: Icons.search,
          headline: 'Find your next book',
          sub: 'Search by title, author, or paste the ISBN.',
        ),
      SearchView.searching => const Center(child: CircularProgressIndicator()),
      SearchView.empty => _centreMessage(
          context,
          icon: Icons.search_off,
          headline: 'No results',
          sub: 'Try a different title or the ISBN from the back cover.',
        ),
      SearchView.error => _centreMessage(
          context,
          icon: Icons.wifi_off,
          headline: 'Couldn\'t search',
          sub: state.failure?.message ?? 'Check your connection and try again.',
        ),
      SearchView.results => ListView.separated(
          padding: const EdgeInsets.all(Spacing.gutter),
          itemCount: state.results.length,
          separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
          itemBuilder: (_, i) {
            final book = state.results[i];
            final inLibrary = state.isInLibrary(book);
            final adding = state.addingBookId == book.uuid;

            return PaperCard.flat(
              padding: const EdgeInsets.all(Spacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(title: book.title, coverUrl: book.coverUrl, width: 52),
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
                        if (book.authors.isNotEmpty) ...[
                          const SizedBox(height: Spacing.xxs),
                          Text(
                            book.authors.join(', '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (book.pageCount != null) ...[
                          const SizedBox(height: Spacing.xxs),
                          Text(
                            '${book.pageCount} pages',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  _AddButton(
                    book: book,
                    inLibrary: inLibrary,
                    adding: adding,
                  ),
                ],
              ),
            );
          },
        ),
    };
  }

  Widget _centreMessage(
    BuildContext context, {
    required IconData icon,
    required String headline,
    required String sub,
  }) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: Spacing.lg),
            Text(headline, style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              sub,
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

class _AddButton extends StatelessWidget {
  const _AddButton({
    required this.book,
    required this.inLibrary,
    required this.adding,
  });

  final BookEntity book;
  final bool inLibrary;
  final bool adding;

  @override
  Widget build(BuildContext context) {
    if (adding) {
      return const SizedBox.square(
        dimension: 40,
        child: Center(
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (inLibrary) {
      return Icon(
        Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
      );
    }

    return IconButton(
      icon: const Icon(Icons.add_circle_outline),
      onPressed: () async {
        final status = await StatusPickerSheet.show(context, book.title);
        if (status == null || !context.mounted) return;
        context.read<SearchBloc>().add(SearchBookAdded(book: book, status: status));
      },
    );
  }
}

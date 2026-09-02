import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/tokens/readora_typography.dart';
import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/domain/entities/note.dart';
import 'package:readora/features/notes/presentation/bloc/notes_bloc.dart';
import 'package:readora/features/notes/presentation/widgets/note_editor_sheet.dart';

enum _KindFilter { all, note, highlight }

class NotesPage extends StatefulWidget {
  const NotesPage({required this.bookTitle, super.key});

  final String bookTitle;

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _searchController = TextEditingController();
  String _query = '';
  _KindFilter _kindFilter = _KindFilter.all;
  bool _favoritesOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Note> _applyFilters(List<Note> notes) {
    final q = _query.trim().toLowerCase();
    return notes.where((n) {
      if (_favoritesOnly && !n.isFavorite) return false;
      if (_kindFilter == _KindFilter.note && n.kind != NoteKind.note) return false;
      if (_kindFilter == _KindFilter.highlight && n.kind != NoteKind.highlight) {
        return false;
      }
      if (q.isEmpty) return true;
      final haystack = [
        n.content,
        n.chapter ?? '',
        ...n.tags,
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  bool get _hasActiveFilter =>
      _query.trim().isNotEmpty || _kindFilter != _KindFilter.all || _favoritesOnly;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bg,
      appBar: AppBar(
        backgroundColor: context.bg,
        foregroundColor: context.ink,
        elevation: 0,
        title: Text('Notes', style: Theme.of(context).textTheme.titleLarge),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addNote(context),
        icon: const Icon(Icons.add),
        label: const Text('Add note'),
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          final allNotes = (state as NotesLoaded).notes;
          if (allNotes.isEmpty) {
            return _EmptyNotes(bookTitle: widget.bookTitle, onAdd: () => _addNote(context));
          }

          final notes = _applyFilters(allNotes);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.gutter,
                  Spacing.sm,
                  Spacing.gutter,
                  0,
                ),
                child: _SearchAndFilterBar(
                  controller: _searchController,
                  onQueryChanged: (v) => setState(() => _query = v),
                  kindFilter: _kindFilter,
                  onKindFilterChanged: (v) => setState(() => _kindFilter = v),
                  favoritesOnly: _favoritesOnly,
                  onFavoritesOnlyChanged: (v) => setState(() => _favoritesOnly = v),
                ),
              ),
              Expanded(
                child: notes.isEmpty
                    ? _NoMatches(onClear: () => setState(() {
                        _searchController.clear();
                        _query = '';
                        _kindFilter = _KindFilter.all;
                        _favoritesOnly = false;
                      }))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          Spacing.gutter,
                          Spacing.md,
                          Spacing.gutter,
                          Spacing.xxxl,
                        ),
                        itemCount: notes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                        itemBuilder: (_, i) => _NoteCard(note: notes[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _addNote(BuildContext context) {
    final bloc = context.read<NotesBloc>();
    NoteEditorSheet.show(
      context,
      title: 'New note',
      onSave: ({
        required kind,
        required content,
        page,
        chapter,
        tags = const [],
      }) async {
        bloc.add(NoteAdded(kind: kind, content: content, page: page, chapter: chapter, tags: tags));
      },
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.onQueryChanged,
    required this.kindFilter,
    required this.onKindFilterChanged,
    required this.favoritesOnly,
    required this.onFavoritesOnlyChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onQueryChanged;
  final _KindFilter kindFilter;
  final ValueChanged<_KindFilter> onKindFilterChanged;
  final bool favoritesOnly;
  final ValueChanged<bool> onFavoritesOnlyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          onChanged: onQueryChanged,
          decoration: InputDecoration(
            hintText: 'Search notes and highlights',
            prefixIcon: Icon(Icons.search, color: context.ink3, size: 20),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close, color: context.ink3, size: 18),
                    onPressed: () {
                      controller.clear();
                      onQueryChanged('');
                    },
                  ),
            filled: true,
            fillColor: context.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.pill),
              borderSide: BorderSide(color: context.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Radii.pill),
              borderSide: BorderSide(color: context.hairline),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: kindFilter == _KindFilter.all,
                onSelected: (_) => onKindFilterChanged(_KindFilter.all),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('Notes'),
                selected: kindFilter == _KindFilter.note,
                onSelected: (_) => onKindFilterChanged(_KindFilter.note),
              ),
              const SizedBox(width: Spacing.xs),
              ChoiceChip(
                label: const Text('Highlights'),
                selected: kindFilter == _KindFilter.highlight,
                onSelected: (_) => onKindFilterChanged(_KindFilter.highlight),
              ),
              const SizedBox(width: Spacing.xs),
              FilterChip(
                label: const Text('Favorites'),
                avatar: Icon(
                  favoritesOnly ? Icons.favorite : Icons.favorite_border,
                  size: 16,
                  color: favoritesOnly ? context.gold : context.ink3,
                ),
                selected: favoritesOnly,
                onSelected: onFavoritesOnlyChanged,
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }
}

class _NoMatches extends StatelessWidget {
  const _NoMatches({required this.onClear});
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 40, color: context.ink3),
            const SizedBox(height: Spacing.md),
            Text('No notes match', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Spacing.sm),
            Text(
              'Try a different search term or clear your filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ink2),
            ),
            const SizedBox(height: Spacing.lg),
            TextButton(onPressed: onClear, child: const Text('Clear filters')),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.bookTitle, required this.onAdd});
  final String bookTitle;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit_note, size: 48, color: context.ink3),
            const SizedBox(height: Spacing.lg),
            Text('No notes yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              'Save quotes, highlights, and your own thinking on "$bookTitle" — '
              'this is what the AI Companion, quizzes, and flashcards are built from.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: context.ink2),
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add your first note'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});
  final Note note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloc = context.read<NotesBloc>();

    return Dismissible(
      key: ValueKey(note.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        decoration: BoxDecoration(
          color: context.danger.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(Radii.md),
        ),
        child: Icon(Icons.delete_outline, color: context.danger),
      ),
      onDismissed: (_) => bloc.add(NoteDeleted(note.id)),
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: () => _edit(context, bloc),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: context.surface,
            border: Border.all(color: context.hairline),
            borderRadius: BorderRadius.circular(Radii.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    note.kind == NoteKind.highlight
                        ? Icons.format_quote
                        : Icons.sticky_note_2_outlined,
                    size: 16,
                    color: context.gold,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    [
                      if (note.chapter != null) note.chapter!,
                      if (note.page != null) 'p.${note.page}',
                    ].join(' · '),
                    style: ReadoraType.eyebrow.copyWith(color: context.ink3),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => bloc.add(
                      NoteFavoriteToggled(note.id, isFavorite: !note.isFavorite),
                    ),
                    child: Icon(
                      note.isFavorite ? Icons.favorite : Icons.favorite_border,
                      size: 18,
                      color: note.isFavorite ? context.gold : context.ink3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              Text(note.content, style: ReadoraType.reading.copyWith(color: context.ink)),
              if (note.tags.isNotEmpty) ...[
                const SizedBox(height: Spacing.sm),
                Wrap(
                  spacing: Spacing.xs,
                  runSpacing: Spacing.xs,
                  children: note.tags
                      .map((t) => Chip(
                            label: Text(t, style: theme.textTheme.labelSmall),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _edit(BuildContext context, NotesBloc bloc) {
    NoteEditorSheet.show(
      context,
      title: 'Edit note',
      initial: note,
      onSave: ({
        required kind,
        required content,
        page,
        chapter,
        tags = const [],
      }) async {
        bloc.add(NoteUpdated(note.copyWith(
          kind: kind,
          content: content,
          page: page,
          chapter: chapter,
          tags: tags,
        )));
      },
    );
  }
}

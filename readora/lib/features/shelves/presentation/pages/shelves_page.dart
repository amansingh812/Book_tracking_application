import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/design_system/widgets/paper_card.dart';
import 'package:readora/features/shelves/domain/entities/shelf.dart';
import 'package:readora/features/shelves/presentation/bloc/shelves_bloc.dart';

class ShelvesPage extends StatefulWidget {
  const ShelvesPage({super.key});

  @override
  State<ShelvesPage> createState() => _ShelvesPageState();
}

class _ShelvesPageState extends State<ShelvesPage> {
  @override
  void initState() {
    super.initState();
    context.read<ShelvesBloc>().add(const ShelvesStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShelvesBloc, ShelvesState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Shelves'),
            foregroundColor: context.ink,
            backgroundColor: context.bg,
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showCreateSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('New shelf'),
          ),
          body: switch (state) {
            ShelvesLoading() => const Center(child: CircularProgressIndicator()),
            ShelvesLoaded(shelves: final shelves) when shelves.isEmpty => _EmptyShelves(
                onCreate: () => _showCreateSheet(context),
              ),
            ShelvesLoaded(shelves: final shelves) => ListView.separated(
                padding: const EdgeInsets.all(Spacing.gutter),
                itemCount: shelves.length,
                separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                itemBuilder: (_, i) => _ShelfTile(shelf: shelves[i]),
              ),
          },
        );
      },
    );
  }

  void _showCreateSheet(BuildContext context) {
    final bloc = context.read<ShelvesBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreateShelfSheet(
        onSave: (name) => bloc.add(ShelfCreated(name)),
      ),
    );
  }
}

class _ShelfTile extends StatelessWidget {
  const _ShelfTile({required this.shelf});
  final Shelf shelf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PaperCard.flat(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      onTap: () => context.push('/library/shelves/${shelf.id}', extra: shelf.name),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: Icon(Icons.bookmark_outlined, color: context.gold, size: 22),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text(
              shelf.name,
              style: theme.textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: context.ink3, size: 20),
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameSheet(context, shelf);
              } else if (value == 'delete') {
                _confirmDelete(context, shelf);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
  }

  void _showRenameSheet(BuildContext context, Shelf shelf) {
    final bloc = context.read<ShelvesBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _CreateShelfSheet(
        initial: shelf.name,
        onSave: (name) => bloc.add(ShelfRenamed(shelf.id, name)),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Shelf shelf) {
    final bloc = context.read<ShelvesBloc>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete shelf?'),
        content: Text('All books will be removed from "${shelf.name}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              bloc.add(ShelfDeleted(shelf.id));
            },
            child: Text('Delete', style: TextStyle(color: context.danger)),
          ),
        ],
      ),
    );
  }
}

class _EmptyShelves extends StatelessWidget {
  const _EmptyShelves({required this.onCreate});
  final VoidCallback onCreate;

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
            Text('No shelves yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: Spacing.sm),
            Text(
              'Create a shelf to organise your books — "To Read Next", "Favourites", anything.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: Spacing.xl),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('New shelf'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateShelfSheet extends StatefulWidget {
  const _CreateShelfSheet({this.initial, required this.onSave});
  final String? initial;
  final void Function(String name) onSave;

  @override
  State<_CreateShelfSheet> createState() => _CreateShelfSheetState();
}

class _CreateShelfSheetState extends State<_CreateShelfSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial ?? '');
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.md, Spacing.gutter, Spacing.xl),
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
              widget.initial == null ? 'New shelf' : 'Rename shelf',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: Spacing.md),
            TextField(
              controller: _ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Shelf name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: Spacing.lg),
            FilledButton(
              onPressed: _save,
              child: Text(widget.initial == null ? 'Create' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    widget.onSave(name);
    Navigator.pop(context);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/features/shelves/domain/entities/shelf.dart';
import 'package:readora/features/shelves/domain/repositories/shelf_repository.dart';
import 'package:readora/features/shelves/presentation/bloc/shelves_bloc.dart';

class AddToShelfSheet extends StatefulWidget {
  const AddToShelfSheet({
    super.key,
    required this.userBookId,
  });

  final String userBookId;

  static Future<void> show(BuildContext context, {required String userBookId}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider(
        create: (_) => ShelvesBloc(sl<ShelfRepository>())..add(const ShelvesStarted()),
        child: AddToShelfSheet(userBookId: userBookId),
      ),
    );
  }

  @override
  State<AddToShelfSheet> createState() => _AddToShelfSheetState();
}

class _AddToShelfSheetState extends State<AddToShelfSheet> {
  final _repo = sl<ShelfRepository>();
  Set<String> _selectedIds = {};
  Set<String> _originalIds = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _repo.watchBookShelfIds(widget.userBookId).first.then((ids) {
      if (mounted) {
        setState(() {
          _selectedIds = ids.toSet();
          _originalIds = ids.toSet();
          _loaded = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: BlocBuilder<ShelvesBloc, ShelvesState>(
        builder: (context, state) {
          final shelves = state is ShelvesLoaded ? state.shelves : const <Shelf>[];
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.md, Spacing.gutter, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Add to shelf', style: theme.textTheme.titleMedium),
                        TextButton.icon(
                          onPressed: () => _showCreateSheet(context),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('New'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!_loaded || state is ShelvesLoading)
                const Padding(
                  padding: EdgeInsets.all(Spacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (shelves.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(Spacing.xl),
                  child: Text(
                    'No shelves yet. Create one above.',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: shelves.length,
                    itemBuilder: (_, i) {
                      final shelf = shelves[i];
                      final checked = _selectedIds.contains(shelf.id);
                      return CheckboxListTile(
                        value: checked,
                        title: Text(shelf.name),
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (_) {
                          setState(() {
                            if (checked) {
                              _selectedIds.remove(shelf.id);
                            } else {
                              _selectedIds.add(shelf.id);
                            }
                          });
                        },
                      );
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.md, Spacing.gutter, Spacing.xl),
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Done'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final added = _selectedIds.difference(_originalIds);
    final removed = _originalIds.difference(_selectedIds);

    for (final shelfId in added) {
      await _repo.addBookToShelf(shelfId, widget.userBookId);
    }
    for (final shelfId in removed) {
      await _repo.removeBookFromShelf(shelfId, widget.userBookId);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showCreateSheet(BuildContext context) {
    final bloc = context.read<ShelvesBloc>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Spacing.gutter, Spacing.md, Spacing.gutter, Spacing.xl),
          child: _InlineCreateShelf(
            onSave: (name) {
              bloc.add(ShelfCreated(name));
              Navigator.pop(ctx);
            },
          ),
        ),
      ),
    );
  }
}

class _InlineCreateShelf extends StatefulWidget {
  const _InlineCreateShelf({required this.onSave});
  final void Function(String) onSave;

  @override
  State<_InlineCreateShelf> createState() => _InlineCreateShelfState();
}

class _InlineCreateShelfState extends State<_InlineCreateShelf> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('New shelf', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Spacing.md),
        TextField(
          controller: _ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Shelf name', border: OutlineInputBorder()),
        ),
        const SizedBox(height: Spacing.lg),
        FilledButton(
          onPressed: () {
            final name = _ctrl.text.trim();
            if (name.isEmpty) return;
            widget.onSave(name);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }
}

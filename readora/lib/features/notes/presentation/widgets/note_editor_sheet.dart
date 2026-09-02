import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readora/design_system/tokens/readora_colors.dart';
import 'package:readora/design_system/tokens/readora_spacing.dart';
import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/domain/entities/note.dart';

/// Add/edit sheet for a single note or highlight.
///
/// Deliberately decoupled from [NotesRepository]/[NotesBloc] — the caller
/// supplies [onSave], so this same sheet works from a book's Notes tab (which
/// dispatches through the bloc) and from the AI Companion's "Save to notes"
/// action (which writes through the repository directly, with no bloc in
/// that part of the tree).
class NoteEditorSheet extends StatefulWidget {
  const NoteEditorSheet({
    required this.onSave,
    this.initial,
    this.title = 'New note',
    super.key,
  });

  final Future<void> Function({
    required NoteKind kind,
    required String content,
    int? page,
    String? chapter,
    List<String> tags,
  }) onSave;
  final Note? initial;
  final String title;

  static Future<void> show(
    BuildContext context, {
    required Future<void> Function({
      required NoteKind kind,
      required String content,
      int? page,
      String? chapter,
      List<String> tags,
    }) onSave,
    Note? initial,
    String title = 'New note',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ReadoraColors.darkSurface
          : ReadoraColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
      ),
      builder: (_) => NoteEditorSheet(onSave: onSave, initial: initial, title: title),
    );
  }

  @override
  State<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends State<NoteEditorSheet> {
  late NoteKind _kind;
  late final TextEditingController _content;
  late final TextEditingController _page;
  late final TextEditingController _chapter;
  late final TextEditingController _tags;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _kind = initial?.kind ?? NoteKind.note;
    _content = TextEditingController(text: initial?.content ?? '');
    _page = TextEditingController(text: initial?.page?.toString() ?? '');
    _chapter = TextEditingController(text: initial?.chapter ?? '');
    _tags = TextEditingController(text: initial?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _content.dispose();
    _page.dispose();
    _chapter.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _content.text.trim();
    if (content.isEmpty || _saving) return;

    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    final tags = _tags.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      await widget.onSave(
        kind: _kind,
        content: content,
        page: int.tryParse(_page.text.trim()),
        chapter: _chapter.text.trim().isEmpty ? null : _chapter.text.trim(),
        tags: tags,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
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
              Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Spacing.md),
              Wrap(
                spacing: Spacing.sm,
                children: NoteKind.values.map((k) {
                  return ChoiceChip(
                    label: Text(k == NoteKind.note ? 'Note' : 'Highlight'),
                    selected: _kind == k,
                    onSelected: (_) => setState(() => _kind = k),
                  );
                }).toList(),
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _content,
                maxLines: 5,
                autofocus: widget.initial == null,
                decoration: InputDecoration(
                  hintText: _kind == NoteKind.highlight
                      ? 'What did you highlight?'
                      : 'What are you thinking?',
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _page,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Page',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _chapter,
                      decoration: const InputDecoration(
                        labelText: 'Chapter (optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _tags,
                decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

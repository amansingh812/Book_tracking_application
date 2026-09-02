import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/features/flashcards/domain/repositories/flashcards_repository.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/presentation/bloc/library_bloc.dart';
import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/domain/repositories/notes_repository.dart';
import 'package:readora/features/notes/presentation/widgets/note_editor_sheet.dart';
import '../bloc/ai_chat_bloc.dart';
import 'book_selection_modal.dart';
import 'thinking_dots.dart';

class AiChatBubble extends StatelessWidget {
  final ChatMessage message;

  const AiChatBubble({super.key, required this.message});

  /// Resolves the book this message should be attached to.
  ///
  /// `AiChatBloc.activeBookId` (set by [BookSelectorCard]) is actually the
  /// shared `books.id`, not `user_books.id` — the same indirection
  /// [BookSelectorCard] itself resolves by matching against the reader's
  /// library. Notes and flashcards need the real `user_books.id`, so we do
  /// the same lookup here rather than trusting the id directly. When there is
  /// no active book, or no match, we ask.
  Future<LibraryBook?> _resolveBook(BuildContext context) async {
    final activeBookId = context.read<AiChatBloc>().state.activeBookId;
    if (activeBookId != null) {
      final books = context.read<LibraryBloc>().state.books;
      for (final b in books) {
        if (b.bookId == activeBookId) return b;
      }
    }
    if (!context.mounted) return null;
    return showModalBottomSheet<LibraryBook>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const BookSelectionModal(),
    );
  }

  Future<void> _saveToNotes(BuildContext context) async {
    final book = await _resolveBook(context);
    if (book == null || !context.mounted) return;

    await NoteEditorSheet.show(
      context,
      title: 'Save to notes',
      onSave: ({
        required kind,
        required content,
        page,
        chapter,
        tags = const [],
      }) async {
        await sl<NotesRepository>().create(
          userBookId: book.id,
          kind: kind,
          content: content,
          page: page,
          chapter: chapter,
          tags: tags,
        );
      },
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to notes')),
      );
    }
  }

  Future<void> _makeFlashcard(BuildContext context) async {
    final book = await _resolveBook(context);
    if (!context.mounted) return;

    final front = TextEditingController();
    final back = TextEditingController(text: message.content);

    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New flashcard'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: front,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Front (question / cue)'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: back,
              decoration: const InputDecoration(labelText: 'Back (answer)'),
              maxLines: 4,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: front.text.trim().isEmpty
                ? null
                : () => Navigator.pop(dialogContext, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (created == true) {
      await sl<FlashcardsRepository>().createFromText(
        front: front.text.trim(),
        back: back.text.trim(),
        userBookId: book?.id,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Flashcard saved')),
        );
      }
    }
    front.dispose();
    back.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            radius: 16,
            child: const Icon(Icons.auto_awesome, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 0.5), // hairline
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isStreaming && message.content.isEmpty)
                    const ThinkingDots()
                  else
                    Text(
                      message.content,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  if (!message.isStreaming && message.content.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _saveToNotes(context),
                          icon: const Icon(Icons.bookmark_border, size: 16),
                          label: const Text('Save to notes', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        const SizedBox(width: 12),
                        TextButton.icon(
                          onPressed: () => _makeFlashcard(context),
                          icon: const Icon(Icons.style, size: 16),
                          label: const Text('Flashcard', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(width: 32), // space on the right
        ],
      ),
    );
  }
}

class UserChatBubble extends StatelessWidget {
  final ChatMessage message;

  const UserChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 48), // space on the left
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer, // ink bg
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              child: Text(
                message.content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

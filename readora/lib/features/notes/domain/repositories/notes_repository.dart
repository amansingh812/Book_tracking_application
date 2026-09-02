import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/domain/entities/note.dart';

abstract interface class NotesRepository {
  /// All notes for one book, newest first.
  Stream<List<Note>> watchForBook(String userBookId);

  /// All notes across the whole library — used by AI context previews and
  /// the "recent notes" surfaces outside a single book.
  Stream<List<Note>> watchAll();

  Future<Note> create({
    required String userBookId,
    required NoteKind kind,
    required String content,
    int? page,
    String? chapter,
    String? color,
    List<String> tags = const [],
  });

  Future<void> update(Note note);

  Future<void> delete(String noteId);

  Future<void> toggleFavorite(String noteId, {required bool isFavorite});
}

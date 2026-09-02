part of 'notes_bloc.dart';

sealed class NotesEvent extends Equatable {
  const NotesEvent();
  @override
  List<Object?> get props => [];
}

class NotesStarted extends NotesEvent {
  const NotesStarted(this.userBookId);
  final String userBookId;
  @override
  List<Object?> get props => [userBookId];
}

class NoteAdded extends NotesEvent {
  const NoteAdded({
    required this.kind,
    required this.content,
    this.page,
    this.chapter,
    this.tags = const [],
  });
  final NoteKind kind;
  final String content;
  final int? page;
  final String? chapter;
  final List<String> tags;
  @override
  List<Object?> get props => [kind, content, page, chapter, tags];
}

class NoteUpdated extends NotesEvent {
  const NoteUpdated(this.note);
  final Note note;
  @override
  List<Object?> get props => [note];
}

class NoteDeleted extends NotesEvent {
  const NoteDeleted(this.noteId);
  final String noteId;
  @override
  List<Object?> get props => [noteId];
}

class NoteFavoriteToggled extends NotesEvent {
  const NoteFavoriteToggled(this.noteId, {required this.isFavorite});
  final String noteId;
  final bool isFavorite;
  @override
  List<Object?> get props => [noteId, isFavorite];
}

class _NotesListUpdated extends NotesEvent {
  const _NotesListUpdated(this.notes);
  final List<Note> notes;
  @override
  List<Object?> get props => [notes];
}

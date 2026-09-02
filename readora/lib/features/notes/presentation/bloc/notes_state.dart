part of 'notes_bloc.dart';

sealed class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object?> get props => [];
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  const NotesLoaded({required this.notes});
  final List<Note> notes;
  @override
  List<Object?> get props => [notes];
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/features/notes/data/models/note_models.dart';
import 'package:readora/features/notes/domain/entities/note.dart';
import 'package:readora/features/notes/domain/repositories/notes_repository.dart';

part 'notes_event.dart';
part 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  NotesBloc(this._repo) : super(const NotesLoading()) {
    on<NotesStarted>(_onStarted);
    on<NoteAdded>(_onAdded);
    on<NoteUpdated>(_onUpdated);
    on<NoteDeleted>(_onDeleted);
    on<NoteFavoriteToggled>(_onFavoriteToggled);
    on<_NotesListUpdated>(_onListUpdated);
  }

  final NotesRepository _repo;
  StreamSubscription<List<Note>>? _sub;
  String? _userBookId;

  void _onStarted(NotesStarted event, Emitter<NotesState> emit) {
    _userBookId = event.userBookId;
    _sub?.cancel();
    _sub = _repo.watchForBook(event.userBookId).listen((n) => add(_NotesListUpdated(n)));
  }

  void _onListUpdated(_NotesListUpdated event, Emitter<NotesState> emit) {
    emit(NotesLoaded(notes: event.notes));
  }

  Future<void> _onAdded(NoteAdded event, Emitter<NotesState> emit) async {
    if (_userBookId == null) return;
    try {
      await _repo.create(
        userBookId: _userBookId!,
        kind: event.kind,
        content: event.content,
        page: event.page,
        chapter: event.chapter,
        tags: event.tags,
      );
    } catch (_) {}
  }

  Future<void> _onUpdated(NoteUpdated event, Emitter<NotesState> emit) async {
    try {
      await _repo.update(event.note);
    } catch (_) {}
  }

  Future<void> _onDeleted(NoteDeleted event, Emitter<NotesState> emit) async {
    try {
      await _repo.delete(event.noteId);
    } catch (_) {}
  }

  Future<void> _onFavoriteToggled(
    NoteFavoriteToggled event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repo.toggleFavorite(event.noteId, isFavorite: event.isFavorite);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

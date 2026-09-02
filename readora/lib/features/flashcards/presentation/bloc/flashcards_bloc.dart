import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/features/flashcards/domain/entities/flashcard.dart';
import 'package:readora/features/flashcards/domain/repositories/flashcards_repository.dart';

part 'flashcards_event.dart';
part 'flashcards_state.dart';

/// Powers both surfaces: pass [userBookId] for "cards from this book" (used
/// from the book detail page, supports generation); omit it for the
/// library-wide due-today review queue (used from the Profile/Study tab).
class FlashcardsBloc extends Bloc<FlashcardsEvent, FlashcardsState> {
  FlashcardsBloc(this._repo, {this.userBookId}) : super(const FlashcardsState()) {
    on<FlashcardsStarted>(_onStarted);
    on<FlashcardsGenerateRequested>(_onGenerateRequested);
    on<FlashcardGraded>(_onGraded);
    on<_FlashcardsListUpdated>(_onListUpdated);
    add(const FlashcardsStarted());
  }

  final FlashcardsRepository _repo;
  final String? userBookId;
  StreamSubscription<List<Flashcard>>? _sub;

  void _onStarted(FlashcardsStarted event, Emitter<FlashcardsState> emit) {
    _sub?.cancel();
    final stream = userBookId != null
        ? _repo.watchForBook(userBookId!)
        : _repo.watchDue();
    _sub = stream.listen((cards) => add(_FlashcardsListUpdated(cards)));
  }

  void _onListUpdated(_FlashcardsListUpdated event, Emitter<FlashcardsState> emit) {
    emit(state.copyWith(cards: event.cards, loaded: true));
  }

  Future<void> _onGenerateRequested(
    FlashcardsGenerateRequested event,
    Emitter<FlashcardsState> emit,
  ) async {
    if (userBookId == null) return;
    emit(state.copyWith(generating: true, error: null));
    try {
      await _repo.generateFromBook(userBookId: userBookId!, count: event.count);
      emit(state.copyWith(generating: false));
    } on FlashcardGenerationException catch (e) {
      emit(state.copyWith(generating: false, error: e.message));
    } catch (_) {
      emit(state.copyWith(
        generating: false,
        error: 'Something went wrong generating those cards. Try again.',
      ));
    }
  }

  Future<void> _onGraded(FlashcardGraded event, Emitter<FlashcardsState> emit) async {
    try {
      await _repo.grade(event.cardId, event.grade);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

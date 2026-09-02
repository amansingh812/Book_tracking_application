import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/features/quiz/domain/entities/quiz.dart';
import 'package:readora/features/quiz/domain/repositories/quiz_repository.dart';

part 'quiz_event.dart';
part 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  QuizBloc(this._repo) : super(const QuizState()) {
    on<QuizStarted>(_onStarted);
    on<QuizGenerateRequested>(_onGenerateRequested);
    on<_QuizListUpdated>(_onListUpdated);
  }

  final QuizRepository _repo;
  StreamSubscription<List<Quiz>>? _sub;
  String? _userBookId;

  void _onStarted(QuizStarted event, Emitter<QuizState> emit) {
    _userBookId = event.userBookId;
    _sub?.cancel();
    _sub = _repo.watchForBook(event.userBookId).listen((q) => add(_QuizListUpdated(q)));
  }

  void _onListUpdated(_QuizListUpdated event, Emitter<QuizState> emit) {
    emit(state.copyWith(quizzes: event.quizzes, loaded: true));
  }

  Future<void> _onGenerateRequested(
    QuizGenerateRequested event,
    Emitter<QuizState> emit,
  ) async {
    if (_userBookId == null) return;
    emit(state.copyWith(generating: true, error: null));
    try {
      await _repo.generate(userBookId: _userBookId!, count: event.count);
      emit(state.copyWith(generating: false));
    } on QuizGenerationException catch (e) {
      emit(state.copyWith(generating: false, error: e.message));
    } catch (_) {
      emit(state.copyWith(
        generating: false,
        error: 'Something went wrong generating that quiz. Try again.',
      ));
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

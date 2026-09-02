part of 'quiz_bloc.dart';

sealed class QuizEvent extends Equatable {
  const QuizEvent();
  @override
  List<Object?> get props => [];
}

class QuizStarted extends QuizEvent {
  const QuizStarted(this.userBookId);
  final String userBookId;
  @override
  List<Object?> get props => [userBookId];
}

class QuizGenerateRequested extends QuizEvent {
  const QuizGenerateRequested({this.count = 8});
  final int count;
  @override
  List<Object?> get props => [count];
}

class _QuizListUpdated extends QuizEvent {
  const _QuizListUpdated(this.quizzes);
  final List<Quiz> quizzes;
  @override
  List<Object?> get props => [quizzes];
}

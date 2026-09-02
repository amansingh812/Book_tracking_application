part of 'quiz_bloc.dart';

class QuizState extends Equatable {
  const QuizState({
    this.quizzes = const [],
    this.loaded = false,
    this.generating = false,
    this.error,
  });

  final List<Quiz> quizzes;
  final bool loaded;
  final bool generating;
  final String? error;

  QuizState copyWith({
    List<Quiz>? quizzes,
    bool? loaded,
    bool? generating,
    String? error,
  }) {
    return QuizState(
      quizzes: quizzes ?? this.quizzes,
      loaded: loaded ?? this.loaded,
      generating: generating ?? this.generating,
      error: error,
    );
  }

  @override
  List<Object?> get props => [quizzes, loaded, generating, error];
}

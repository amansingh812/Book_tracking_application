import 'package:equatable/equatable.dart';

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.position,
    required this.prompt,
    required this.options,
    this.answerIndex,
    this.explanation,
  });

  final String id;
  final int position;
  final String prompt;
  final List<String> options;
  final int? answerIndex;
  final String? explanation;

  @override
  List<Object?> get props => [id, position, prompt, options, answerIndex, explanation];
}

class Quiz extends Equatable {
  const Quiz({
    required this.id,
    required this.userBookId,
    required this.createdAt,
    this.title,
    this.questions = const [],
  });

  final String id;
  final String userBookId;
  final String? title;
  final List<QuizQuestion> questions;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, userBookId, title, questions, createdAt];
}

class QuizAttempt extends Equatable {
  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.score,
    required this.answers,
    required this.takenAt,
  });

  final String id;
  final String quizId;
  final int score;
  final List<int?> answers;
  final DateTime takenAt;

  @override
  List<Object?> get props => [id, quizId, score, answers, takenAt];
}

/// Thrown by [QuizRepository.generate] when the AI backend refuses the
/// request — no notes yet, or the free-tier quota is used up. The message is
/// already reader-facing (it comes straight from the Edge Function).
class QuizGenerationException implements Exception {
  const QuizGenerationException(this.code, this.message);
  final String code;
  final String message;

  bool get isQuotaExceeded => code == 'AI_QUOTA_EXCEEDED';
  bool get isNoNotes => code == 'NO_NOTES';

  @override
  String toString() => message;
}

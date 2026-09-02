import 'package:readora/features/quiz/domain/entities/quiz.dart';

abstract interface class QuizRepository {
  /// Quizzes for one book, newest first, each with its questions attached.
  Stream<List<Quiz>> watchForBook(String userBookId);

  /// Score history for one quiz, newest attempt first.
  Stream<List<QuizAttempt>> watchAttempts(String quizId);

  /// Calls the `ai-generate` Edge Function (task: quiz) and persists the
  /// result locally + to the outbox. Throws [QuizGenerationException] on a
  /// structured failure (no notes yet, quota exceeded, bad AI output).
  Future<Quiz> generate({required String userBookId, int count = 8});

  /// Scores [answers] client-side against the stored answer key and records
  /// the attempt.
  Future<QuizAttempt> submitAttempt({
    required String quizId,
    required List<int?> answers,
  });
}

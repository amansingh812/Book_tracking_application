import 'package:readora/features/flashcards/domain/entities/flashcard.dart';

abstract interface class FlashcardsRepository {
  /// Cards due for review right now, across the whole library, oldest-due
  /// first. Works offline — review scheduling never needs the network.
  Stream<List<Flashcard>> watchDue();

  /// Every card for one book, regardless of due date.
  Stream<List<Flashcard>> watchForBook(String userBookId);

  /// Calls `ai-generate` (task: flashcards) and persists the resulting cards.
  /// Throws [FlashcardGenerationException] on a structured failure.
  Future<List<Flashcard>> generateFromBook({required String userBookId, int count = 10});

  /// Creates a single card directly — used by the "Flashcard" quick action on
  /// an AI Companion message.
  Future<Flashcard> createFromText({
    required String front,
    required String back,
    String? userBookId,
    String? noteId,
  });

  /// Applies [grade] to the card's SM-2-lite schedule and persists the result.
  Future<void> grade(String cardId, ReviewGrade grade);
}

class FlashcardGenerationException implements Exception {
  const FlashcardGenerationException(this.code, this.message);
  final String code;
  final String message;
  bool get isQuotaExceeded => code == 'AI_QUOTA_EXCEEDED';
  bool get isNoNotes => code == 'NO_NOTES';
  @override
  String toString() => message;
}

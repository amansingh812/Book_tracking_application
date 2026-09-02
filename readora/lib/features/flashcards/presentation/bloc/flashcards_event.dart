part of 'flashcards_bloc.dart';

sealed class FlashcardsEvent extends Equatable {
  const FlashcardsEvent();
  @override
  List<Object?> get props => [];
}

class FlashcardsStarted extends FlashcardsEvent {
  const FlashcardsStarted();
}

class FlashcardsGenerateRequested extends FlashcardsEvent {
  const FlashcardsGenerateRequested({this.count = 10});
  final int count;
  @override
  List<Object?> get props => [count];
}

class FlashcardGraded extends FlashcardsEvent {
  const FlashcardGraded(this.cardId, this.grade);
  final String cardId;
  final ReviewGrade grade;
  @override
  List<Object?> get props => [cardId, grade];
}

class _FlashcardsListUpdated extends FlashcardsEvent {
  const _FlashcardsListUpdated(this.cards);
  final List<Flashcard> cards;
  @override
  List<Object?> get props => [cards];
}

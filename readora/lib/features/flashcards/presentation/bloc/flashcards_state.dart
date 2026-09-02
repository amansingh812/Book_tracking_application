part of 'flashcards_bloc.dart';

class FlashcardsState extends Equatable {
  const FlashcardsState({
    this.cards = const [],
    this.loaded = false,
    this.generating = false,
    this.error,
  });

  final List<Flashcard> cards;
  final bool loaded;
  final bool generating;
  final String? error;

  FlashcardsState copyWith({
    List<Flashcard>? cards,
    bool? loaded,
    bool? generating,
    String? error,
  }) {
    return FlashcardsState(
      cards: cards ?? this.cards,
      loaded: loaded ?? this.loaded,
      generating: generating ?? this.generating,
      error: error,
    );
  }

  @override
  List<Object?> get props => [cards, loaded, generating, error];
}

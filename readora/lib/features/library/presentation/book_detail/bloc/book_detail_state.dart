part of 'book_detail_bloc.dart';

sealed class BookDetailState extends Equatable {
  const BookDetailState();
  @override
  List<Object?> get props => [];
}

final class BookDetailLoading extends BookDetailState {
  const BookDetailLoading();
}

final class BookDetailLoaded extends BookDetailState {
  const BookDetailLoaded({
    this.book,
    this.isSaving = false,
    this.failure,
  });

  final LibraryBook? book;
  final bool isSaving;
  final Failure? failure;

  BookDetailLoaded copyWith({
    LibraryBook? book,
    bool? isSaving,
    Failure? failure,
  }) =>
      BookDetailLoaded(
        book: book ?? this.book,
        isSaving: isSaving ?? this.isSaving,
        failure: failure,
      );

  @override
  List<Object?> get props => [book, isSaving, failure];
}

// Renamed to avoid conflict with the event of the same name.
final class BookDetailRemoved_ extends BookDetailState {
  const BookDetailRemoved_();
}

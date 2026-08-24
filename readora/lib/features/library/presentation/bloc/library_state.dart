part of 'library_bloc.dart';

enum LibraryStatusView { loading, ready }

final class LibraryState extends Equatable {
  const LibraryState({
    this.view = LibraryStatusView.loading,
    this.books = const [],
    this.filter,
    this.failure,
  });

  final LibraryStatusView view;
  final List<LibraryBook> books;
  final ReadingStatus? filter;
  final Failure? failure;

  bool get isEmpty => view == LibraryStatusView.ready && books.isEmpty;

  LibraryState copyWith({
    LibraryStatusView? view,
    List<LibraryBook>? books,
    ReadingStatus? filter,
    bool clearFilter = false,
    Failure? failure,
  }) {
    return LibraryState(
      view: view ?? this.view,
      books: books ?? this.books,
      filter: clearFilter ? null : filter ?? this.filter,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [view, books, filter, failure];
}

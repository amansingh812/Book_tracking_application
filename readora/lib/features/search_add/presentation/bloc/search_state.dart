part of 'search_bloc.dart';

enum SearchView { idle, searching, results, empty, error }

final class SearchState extends Equatable {
  const SearchState({
    this.view = SearchView.idle,
    this.query = '',
    this.results = const [],
    this.libraryBookIds = const {},
    this.addingBookId,
    this.addedMessage,
    this.failure,
  });

  final SearchView view;
  final String query;
  final List<BookEntity> results;

  /// UUIDs of catalogue books already in the user's library.
  final Set<String> libraryBookIds;

  /// UUID of the book currently being added (shows per-row spinner).
  final String? addingBookId;

  /// Transient success message after adding a book.
  final String? addedMessage;

  final Failure? failure;

  bool isInLibrary(BookEntity book) => libraryBookIds.contains(book.uuid);

  SearchState copyWith({
    SearchView? view,
    String? query,
    List<BookEntity>? results,
    Set<String>? libraryBookIds,
    String? addingBookId,
    String? addedMessage,
    Failure? failure,
    bool clearAdding = false,
    bool clearMessage = false,
    bool clearFailure = false,
  }) {
    return SearchState(
      view: view ?? this.view,
      query: query ?? this.query,
      results: results ?? this.results,
      libraryBookIds: libraryBookIds ?? this.libraryBookIds,
      addingBookId: clearAdding ? null : addingBookId ?? this.addingBookId,
      addedMessage: clearMessage ? null : addedMessage ?? this.addedMessage,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }

  @override
  List<Object?> get props =>
      [view, query, results, libraryBookIds, addingBookId, addedMessage, failure];
}

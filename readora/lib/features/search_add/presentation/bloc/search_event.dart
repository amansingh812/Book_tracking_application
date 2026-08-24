part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once when the screen mounts to start watching the local library.
final class SearchStarted extends SearchEvent {
  const SearchStarted();
}

/// Fired on every keystroke; the Bloc debounces before running the search.
final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Internal: the library stream pushed a new snapshot.
final class _SearchLibraryUpdated extends SearchEvent {
  const _SearchLibraryUpdated(this.bookIds);
  final Set<String> bookIds;

  @override
  List<Object?> get props => [bookIds];
}

/// User tapped the add icon on a result row.
final class SearchBookAdded extends SearchEvent {
  const SearchBookAdded({required this.book, required this.status});
  final BookEntity book;
  final ReadingStatus status;

  @override
  List<Object?> get props => [book, status];
}

/// User cleared the search field.
final class SearchCleared extends SearchEvent {
  const SearchCleared();
}

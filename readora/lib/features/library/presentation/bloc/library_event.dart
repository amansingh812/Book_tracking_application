part of 'library_bloc.dart';

sealed class LibraryEvent extends Equatable {
  const LibraryEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribes to the local database. Fired once when the page mounts.
final class LibraryStarted extends LibraryEvent {
  const LibraryStarted();
}

final class LibraryFilterChanged extends LibraryEvent {
  const LibraryFilterChanged(this.status);
  final ReadingStatus? status;

  @override
  List<Object?> get props => [status];
}

/// Internal: the Isar stream produced a new snapshot.
final class LibraryBooksUpdated extends LibraryEvent {
  const LibraryBooksUpdated(this.books);
  final List<LibraryBook> books;

  @override
  List<Object?> get props => [books];
}

final class LibraryProgressUpdated extends LibraryEvent {
  const LibraryProgressUpdated({required this.userBookId, required this.page});
  final String userBookId;
  final int page;

  @override
  List<Object?> get props => [userBookId, page];
}

final class LibraryStatusChanged extends LibraryEvent {
  const LibraryStatusChanged({required this.userBookId, required this.status});
  final String userBookId;
  final ReadingStatus status;

  @override
  List<Object?> get props => [userBookId, status];
}

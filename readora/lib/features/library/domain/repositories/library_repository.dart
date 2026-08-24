import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';

abstract interface class LibraryRepository {
  /// Live view of the local database. Emits immediately and on every change,
  /// whether that change came from this device or from a sync pull.
  Stream<List<LibraryBook>> watchLibrary({ReadingStatus? status});

  Stream<List<LibraryBook>> watchCurrentlyReading();

  /// Searches Google Books (with an Open Library fallback) through the
  /// `book-search` Edge Function. Requires a connection — this is the one
  /// place in the library flow that does.
  Future<List<BookEntity>> searchCatalogue({String? query, String? isbn});

  /// Adds a catalogue result to the reader's library. Writes locally first and
  /// returns straight away; the upload is queued.
  Future<LibraryBook> addToLibrary(BookEntity book, {ReadingStatus status});

  Future<void> updateProgress(String userBookId, int page);

  Future<void> setStatus(String userBookId, ReadingStatus status);

  Future<void> rate(String userBookId, {required int halfStars, String? review});

  /// Soft delete. The tombstone reaches other devices on the next pull.
  Future<void> removeFromLibrary(String userBookId);
}

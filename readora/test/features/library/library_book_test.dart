import 'package:flutter_test/flutter_test.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';

/// Sample of the testing conventions:
///   * domain entities are tested as pure functions, no mocks needed
///   * every branch that could show a reader a wrong number gets a case
void main() {
  BookEntity book({int? pages}) => BookEntity()
    ..uuid = 'book-1'
    ..title = 'Atomic Habits'
    ..authors = ['James Clear']
    ..pageCount = pages;

  UserBookEntity userBook({int page = 0, int? override}) => UserBookEntity()
    ..uuid = 'ub-1'
    ..userId = 'local'
    ..bookUuid = 'book-1'
    ..currentPage = page
    ..pageCountOverride = override
    ..createdAt = DateTime(2026);

  group('LibraryBook.progress', () {
    test('is zero when the page count is unknown', () {
      final subject = LibraryBook.from(userBook(page: 100), book());
      expect(subject.progress, 0);
      expect(subject.pagesLeft, isNull);
    });

    test('is the ratio of current page to total', () {
      final subject = LibraryBook.from(userBook(page: 142), book(pages: 320));
      expect(subject.progress, closeTo(0.44, 0.01));
      expect(subject.pagesLeft, 178);
    });

    test('never exceeds 1 when the reader overshoots the page count', () {
      final subject = LibraryBook.from(userBook(page: 400), book(pages: 320));
      expect(subject.progress, 1.0);
      expect(subject.pagesLeft, 0);
    });

    test('prefers the reader edition page count over the catalogue value', () {
      final subject = LibraryBook.from(
        userBook(page: 50, override: 100),
        book(pages: 320),
      );
      expect(subject.progress, 0.5);
    });
  });

  group('LibraryBook.stars', () {
    test('converts half-star steps back to stars', () {
      final entity = userBook()..rating = 9;
      expect(LibraryBook.from(entity, book()).stars, 4.5);
    });

    test('is null when unrated', () {
      expect(LibraryBook.from(userBook(), book()).stars, isNull);
    });
  });

  group('authorLine', () {
    test('falls back rather than showing an empty line', () {
      final b = book()..authors = [];
      expect(LibraryBook.from(userBook(), b).authorLine, 'Unknown author');
    });
  });
}

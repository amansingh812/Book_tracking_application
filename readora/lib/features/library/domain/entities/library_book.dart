import 'package:equatable/equatable.dart';
import 'package:readora/features/library/data/models/library_models.dart';

/// A book as the UI thinks about it: the shared metadata joined with this
/// reader's own state. Built in the data layer so no widget ever has to hold
/// two objects and remember how they relate.
class LibraryBook extends Equatable {
  const LibraryBook({
    required this.id,
    required this.bookId,
    required this.title,
    required this.authors,
    required this.status,
    required this.currentPage,
    this.subtitle,
    this.coverUrl,
    this.pageCount,
    this.rating,
    this.isFavorite = false,
    this.notesCount = 0,
    this.startedAt,
    this.finishedAt,
  });

  factory LibraryBook.from(UserBookEntity ub, BookEntity? book) => LibraryBook(
        id: ub.uuid,
        bookId: ub.bookUuid,
        title: book?.title ?? 'Unknown book',
        subtitle: book?.subtitle,
        authors: book?.authors ?? const [],
        coverUrl: book?.coverUrl,
        pageCount: ub.pageCountOverride ?? book?.pageCount,
        status: ub.status,
        currentPage: ub.currentPage,
        rating: ub.rating,
        isFavorite: ub.isFavorite,
        notesCount: ub.notesCount,
        startedAt: ub.startedAt,
        finishedAt: ub.finishedAt,
      );

  final String id;
  final String bookId;
  final String title;
  final String? subtitle;
  final List<String> authors;
  final String? coverUrl;
  final int? pageCount;
  final ReadingStatus status;
  final int currentPage;
  final int? rating;
  final bool isFavorite;
  final int notesCount;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  String get authorLine => authors.isEmpty ? 'Unknown author' : authors.join(', ');

  /// 0..1. Returns 0 when the page count is unknown rather than guessing —
  /// a fake progress bar is worse than none.
  double get progress {
    final total = pageCount ?? 0;
    if (total <= 0) return 0;
    return (currentPage / total).clamp(0.0, 1.0);
  }

  int? get pagesLeft {
    final total = pageCount;
    if (total == null) return null;
    return (total - currentPage).clamp(0, total);
  }

  double? get stars => rating == null ? null : rating! / 2;

  @override
  List<Object?> get props => [
        id, bookId, title, subtitle, authors, coverUrl, pageCount,
        status, currentPage, rating, isFavorite, notesCount, startedAt, finishedAt,
      ];
}

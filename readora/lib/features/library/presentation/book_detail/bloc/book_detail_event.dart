part of 'book_detail_bloc.dart';

sealed class BookDetailEvent extends Equatable {
  const BookDetailEvent();
  @override
  List<Object?> get props => [];
}

final class BookDetailStarted extends BookDetailEvent {
  const BookDetailStarted(this.userBookId);
  final String userBookId;
  @override
  List<Object?> get props => [userBookId];
}

final class BookDetailRated extends BookDetailEvent {
  const BookDetailRated(this.halfStars, {this.review});
  final int halfStars;
  final String? review;
  @override
  List<Object?> get props => [halfStars, review];
}

final class BookDetailFavoriteToggled extends BookDetailEvent {
  const BookDetailFavoriteToggled();
}

final class BookDetailStatusChanged extends BookDetailEvent {
  const BookDetailStatusChanged(this.status);
  final ReadingStatus status;
  @override
  List<Object?> get props => [status];
}

final class BookDetailPageCountOverridden extends BookDetailEvent {
  const BookDetailPageCountOverridden(this.pageCount);
  final int? pageCount;
  @override
  List<Object?> get props => [pageCount];
}

final class BookDetailRemoved extends BookDetailEvent {
  const BookDetailRemoved();
}

// Internal event — fired by the Isar stream subscription.
final class _BookUpdated extends BookDetailEvent {
  const _BookUpdated(this.book);
  final LibraryBook? book;
  @override
  List<Object?> get props => [book];
}

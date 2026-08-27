import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/core/error/failure.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';

part 'book_detail_event.dart';
part 'book_detail_state.dart';

class BookDetailBloc extends Bloc<BookDetailEvent, BookDetailState> {
  BookDetailBloc(this._repo) : super(const BookDetailLoading()) {
    on<BookDetailStarted>(_onStarted);
    on<BookDetailRated>(_onRated);
    on<BookDetailFavoriteToggled>(_onFavoriteToggled);
    on<BookDetailStatusChanged>(_onStatusChanged);
    on<BookDetailPageCountOverridden>(_onPageCountOverridden);
    on<BookDetailRemoved>(_onRemoved);
    on<_BookUpdated>(_onBookUpdated);
  }

  final LibraryRepository _repo;
  StreamSubscription<LibraryBook?>? _sub;
  String? _userBookId;

  void _onStarted(BookDetailStarted event, Emitter<BookDetailState> emit) {
    _userBookId = event.userBookId;
    _sub?.cancel();
    emit(const BookDetailLoading());
    _sub = _repo.watchBook(event.userBookId).listen(
          (book) => add(_BookUpdated(book)),
        );
  }

  void _onBookUpdated(_BookUpdated event, Emitter<BookDetailState> emit) {
    emit(BookDetailLoaded(book: event.book));
  }

  Future<void> _onRated(
      BookDetailRated event, Emitter<BookDetailState> emit) async {
    if (_userBookId == null) return;
    final current = state;
    if (current is BookDetailLoaded) {
      emit(current.copyWith(isSaving: true));
    }
    try {
      await _repo.rate(_userBookId!,
          halfStars: event.halfStars, review: event.review);
    } on Failure catch (f) {
      if (state is BookDetailLoaded) {
        emit((state as BookDetailLoaded)
            .copyWith(isSaving: false, failure: f));
      }
    }
  }

  Future<void> _onFavoriteToggled(
      BookDetailFavoriteToggled event, Emitter<BookDetailState> emit) async {
    if (_userBookId == null) return;
    // Optimistic: flip locally shown in stream update; errors revert it.
    try {
      await _repo.toggleFavorite(_userBookId!);
    } on Failure catch (f) {
      if (state is BookDetailLoaded) {
        emit((state as BookDetailLoaded).copyWith(failure: f));
      }
    }
  }

  Future<void> _onStatusChanged(
      BookDetailStatusChanged event, Emitter<BookDetailState> emit) async {
    if (_userBookId == null) return;
    try {
      await _repo.setStatus(_userBookId!, event.status);
    } on Failure catch (f) {
      if (state is BookDetailLoaded) {
        emit((state as BookDetailLoaded).copyWith(failure: f));
      }
    }
  }

  Future<void> _onPageCountOverridden(
      BookDetailPageCountOverridden event, Emitter<BookDetailState> emit) async {
    if (_userBookId == null) return;
    final book = (state is BookDetailLoaded)
        ? (state as BookDetailLoaded).book
        : null;
    // Guard: override must be >= currentPage
    if (event.pageCount != null &&
        book != null &&
        event.pageCount! < book.currentPage) {
      if (state is BookDetailLoaded) {
        emit((state as BookDetailLoaded).copyWith(
          failure: const ValidationFailure(
              "Total pages can't be less than your current page."),
        ));
      }
      return;
    }
    try {
      await _repo.setPageCountOverride(_userBookId!, event.pageCount);
    } on Failure catch (f) {
      if (state is BookDetailLoaded) {
        emit((state as BookDetailLoaded).copyWith(failure: f));
      }
    }
  }

  Future<void> _onRemoved(
      BookDetailRemoved event, Emitter<BookDetailState> emit) async {
    if (_userBookId == null) return;
    try {
      await _repo.removeFromLibrary(_userBookId!);
      emit(const BookDetailRemoved_());
    } on Failure catch (f) {
      if (state is BookDetailLoaded) {
        emit((state as BookDetailLoaded).copyWith(failure: f));
      }
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

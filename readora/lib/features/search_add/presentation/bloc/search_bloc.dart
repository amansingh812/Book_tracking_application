import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/core/error/error_mapper.dart';
import 'package:readora/core/error/failure.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

/// A thin ISBN detection heuristic: 10 or 13 consecutive digits.
final _isbnRe = RegExp(r'^\d{10}$|^\d{13}$');

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required LibraryRepository repository})
      : _repository = repository,
        super(const SearchState()) {
    on<SearchStarted>(_onStarted);
    on<SearchQueryChanged>(_onQueryChanged, transformer: restartable());
    on<_SearchLibraryUpdated>(_onLibraryUpdated);
    on<SearchBookAdded>(_onBookAdded, transformer: sequential());
    on<SearchCleared>(_onCleared);
  }

  final LibraryRepository _repository;
  StreamSubscription<dynamic>? _librarySub;

  Future<void> _onStarted(SearchStarted event, Emitter<SearchState> emit) async {
    _librarySub = _repository.watchLibrary().listen((books) {
      add(_SearchLibraryUpdated({for (final b in books) b.bookId}));
    });
  }

  Future<void> _onQueryChanged(
      SearchQueryChanged event, Emitter<SearchState> emit) async {
    final q = event.query.trim();
    if (q.isEmpty) {
      emit(state.copyWith(view: SearchView.idle, results: [], query: ''));
      return;
    }
    emit(state.copyWith(view: SearchView.searching, query: q, clearFailure: true));

    // Debounce — wait 350 ms before hitting the network.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (emit.isDone) return;

    try {
      final results = _isbnRe.hasMatch(q)
          ? await _repository.searchCatalogue(isbn: q)
          : await _repository.searchCatalogue(query: q);

      emit(state.copyWith(
        view: results.isEmpty ? SearchView.empty : SearchView.results,
        results: results,
      ));
    } catch (error) {
      emit(state.copyWith(view: SearchView.error, failure: mapError(error)));
    }
  }

  void _onLibraryUpdated(_SearchLibraryUpdated event, Emitter<SearchState> emit) {
    emit(state.copyWith(libraryBookIds: event.bookIds));
  }

  Future<void> _onBookAdded(SearchBookAdded event, Emitter<SearchState> emit) async {
    emit(state.copyWith(addingBookId: event.book.uuid, clearMessage: true));
    try {
      final book = await _repository.addToLibrary(event.book, status: event.status);
      emit(state.copyWith(
        clearAdding: true,
        addedMessage: '"${book.title}" added to your library.',
      ));
    } catch (error) {
      emit(state.copyWith(clearAdding: true, failure: mapError(error)));
    }
  }

  void _onCleared(SearchCleared event, Emitter<SearchState> emit) {
    emit(const SearchState());
  }

  @override
  Future<void> close() async {
    await _librarySub?.cancel();
    return super.close();
  }
}

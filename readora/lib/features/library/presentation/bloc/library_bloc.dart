import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/core/error/error_mapper.dart';
import 'package:readora/core/error/failure.dart';
import 'package:readora/features/library/data/models/library_models.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/library/domain/repositories/library_repository.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({required LibraryRepository repository})
      : _repository = repository,
        super(const LibraryState()) {
    on<LibraryStarted>(_onStarted);
    // restartable: a new filter cancels the previous subscription instead of
    // leaving two Isar streams feeding the same bloc.
    on<LibraryFilterChanged>(_onFilterChanged, transformer: restartable());
    on<LibraryBooksUpdated>(_onBooksUpdated);
    on<LibraryProgressUpdated>(_onProgressUpdated, transformer: sequential());
    on<LibraryStatusChanged>(_onStatusChanged, transformer: sequential());
  }

  final LibraryRepository _repository;
  StreamSubscription<List<LibraryBook>>? _sub;

  Future<void> _onStarted(LibraryStarted event, Emitter<LibraryState> emit) async {
    await _subscribe(state.filter);
  }

  Future<void> _onFilterChanged(
    LibraryFilterChanged event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(filter: event.status, clearFilter: event.status == null));
    await _subscribe(event.status);
  }

  Future<void> _subscribe(ReadingStatus? status) async {
    await _sub?.cancel();
    _sub = _repository
        .watchLibrary(status: status)
        .listen((books) => add(LibraryBooksUpdated(books)));
  }

  void _onBooksUpdated(LibraryBooksUpdated event, Emitter<LibraryState> emit) {
    emit(state.copyWith(view: LibraryStatusView.ready, books: event.books));
  }

  Future<void> _onProgressUpdated(
    LibraryProgressUpdated event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      // Local write; the Isar stream pushes the new state back to us.
      await _repository.updateProgress(event.userBookId, event.page);
    } catch (error) {
      emit(state.copyWith(failure: mapError(error)));
    }
  }

  Future<void> _onStatusChanged(
    LibraryStatusChanged event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.setStatus(event.userBookId, event.status);
    } catch (error) {
      emit(state.copyWith(failure: mapError(error)));
    }
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}

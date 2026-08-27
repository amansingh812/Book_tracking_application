import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/shelves/domain/entities/shelf.dart';
import 'package:readora/features/shelves/domain/repositories/shelf_repository.dart';

part 'shelves_event.dart';
part 'shelves_state.dart';

class ShelvesBloc extends Bloc<ShelvesEvent, ShelvesState> {
  ShelvesBloc(this._repo) : super(const ShelvesLoading()) {
    on<ShelvesStarted>(_onStarted);
    on<ShelfCreated>(_onCreated);
    on<ShelfRenamed>(_onRenamed);
    on<ShelfDeleted>(_onDeleted);
    on<_ShelvesUpdated>(_onUpdated);
  }

  final ShelfRepository _repo;
  StreamSubscription<List<Shelf>>? _sub;

  void _onStarted(ShelvesStarted event, Emitter<ShelvesState> emit) {
    _sub?.cancel();
    _sub = _repo.watchShelves().listen((s) => add(_ShelvesUpdated(s)));
  }

  void _onUpdated(_ShelvesUpdated event, Emitter<ShelvesState> emit) {
    emit(ShelvesLoaded(shelves: event.shelves));
  }

  Future<void> _onCreated(ShelfCreated event, Emitter<ShelvesState> emit) async {
    try {
      await _repo.createShelf(event.name);
    } catch (_) {}
  }

  Future<void> _onRenamed(ShelfRenamed event, Emitter<ShelvesState> emit) async {
    try {
      await _repo.renameShelf(event.shelfId, event.newName);
    } catch (_) {}
  }

  Future<void> _onDeleted(ShelfDeleted event, Emitter<ShelvesState> emit) async {
    try {
      await _repo.deleteShelf(event.shelfId);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

// ── ShelfDetailBloc ──────────────────────────────────────────────────────────

class ShelfDetailBloc extends Bloc<ShelfDetailEvent, ShelfDetailState> {
  ShelfDetailBloc(this._repo) : super(const ShelfDetailLoading()) {
    on<ShelfDetailStarted>(_onStarted);
    on<ShelfDetailBookRemoved>(_onRemoved);
    on<_ShelfDetailUpdated>(_onUpdated);
  }

  final ShelfRepository _repo;
  StreamSubscription<List<LibraryBook>>? _sub;
  String? _shelfId;

  void _onStarted(ShelfDetailStarted event, Emitter<ShelfDetailState> emit) {
    _shelfId = event.shelfId;
    _sub?.cancel();
    _sub = _repo
        .watchShelfBooks(event.shelfId)
        .listen((books) => add(_ShelfDetailUpdated(books)));
  }

  void _onUpdated(_ShelfDetailUpdated event, Emitter<ShelfDetailState> emit) {
    emit(ShelfDetailLoaded(books: event.books));
  }

  Future<void> _onRemoved(ShelfDetailBookRemoved event, Emitter<ShelfDetailState> emit) async {
    if (_shelfId == null) return;
    try {
      await _repo.removeBookFromShelf(_shelfId!, event.userBookId);
    } catch (_) {}
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

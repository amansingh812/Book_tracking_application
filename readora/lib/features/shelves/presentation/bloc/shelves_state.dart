part of 'shelves_bloc.dart';

sealed class ShelvesState extends Equatable {
  const ShelvesState();
  @override
  List<Object?> get props => [];
}

class ShelvesLoading extends ShelvesState {
  const ShelvesLoading();
}

class ShelvesLoaded extends ShelvesState {
  const ShelvesLoaded({required this.shelves});
  final List<Shelf> shelves;
  @override
  List<Object?> get props => [shelves];
}

// ── ShelfDetail states ────────────────────────────────────────────────────────

sealed class ShelfDetailState extends Equatable {
  const ShelfDetailState();
  @override
  List<Object?> get props => [];
}

class ShelfDetailLoading extends ShelfDetailState {
  const ShelfDetailLoading();
}

class ShelfDetailLoaded extends ShelfDetailState {
  const ShelfDetailLoaded({required this.books});
  final List<LibraryBook> books;
  @override
  List<Object?> get props => [books];
}

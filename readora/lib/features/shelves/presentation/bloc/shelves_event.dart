part of 'shelves_bloc.dart';

sealed class ShelvesEvent extends Equatable {
  const ShelvesEvent();
  @override
  List<Object?> get props => [];
}

class ShelvesStarted extends ShelvesEvent {
  const ShelvesStarted();
}

class ShelfCreated extends ShelvesEvent {
  const ShelfCreated(this.name);
  final String name;
  @override
  List<Object?> get props => [name];
}

class ShelfRenamed extends ShelvesEvent {
  const ShelfRenamed(this.shelfId, this.newName);
  final String shelfId;
  final String newName;
  @override
  List<Object?> get props => [shelfId, newName];
}

class ShelfDeleted extends ShelvesEvent {
  const ShelfDeleted(this.shelfId);
  final String shelfId;
  @override
  List<Object?> get props => [shelfId];
}

class _ShelvesUpdated extends ShelvesEvent {
  const _ShelvesUpdated(this.shelves);
  final List<Shelf> shelves;
  @override
  List<Object?> get props => [shelves];
}

// ── ShelfDetail events ───────────────────────────────────────────────────────

sealed class ShelfDetailEvent extends Equatable {
  const ShelfDetailEvent();
  @override
  List<Object?> get props => [];
}

class ShelfDetailStarted extends ShelfDetailEvent {
  const ShelfDetailStarted(this.shelfId);
  final String shelfId;
  @override
  List<Object?> get props => [shelfId];
}

class ShelfDetailBookRemoved extends ShelfDetailEvent {
  const ShelfDetailBookRemoved(this.userBookId);
  final String userBookId;
  @override
  List<Object?> get props => [userBookId];
}

class _ShelfDetailUpdated extends ShelfDetailEvent {
  const _ShelfDetailUpdated(this.books);
  final List<LibraryBook> books;
  @override
  List<Object?> get props => [books];
}

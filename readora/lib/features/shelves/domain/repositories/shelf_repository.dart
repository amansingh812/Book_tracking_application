import 'package:readora/features/library/domain/entities/library_book.dart';
import 'package:readora/features/shelves/domain/entities/shelf.dart';

abstract interface class ShelfRepository {
  Stream<List<Shelf>> watchShelves();
  Stream<List<LibraryBook>> watchShelfBooks(String shelfId);
  Stream<List<String>> watchBookShelfIds(String userBookId);
  Future<Shelf> createShelf(String name);
  Future<void> renameShelf(String shelfId, String name);
  Future<void> deleteShelf(String shelfId);
  Future<void> addBookToShelf(String shelfId, String userBookId);
  Future<void> removeBookFromShelf(String shelfId, String userBookId);
}

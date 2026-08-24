import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/library/data/models/library_models.dart';

/// `public.books` — pull only. The client never writes book metadata directly;
/// the `book-search` Edge Function owns that table.
class BooksSyncTable implements SyncableTable {
  @override
  String get table => 'books';

  @override
  String get columns =>
      'id, title, subtitle, authors, description, publisher, published_date, '
      'page_count, categories, language, cover_url, isbn10, isbn13, updated_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(BookEntity.fromJson).toList();
    await isar.writeTxn(() => isar.bookEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.bookEntitys.deleteAllByUuid(uuids));
  }
}

/// `public.user_books` — the user's library. Pushed and pulled.
class UserBooksSyncTable implements SyncableTable {
  @override
  String get table => 'user_books';

  @override
  String get columns =>
      'id, user_id, book_id, status, current_page, page_count_override, '
      'started_at, finished_at, rating, review, is_favorite, tbr_priority, '
      'notes_count, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(UserBookEntity.fromJson).toList();
    await isar.writeTxn(() => isar.userBookEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.userBookEntitys.deleteAllByUuid(uuids));
  }
}

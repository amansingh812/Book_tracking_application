import 'package:isar_community/isar.dart';

part 'shelf_models.g.dart';

// ── Shelf ─────────────────────────────────────────────────────────────────

/// Local mirror of `public.shelves`. Custom TBR shelf created by the user.
@collection
class ShelfEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  late String name;
  int sortOrder = 0;

  late DateTime createdAt;
  DateTime? updatedAt;

  static ShelfEntity fromJson(Map<String, dynamic> json) => ShelfEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..name = json['name'] as String? ?? ''
    ..sortOrder = json['sort_order'] as int? ?? 0
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'name': name,
        'sort_order': sortOrder,
        'created_at': createdAt.toIso8601String(),
      };
}

// ── Shelf Item ────────────────────────────────────────────────────────────

/// Local mirror of `public.shelf_items`. Join between shelf and user_book.
@collection
class ShelfItemEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(composite: [CompositeIndex('shelfUuid')], unique: true, replace: true)
  late String userBookUuid;

  late String shelfUuid;

  late DateTime addedAt;
  late DateTime createdAt;

  static ShelfItemEntity fromJson(Map<String, dynamic> json) => ShelfItemEntity()
    ..uuid = json['id'] as String
    ..userBookUuid = json['user_book_id'] as String
    ..shelfUuid = json['shelf_id'] as String
    ..addedAt =
        DateTime.tryParse(json['added_at'] as String? ?? '') ?? DateTime.now()
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now();

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_book_id': userBookUuid,
        'shelf_id': shelfUuid,
        'added_at': addedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

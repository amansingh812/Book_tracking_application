import 'package:isar_community/isar.dart';

part 'library_models.g.dart';

/// Local mirror of `public.books`. Shared metadata, not user data.
@collection
class BookEntity {
  Id id = Isar.autoIncrement;

  /// Server uuid. Every synced collection carries one of these.
  @Index(unique: true, replace: true)
  late String uuid;

  late String title;
  String? subtitle;
  List<String> authors = const [];
  String? description;
  String? publisher;
  String? publishedDate;
  int? pageCount;
  List<String> categories = const [];
  String? language;
  String? coverUrl;
  String? isbn10;
  String? isbn13;
  DateTime? updatedAt;

  static BookEntity fromJson(Map<String, dynamic> json) => BookEntity()
    ..uuid = json['id'] as String
    ..title = json['title'] as String? ?? 'Untitled'
    ..subtitle = json['subtitle'] as String?
    ..authors = (json['authors'] as List?)?.cast<String>() ?? const []
    ..description = json['description'] as String?
    ..publisher = json['publisher'] as String?
    ..publishedDate = json['published_date'] as String?
    ..pageCount = json['page_count'] as int?
    ..categories = (json['categories'] as List?)?.cast<String>() ?? const []
    ..language = json['language'] as String?
    ..coverUrl = json['cover_url'] as String?
    ..isbn10 = json['isbn10'] as String?
    ..isbn13 = json['isbn13'] as String?
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');
}

enum ReadingStatus { wantToRead, reading, finished, dnf, paused }

extension ReadingStatusWire on ReadingStatus {
  /// Postgres enum values are snake_case; Dart enums are camelCase.
  String get wire => switch (this) {
        ReadingStatus.wantToRead => 'want_to_read',
        ReadingStatus.reading => 'reading',
        ReadingStatus.finished => 'finished',
        ReadingStatus.dnf => 'dnf',
        ReadingStatus.paused => 'paused',
      };

  static ReadingStatus parse(String? value) => switch (value) {
        'reading' => ReadingStatus.reading,
        'finished' => ReadingStatus.finished,
        'dnf' => ReadingStatus.dnf,
        'paused' => ReadingStatus.paused,
        _ => ReadingStatus.wantToRead,
      };

  String get label => switch (this) {
        ReadingStatus.wantToRead => 'Want to read',
        ReadingStatus.reading => 'Reading',
        ReadingStatus.finished => 'Finished',
        ReadingStatus.dnf => 'Did not finish',
        ReadingStatus.paused => 'Paused',
      };
}

/// Local mirror of `public.user_books`.
@collection
class UserBookEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  /// Real Supabase uid, or `local` while in guest mode.
  @Index()
  late String userId;

  @Index()
  late String bookUuid;

  @enumerated
  ReadingStatus status = ReadingStatus.wantToRead;

  int currentPage = 0;
  int? pageCountOverride;
  DateTime? startedAt;
  DateTime? finishedAt;

  /// Half-star steps, 1..10.
  int? rating;
  String? review;
  bool isFavorite = false;
  int? tbrPriority;
  int notesCount = 0;

  late DateTime createdAt;
  DateTime? updatedAt;

  static UserBookEntity fromJson(Map<String, dynamic> json) => UserBookEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..bookUuid = json['book_id'] as String
    ..status = ReadingStatusWire.parse(json['status'] as String?)
    ..currentPage = json['current_page'] as int? ?? 0
    ..pageCountOverride = json['page_count_override'] as int?
    ..startedAt = DateTime.tryParse(json['started_at'] as String? ?? '')
    ..finishedAt = DateTime.tryParse(json['finished_at'] as String? ?? '')
    ..rating = json['rating'] as int?
    ..review = json['review'] as String?
    ..isFavorite = json['is_favorite'] as bool? ?? false
    ..tbrPriority = json['tbr_priority'] as int?
    ..notesCount = json['notes_count'] as int? ?? 0
    ..createdAt = DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'book_id': bookUuid,
        'status': status.wire,
        'current_page': currentPage,
        'page_count_override': pageCountOverride,
        'started_at': startedAt?.toIso8601String(),
        'finished_at': finishedAt?.toIso8601String(),
        'rating': rating,
        'review': review,
        'is_favorite': isFavorite,
        'tbr_priority': tbrPriority,
        'created_at': createdAt.toIso8601String(),
      };
}

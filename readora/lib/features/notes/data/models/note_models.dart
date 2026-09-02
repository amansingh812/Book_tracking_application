import 'package:isar_community/isar.dart';

part 'note_models.g.dart';

enum NoteKind { note, highlight }

extension NoteKindWire on NoteKind {
  String get wire => name;
  static NoteKind parse(String? v) =>
      NoteKind.values.firstWhere((e) => e.name == v, orElse: () => NoteKind.note);
}

/// Local mirror of `public.notes`. The reader's own words — the data every AI
/// feature (chat, quiz, flashcards) is built from.
@collection
class NoteEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  late String userBookUuid;

  @enumerated
  NoteKind kind = NoteKind.note;

  late String content;

  int? page;
  String? chapter;
  String? color;

  List<String> tags = const [];

  bool isFavorite = false;

  late DateTime createdAt;
  DateTime? updatedAt;

  static NoteEntity fromJson(Map<String, dynamic> json) => NoteEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..userBookUuid = json['user_book_id'] as String
    ..kind = NoteKindWire.parse(json['kind'] as String?)
    ..content = json['content'] as String? ?? ''
    ..page = json['page'] as int?
    ..chapter = json['chapter'] as String?
    ..color = json['color'] as String?
    ..tags = (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const []
    ..isFavorite = json['is_favorite'] as bool? ?? false
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'user_book_id': userBookUuid,
        'kind': kind.wire,
        'content': content,
        'page': page,
        'chapter': chapter,
        'color': color,
        'tags': tags,
        'is_favorite': isFavorite,
        'created_at': createdAt.toIso8601String(),
      };
}

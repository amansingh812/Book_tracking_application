import 'package:isar_community/isar.dart';

part 'flashcard_models.g.dart';

/// Local mirror of `public.flashcards`. SM-2-lite spaced repetition fields.
@collection
class FlashcardEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  String? userBookUuid;

  String? noteUuid;

  late String front;
  late String back;

  double ease = 2.50;
  int intervalDays = 0;
  int reps = 0;
  int lapses = 0;

  @Index()
  late DateTime dueAt;

  late DateTime createdAt;
  DateTime? updatedAt;

  static FlashcardEntity fromJson(Map<String, dynamic> json) => FlashcardEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..userBookUuid = json['user_book_id'] as String?
    ..noteUuid = json['note_id'] as String?
    ..front = json['front'] as String? ?? ''
    ..back = json['back'] as String? ?? ''
    ..ease = (json['ease'] as num?)?.toDouble() ?? 2.50
    ..intervalDays = json['interval_days'] as int? ?? 0
    ..reps = json['reps'] as int? ?? 0
    ..lapses = json['lapses'] as int? ?? 0
    ..dueAt = DateTime.tryParse(json['due_at'] as String? ?? '') ?? DateTime.now()
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'user_book_id': userBookUuid,
        'note_id': noteUuid,
        'front': front,
        'back': back,
        'ease': ease,
        'interval_days': intervalDays,
        'reps': reps,
        'lapses': lapses,
        'due_at': dueAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

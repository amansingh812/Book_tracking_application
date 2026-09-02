import 'dart:convert';

import 'package:isar_community/isar.dart';

part 'quiz_models.g.dart';

/// Local mirror of `public.quizzes`.
@collection
class QuizEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  late String userBookUuid;

  String? title;
  String generatedFrom = 'notes';

  late DateTime createdAt;
  DateTime? updatedAt;

  static QuizEntity fromJson(Map<String, dynamic> json) => QuizEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..userBookUuid = json['user_book_id'] as String
    ..title = json['title'] as String?
    ..generatedFrom = json['generated_from'] as String? ?? 'notes'
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'user_book_id': userBookUuid,
        'title': title,
        'generated_from': generatedFrom,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Local mirror of `public.quiz_questions`.
/// 
@collection
class QuizQuestionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  late String quizUuid;

  int position = 0;
  late String prompt;
  List<String> options = const [];
  int? answerIndex;
  String? explanation;

  late DateTime createdAt;
  DateTime? updatedAt;

  static QuizQuestionEntity fromJson(Map<String, dynamic> json) => QuizQuestionEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..quizUuid = json['quiz_id'] as String
    ..position = json['position'] as int? ?? 0
    ..prompt = json['prompt'] as String? ?? ''
    ..options =
        (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const []
    ..answerIndex = json['answer_index'] as int?
    ..explanation = json['explanation'] as String?
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'quiz_id': quizUuid,
        'position': position,
        'prompt': prompt,
        'options': options,
        'answer_index': answerIndex,
        'explanation': explanation,
        'created_at': createdAt.toIso8601String(),
      };
}

/// Local mirror of `public.quiz_attempts`.
@collection
class QuizAttemptEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  late String quizUuid;

  int score = 0;

  /// JSON-encoded `List<int?>` — the chosen option index per question, in
  /// question order. Stored as a string locally; sent as jsonb to Supabase.
  String answersJson = '[]';

  late DateTime takenAt;
  late DateTime createdAt;
  DateTime? updatedAt;

  static QuizAttemptEntity fromJson(Map<String, dynamic> json) => QuizAttemptEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..quizUuid = json['quiz_id'] as String
    ..score = json['score'] as int? ?? 0
    ..answersJson = jsonEncode(json['answers'] is List ? json['answers'] as List : const [])
    ..takenAt = DateTime.tryParse(json['taken_at'] as String? ?? '') ?? DateTime.now()
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  @ignore
  List<dynamic> get answers => jsonDecode(answersJson) as List<dynamic>;

  Map<String, dynamic> toInsertJson({required List<dynamic> answers}) => {
        'id': uuid,
        'user_id': userId,
        'quiz_id': quizUuid,
        'score': score,
        'answers': answers,
        'taken_at': takenAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}

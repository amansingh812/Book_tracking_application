import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/syncable_table.dart';
import 'package:readora/features/quiz/data/models/quiz_models.dart';

class QuizzesSyncTable implements SyncableTable {
  @override
  String get table => 'quizzes';

  @override
  String get columns =>
      'id, user_id, user_book_id, title, generated_from, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(QuizEntity.fromJson).toList();
    await isar.writeTxn(() => isar.quizEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.quizEntitys.deleteAllByUuid(uuids));
  }
}

class QuizQuestionsSyncTable implements SyncableTable {
  @override
  String get table => 'quiz_questions';

  @override
  String get columns =>
      'id, user_id, quiz_id, position, prompt, options, answer_index, explanation, '
      'created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(QuizQuestionEntity.fromJson).toList();
    await isar.writeTxn(() => isar.quizQuestionEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.quizQuestionEntitys.deleteAllByUuid(uuids));
  }
}

class QuizAttemptsSyncTable implements SyncableTable {
  @override
  String get table => 'quiz_attempts';

  @override
  String get columns =>
      'id, user_id, quiz_id, score, answers, taken_at, created_at, updated_at, deleted_at';

  @override
  Future<void> upsertFromServer(Isar isar, List<Map<String, dynamic>> rows) async {
    final entities = rows.map(QuizAttemptEntity.fromJson).toList();
    await isar.writeTxn(() => isar.quizAttemptEntitys.putAllByUuid(entities));
  }

  @override
  Future<void> removeLocal(Isar isar, List<String> uuids) async {
    await isar.writeTxn(() => isar.quizAttemptEntitys.deleteAllByUuid(uuids));
  }
}

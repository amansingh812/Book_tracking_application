import 'dart:async';
import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/quiz/data/models/quiz_models.dart';
import 'package:readora/features/quiz/domain/entities/quiz.dart';
import 'package:readora/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class QuizRepositoryImpl implements QuizRepository {
  QuizRepositoryImpl({
    required Isar isar,
    required Outbox outbox,
    required SyncEngine syncEngine,
    required SupabaseClient supabase,
    required AuthRepository auth,
  })  : _isar = isar,
        _outbox = outbox,
        _sync = syncEngine,
        _supabase = supabase,
        _auth = auth;

  static const _uuid = Uuid();
  final Isar _isar;
  final Outbox _outbox;
  final SyncEngine _sync;
  final SupabaseClient _supabase;
  final AuthRepository _auth;

  String get _userId => _auth.current?.id ?? '__no_session__';

  @override
  Stream<List<Quiz>> watchForBook(String userBookId) {
    return _isar.quizEntitys
        .filter()
        .userIdEqualTo(_userId)
        .userBookUuidEqualTo(userBookId)
        .sortByCreatedAtDesc()
        .watch(fireImmediately: true)
        .asyncMap(_joinQuestions);
  }

  @override
  Stream<List<QuizAttempt>> watchAttempts(String quizId) {
    return _isar.quizAttemptEntitys
        .filter()
        .quizUuidEqualTo(quizId)
        .sortByTakenAtDesc()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toAttempt).toList());
  }

  @override
  Future<Quiz> generate({required String userBookId, int count = 8}) async {
    final Map<String, dynamic> data;
    try {
      final res = await _supabase.functions.invoke(
        'ai-generate',
        body: {'task': 'quiz', 'userBookId': userBookId, 'count': count},
      );
      data = Map<String, dynamic>.from(res.data as Map);
    } on FunctionException catch (e) {
      throw _mapFunctionError(e);
    }

    final result = Map<String, dynamic>.from(data['result'] as Map? ?? {});
    final title = result['title'] as String?;
    final rawQuestions = (result['questions'] as List<dynamic>? ?? const [])
        .cast<Map<dynamic, dynamic>>();

    final now = DateTime.now().toUtc();
    final quiz = QuizEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..userBookUuid = userBookId
      ..title = title
      ..generatedFrom = 'notes'
      ..createdAt = now;

    final questions = <QuizQuestionEntity>[];
    for (var i = 0; i < rawQuestions.length; i++) {
      final q = Map<String, dynamic>.from(rawQuestions[i]);
      questions.add(
        QuizQuestionEntity()
          ..uuid = _uuid.v4()
          ..userId = _userId
          ..quizUuid = quiz.uuid
          ..position = i
          ..prompt = q['prompt'] as String? ?? ''
          ..options =
              (q['options'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList()
          ..answerIndex = q['answerIndex'] as int?
          ..explanation = q['explanation'] as String?
          ..createdAt = now,
      );
    }

    await _isar.writeTxn(() async {
      await _isar.quizEntitys.putByUuid(quiz);
      await _isar.quizQuestionEntitys.putAllByUuid(questions);
    });

    await _outbox.enqueue(
      entity: 'quizzes',
      entityId: quiz.uuid,
      op: OutboxOp.insert,
      payload: quiz.toInsertJson(),
    );
    for (final q in questions) {
      await _outbox.enqueue(
        entity: 'quiz_questions',
        entityId: q.uuid,
        op: OutboxOp.insert,
        payload: q.toInsertJson(),
      );
    }
    unawaited(_sync.syncNow());

    return _toQuiz(quiz, questions);
  }

  @override
  Future<QuizAttempt> submitAttempt({
    required String quizId,
    required List<int?> answers,
  }) async {
    final questions = await _isar.quizQuestionEntitys
        .filter()
        .quizUuidEqualTo(quizId)
        .sortByPosition()
        .findAll();

    var correct = 0;
    for (var i = 0; i < questions.length && i < answers.length; i++) {
      if (questions[i].answerIndex != null && questions[i].answerIndex == answers[i]) {
        correct++;
      }
    }
    final score = questions.isEmpty ? 0 : ((correct / questions.length) * 100).round();

    final now = DateTime.now().toUtc();
    final entity = QuizAttemptEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..quizUuid = quizId
      ..score = score
      ..answersJson = jsonEncode(answers)
      ..takenAt = now
      ..createdAt = now;

    await _isar.writeTxn(() => _isar.quizAttemptEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'quiz_attempts',
      entityId: entity.uuid,
      op: OutboxOp.insert,
      payload: entity.toInsertJson(answers: answers),
    );
    unawaited(_sync.syncNow());

    return _toAttempt(entity);
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  Future<List<Quiz>> _joinQuestions(List<QuizEntity> quizzes) async {
    if (quizzes.isEmpty) return const [];
    final result = <Quiz>[];
    for (final quiz in quizzes) {
      final questions = await _isar.quizQuestionEntitys
          .filter()
          .quizUuidEqualTo(quiz.uuid)
          .sortByPosition()
          .findAll();
      result.add(_toQuiz(quiz, questions));
    }
    return result;
  }

  Quiz _toQuiz(QuizEntity e, List<QuizQuestionEntity> questions) => Quiz(
        id: e.uuid,
        userBookId: e.userBookUuid,
        title: e.title,
        createdAt: e.createdAt,
        questions: questions
            .map((q) => QuizQuestion(
                  id: q.uuid,
                  position: q.position,
                  prompt: q.prompt,
                  options: q.options,
                  answerIndex: q.answerIndex,
                  explanation: q.explanation,
                ))
            .toList(),
      );

  QuizAttempt _toAttempt(QuizAttemptEntity e) => QuizAttempt(
        id: e.uuid,
        quizId: e.quizUuid,
        score: e.score,
        answers: e.answers.map((a) => a as int?).toList(),
        takenAt: e.takenAt,
      );

  QuizGenerationException _mapFunctionError(FunctionException e) {
    var code = 'AI_GENERATE_FAILED';
    var message = 'Could not generate that right now. Try again in a moment.';
    final details = e.details;
    if (details is Map) {
      final error = details['error'];
      if (error is Map) {
        code = error['code']?.toString() ?? code;
        message = error['message']?.toString() ?? message;
      }
    }
    if (code == 'NO_NOTES') {
      message = 'Save a few notes or highlights from this book first — '
          'Readora builds quizzes from your own words.';
    } else if (code == 'AI_QUOTA_EXCEEDED') {
      message = "You've used your free AI interactions for this month. "
          'Upgrade to Readora Plus for unlimited AI features.';
    }
    return QuizGenerationException(code, message);
  }
}

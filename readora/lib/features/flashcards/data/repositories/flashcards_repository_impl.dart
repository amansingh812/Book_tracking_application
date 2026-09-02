import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/flashcards/data/models/flashcard_models.dart';
import 'package:readora/features/flashcards/domain/entities/flashcard.dart';
import 'package:readora/features/flashcards/domain/repositories/flashcards_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FlashcardsRepositoryImpl implements FlashcardsRepository {
  FlashcardsRepositoryImpl({
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
  Stream<List<Flashcard>> watchDue() {
    final now = DateTime.now();
    return _isar.flashcardEntitys
        .filter()
        .userIdEqualTo(_userId)
        .dueAtLessThan(now, include: true)
        .sortByDueAt()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toCard).toList());
  }

  @override
  Stream<List<Flashcard>> watchForBook(String userBookId) {
    return _isar.flashcardEntitys
        .filter()
        .userIdEqualTo(_userId)
        .userBookUuidEqualTo(userBookId)
        .sortByDueAt()
        .watch(fireImmediately: true)
        .map((rows) => rows.map(_toCard).toList());
  }

  @override
  Future<List<Flashcard>> generateFromBook({
    required String userBookId,
    int count = 10,
  }) async {
    final Map<String, dynamic> data;
    try {
      final res = await _supabase.functions.invoke(
        'ai-generate',
        body: {'task': 'flashcards', 'userBookId': userBookId, 'count': count},
      );
      data = Map<String, dynamic>.from(res.data as Map);
    } on FunctionException catch (e) {
      throw _mapFunctionError(e);
    }

    final result = Map<String, dynamic>.from(data['result'] as Map? ?? {});
    final rawCards =
        (result['cards'] as List<dynamic>? ?? const []).cast<Map<dynamic, dynamic>>();

    final now = DateTime.now().toUtc();
    final entities = rawCards.map((c) {
      final card = Map<String, dynamic>.from(c);
      return FlashcardEntity()
        ..uuid = _uuid.v4()
        ..userId = _userId
        ..userBookUuid = userBookId
        ..front = card['front'] as String? ?? ''
        ..back = card['back'] as String? ?? ''
        ..ease = 2.50
        ..intervalDays = 0
        ..reps = 0
        ..lapses = 0
        ..dueAt = now
        ..createdAt = now;
    }).toList();

    await _isar.writeTxn(() => _isar.flashcardEntitys.putAllByUuid(entities));
    for (final e in entities) {
      await _outbox.enqueue(
        entity: 'flashcards',
        entityId: e.uuid,
        op: OutboxOp.insert,
        payload: e.toInsertJson(),
      );
    }
    unawaited(_sync.syncNow());

    return entities.map(_toCard).toList();
  }

  @override
  Future<Flashcard> createFromText({
    required String front,
    required String back,
    String? userBookId,
    String? noteId,
  }) async {
    final now = DateTime.now().toUtc();
    final entity = FlashcardEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..userBookUuid = userBookId
      ..noteUuid = noteId
      ..front = front.trim()
      ..back = back.trim()
      ..ease = 2.50
      ..intervalDays = 0
      ..reps = 0
      ..lapses = 0
      ..dueAt = now
      ..createdAt = now;

    await _isar.writeTxn(() => _isar.flashcardEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'flashcards',
      entityId: entity.uuid,
      op: OutboxOp.insert,
      payload: entity.toInsertJson(),
    );
    unawaited(_sync.syncNow());
    return _toCard(entity);
  }

  @override
  Future<void> grade(String cardId, ReviewGrade grade) async {
    final entity = await _isar.flashcardEntitys.getByUuid(cardId);
    if (entity == null) return;

    final now = DateTime.now().toUtc();
    _applySm2Lite(entity, grade);
    entity.updatedAt = now;

    await _isar.writeTxn(() => _isar.flashcardEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'flashcards',
      entityId: entity.uuid,
      op: OutboxOp.update,
      payload: {
        'ease': entity.ease,
        'interval_days': entity.intervalDays,
        'reps': entity.reps,
        'lapses': entity.lapses,
        'due_at': entity.dueAt.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
    );
    unawaited(_sync.syncNow());
  }

  // ── SM-2-lite ────────────────────────────────────────────────────────────
  //
  // A simplified SM-2: four Anki-style grades instead of a 0-5 quality score.
  // "Again" resets progress and shortens the interval sharply; "Good" is the
  // steady-state path (interval *= ease); "Easy" grows the interval faster and
  // nudges ease up; "Hard" grows it slowly and nudges ease down. Ease is
  // floored at 1.30, matching the DB check constraint.
  void _applySm2Lite(FlashcardEntity e, ReviewGrade grade) {
    switch (grade) {
      case ReviewGrade.again:
        e.lapses += 1;
        e.reps = 0;
        e.ease = (e.ease - 0.20).clamp(1.30, 3.00);
        e.intervalDays = 1;
      case ReviewGrade.hard:
        e.reps += 1;
        e.ease = (e.ease - 0.15).clamp(1.30, 3.00);
        e.intervalDays = e.intervalDays <= 1 ? 1 : (e.intervalDays * 1.2).round();
      case ReviewGrade.good:
        e.reps += 1;
        if (e.reps == 1) {
          e.intervalDays = 1;
        } else if (e.reps == 2) {
          e.intervalDays = 6;
        } else {
          e.intervalDays = (e.intervalDays * e.ease).round().clamp(1, 3650);
        }
      case ReviewGrade.easy:
        e.reps += 1;
        e.ease = (e.ease + 0.15).clamp(1.30, 3.00);
        if (e.reps <= 1) {
          e.intervalDays = 4;
        } else {
          e.intervalDays = (e.intervalDays * e.ease * 1.3).round().clamp(1, 3650);
        }
    }
    e.dueAt = DateTime.now().toUtc().add(Duration(days: e.intervalDays));
  }

  Flashcard _toCard(FlashcardEntity e) => Flashcard(
        id: e.uuid,
        userBookId: e.userBookUuid,
        noteId: e.noteUuid,
        front: e.front,
        back: e.back,
        ease: e.ease,
        intervalDays: e.intervalDays,
        reps: e.reps,
        lapses: e.lapses,
        dueAt: e.dueAt,
      );

  FlashcardGenerationException _mapFunctionError(FunctionException e) {
    var code = 'AI_GENERATE_FAILED';
    var message = 'Could not generate flashcards right now. Try again in a moment.';
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
          'Readora builds flashcards from your own words.';
    } else if (code == 'AI_QUOTA_EXCEEDED') {
      message = "You've used your free AI interactions for this month. "
          'Upgrade to Readora Plus for unlimited AI features.';
    }
    return FlashcardGenerationException(code, message);
  }
}

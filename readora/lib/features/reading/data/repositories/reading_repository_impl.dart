import 'dart:async';

import 'package:isar_community/isar.dart';
import 'package:readora/core/sync/outbox.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/core/sync/sync_models.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:readora/features/reading/data/models/reading_models.dart';
import 'package:readora/features/reading/domain/entities/reading_session.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class ReadingRepositoryImpl implements ReadingRepository {
  ReadingRepositoryImpl({
    required Isar isar,
    required Outbox outbox,
    required SyncEngine syncEngine,
    required AuthRepository auth,
    required SharedPreferences prefs,
  })  : _isar = isar,
        _outbox = outbox,
        _sync = syncEngine,
        _auth = auth,
        _prefs = prefs;

  static const _uuid = Uuid();
  static const _goalKey = 'reading_goal_minutes';

  final Isar _isar;
  final Outbox _outbox;
  final SyncEngine _sync;
  final AuthRepository _auth;
  final SharedPreferences _prefs;

  String get _userId => _auth.current?.id ?? '__no_session__';

  // ── Active session ──────────────────────────────────────────────────────

  @override
  Stream<ReadingSession?> watchActiveSession() {
    return _isar.readingSessionEntitys
        .filter()
        .userIdEqualTo(_userId)
        .endedAtIsNull()
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty ? null : _toSession(rows.first));
  }

  @override
  Future<ReadingSession> startSession(String userBookId) async {
    // End any existing active session first.
    final active = await _isar.readingSessionEntitys
        .filter()
        .userIdEqualTo(_userId)
        .endedAtIsNull()
        .findFirst();
    if (active != null) {
      await _endEntitySession(active, pagesRead: 0);
    }

    final now = DateTime.now().toUtc();
    final entity = ReadingSessionEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..userBookUuid = userBookId
      ..startedAt = now
      ..createdAt = now;

    await _isar.writeTxn(() => _isar.readingSessionEntitys.putByUuid(entity));
    return _toSession(entity);
  }

  @override
  Future<ReadingSession> endSession(String sessionId, {required int pagesRead}) async {
    final entity = await _isar.readingSessionEntitys.getByUuid(sessionId);
    if (entity == null) {
      throw StateError('Session $sessionId not found');
    }
    return _endEntitySession(entity, pagesRead: pagesRead);
  }

  Future<ReadingSession> _endEntitySession(
    ReadingSessionEntity entity, {
    required int pagesRead,
  }) async {
    final now = DateTime.now().toUtc();
    entity
      ..endedAt = now
      ..durationSeconds = now.difference(entity.startedAt).inSeconds
      ..pagesRead = pagesRead;

    await _isar.writeTxn(() => _isar.readingSessionEntitys.putByUuid(entity));
    await _upsertReadingDay(entity.startedAt);
    await _outbox.enqueue(
      entity: 'reading_sessions',
      entityId: entity.uuid,
      op: OutboxOp.insert,
      payload: entity.toInsertJson(),
    );
    unawaited(_sync.syncNow());
    return _toSession(entity);
  }

  // ── Stats ──────────────────────────────────────────────────────────────

  @override
  Stream<ReadingStats> watchStats() {
    return _isar.readingSessionEntitys
        .filter()
        .userIdEqualTo(_userId)
        .watch(fireImmediately: true)
        .asyncMap((_) => _computeStats());
  }

  Future<ReadingStats> _computeStats() async {
    final todayIso = _todayIso();
    final allSessions = await _isar.readingSessionEntitys
        .filter()
        .userIdEqualTo(_userId)
        .endedAtIsNotNull()
        .findAll();

    final todaySeconds = allSessions
        .where((s) => _dateIso(s.startedAt) == todayIso)
        .fold(0, (sum, s) => sum + s.durationSeconds);

    final days = await _isar.readingDayEntitys
        .filter()
        .userIdEqualTo(_userId)
        .sortByDayDateIsoDesc()
        .findAll();

    final streak = _computeStreak(days);

    return ReadingStats(
      totalMinutesToday: todaySeconds ~/ 60,
      currentStreak: streak.$1,
      longestStreak: streak.$2,
      totalBooksRead: 0,
      totalPagesRead: allSessions.fold(0, (s, e) => s + e.pagesRead),
    );
  }

  @override
  Stream<ActiveGoal?> watchTodayGoal() {
    return _isar.readingSessionEntitys
        .filter()
        .userIdEqualTo(_userId)
        .watch(fireImmediately: true)
        .asyncMap((_) => _computeActiveGoal());
  }

  Future<ActiveGoal?> _computeActiveGoal() async {
    final target = _prefs.getInt(_goalKey);
    if (target == null || target <= 0) return null;

    final todayIso = _todayIso();
    final goalEntity = await _isar.goalEntitys
        .filter()
        .userIdEqualTo(_userId)
        .findFirst();

    final effectiveTarget = goalEntity?.target ?? target;

    final todaySessions = await _isar.readingSessionEntitys
        .filter()
        .userIdEqualTo(_userId)
        .endedAtIsNotNull()
        .findAll();

    final todaySeconds = todaySessions
        .where((s) => _dateIso(s.startedAt) == todayIso)
        .fold(0, (sum, s) => sum + s.durationSeconds);

    return ActiveGoal(
      id: goalEntity?.uuid ?? 'local',
      targetMinutes: effectiveTarget,
      minutesToday: todaySeconds ~/ 60,
    );
  }

  // ── Goal management ────────────────────────────────────────────────────

  @override
  Future<void> setDailyGoalMinutes(int minutes) async {
    await _prefs.setInt(_goalKey, minutes);

    final now = DateTime.now().toUtc();
    final existing = await _isar.goalEntitys
        .filter()
        .userIdEqualTo(_userId)
        .findFirst();

    if (existing != null) {
      existing
        ..target = minutes
        ..updatedAt = now;
      await _isar.writeTxn(() => _isar.goalEntitys.putByUuid(existing));
      await _outbox.enqueue(
        entity: 'goals',
        entityId: existing.uuid,
        op: OutboxOp.update,
        payload: {'target': minutes, 'updated_at': now.toIso8601String()},
      );
    } else {
      final entity = GoalEntity()
        ..uuid = _uuid.v4()
        ..userId = _userId
        ..period = GoalPeriod.daily
        ..metric = GoalMetric.minutes
        ..target = minutes
        ..createdAt = now;
      await _isar.writeTxn(() => _isar.goalEntitys.putByUuid(entity));
      await _outbox.enqueue(
        entity: 'goals',
        entityId: entity.uuid,
        op: OutboxOp.insert,
        payload: entity.toInsertJson(),
      );
    }
    unawaited(_sync.syncNow());
  }

  @override
  Future<int?> getDailyGoalMinutes() async {
    final fromPrefs = _prefs.getInt(_goalKey);
    if (fromPrefs != null) return fromPrefs;
    final entity = await _isar.goalEntitys
        .filter()
        .userIdEqualTo(_userId)
        .findFirst();
    return entity?.target;
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  ReadingSession _toSession(ReadingSessionEntity e) => ReadingSession(
        id: e.uuid,
        userBookId: e.userBookUuid,
        startedAt: e.startedAt,
        endedAt: e.endedAt,
        durationSeconds: e.durationSeconds,
        pagesRead: e.pagesRead,
      );

  Future<void> _upsertReadingDay(DateTime date) async {
    final iso = _dateIso(date);
    final existing = await _isar.readingDayEntitys
        .filter()
        .userIdEqualTo(_userId)
        .dayDateIsoEqualTo(iso)
        .findFirst();
    if (existing != null) return;

    final entity = ReadingDayEntity()
      ..uuid = _uuid.v4()
      ..userId = _userId
      ..dayDateIso = iso
      ..createdAt = DateTime.now().toUtc();

    await _isar.writeTxn(() => _isar.readingDayEntitys.putByUuid(entity));
    await _outbox.enqueue(
      entity: 'reading_days',
      entityId: entity.uuid,
      op: OutboxOp.insert,
      payload: entity.toInsertJson(),
    );
  }

  String _todayIso() => _dateIso(DateTime.now());
  String _dateIso(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  (int current, int longest) _computeStreak(List<ReadingDayEntity> days) {
    if (days.isEmpty) return (0, 0);

    final sorted = days.map((d) => d.dayDateIso).toSet().toList()..sort();
    final todayIso = _todayIso();
    final yesterdayIso = _dateIso(DateTime.now().subtract(const Duration(days: 1)));

    // Must have read today or yesterday to have an active streak.
    if (!sorted.contains(todayIso) && !sorted.contains(yesterdayIso)) {
      return (0, _longestStreak(sorted));
    }

    // Walk backwards from today counting consecutive days.
    var current = 0;
    var check = DateTime.now();
    while (true) {
      final iso = _dateIso(check);
      if (!sorted.contains(iso)) break;
      current++;
      check = check.subtract(const Duration(days: 1));
    }

    return (current, _longestStreak(sorted));
  }

  int _longestStreak(List<String> sortedDays) {
    if (sortedDays.isEmpty) return 0;
    var longest = 1;
    var current = 1;
    for (var i = 1; i < sortedDays.length; i++) {
      final prev = DateTime.parse('${sortedDays[i - 1]}T00:00:00');
      final curr = DateTime.parse('${sortedDays[i]}T00:00:00');
      if (curr.difference(prev).inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}

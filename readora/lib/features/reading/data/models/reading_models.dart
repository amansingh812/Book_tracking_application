import 'package:isar_community/isar.dart';

part 'reading_models.g.dart';

// ── Reading Session ────────────────────────────────────────────────────────

/// Local mirror of `public.reading_sessions`. Append-only — no updates.
@collection
class ReadingSessionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @Index()
  late String userBookUuid;

  late DateTime startedAt;
  DateTime? endedAt;
  int durationSeconds = 0;
  int pagesRead = 0;

  /// Device identifier for dedup across devices.
  String deviceId = '';

  late DateTime createdAt;

  static ReadingSessionEntity fromJson(Map<String, dynamic> json) =>
      ReadingSessionEntity()
        ..uuid = json['id'] as String
        ..userId = json['user_id'] as String
        ..userBookUuid = json['user_book_id'] as String
        ..startedAt =
            DateTime.tryParse(json['started_at'] as String? ?? '') ??
                DateTime.now()
        ..endedAt = DateTime.tryParse(json['ended_at'] as String? ?? '')
        ..durationSeconds = json['duration_seconds'] as int? ?? 0
        ..pagesRead = json['pages_read'] as int? ?? 0
        ..deviceId = json['device_id'] as String? ?? ''
        ..createdAt =
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now();

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'user_book_id': userBookUuid,
        'started_at': startedAt.toIso8601String(),
        'ended_at': endedAt?.toIso8601String(),
        'duration_seconds': durationSeconds,
        'pages_read': pagesRead,
        'device_id': deviceId,
        'created_at': createdAt.toIso8601String(),
      };
}

// ── Reading Day ────────────────────────────────────────────────────────────

/// One row per calendar day the user read anything. Powers streak logic.
@collection
class ReadingDayEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index(composite: [CompositeIndex('dayDateIso')], unique: true, replace: true)
  late String userId;

  /// Local date string, e.g. "2026-08-25". Always in device local time.
  late String dayDateIso;

  late DateTime createdAt;

  static ReadingDayEntity fromJson(Map<String, dynamic> json) =>
      ReadingDayEntity()
        ..uuid = json['id'] as String
        ..userId = json['user_id'] as String
        ..dayDateIso = json['day_date'] as String
        ..createdAt =
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
                DateTime.now();

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'day_date': dayDateIso,
        'created_at': createdAt.toIso8601String(),
      };
}

// ── Goal ──────────────────────────────────────────────────────────────────

enum GoalPeriod { daily, yearly }

enum GoalMetric { minutes, pages, books }

extension GoalPeriodWire on GoalPeriod {
  String get wire => name;
  static GoalPeriod parse(String? v) =>
      GoalPeriod.values.firstWhere((e) => e.name == v,
          orElse: () => GoalPeriod.daily);
}

extension GoalMetricWire on GoalMetric {
  String get wire => name;
  static GoalMetric parse(String? v) =>
      GoalMetric.values.firstWhere((e) => e.name == v,
          orElse: () => GoalMetric.minutes);
}

/// Local mirror of `public.goals`. One active goal per (period, metric).
@collection
class GoalEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  late String userId;

  @enumerated
  GoalPeriod period = GoalPeriod.daily;

  @enumerated
  GoalMetric metric = GoalMetric.minutes;

  int target = 20;

  late DateTime createdAt;
  DateTime? updatedAt;

  static GoalEntity fromJson(Map<String, dynamic> json) => GoalEntity()
    ..uuid = json['id'] as String
    ..userId = json['user_id'] as String
    ..period = GoalPeriodWire.parse(json['period'] as String?)
    ..metric = GoalMetricWire.parse(json['metric'] as String?)
    ..target = json['target'] as int? ?? 20
    ..createdAt =
        DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now()
    ..updatedAt = DateTime.tryParse(json['updated_at'] as String? ?? '');

  Map<String, dynamic> toInsertJson() => {
        'id': uuid,
        'user_id': userId,
        'period': period.wire,
        'metric': metric.wire,
        'target': target,
        'created_at': createdAt.toIso8601String(),
      };
}

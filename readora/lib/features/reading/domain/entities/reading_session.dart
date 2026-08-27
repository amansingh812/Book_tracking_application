import 'package:equatable/equatable.dart';

class ReadingSession extends Equatable {
  const ReadingSession({
    required this.id,
    required this.userBookId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
    this.pagesRead = 0,
  });

  final String id;
  final String userBookId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final int pagesRead;

  bool get isActive => endedAt == null;
  Duration get duration => Duration(seconds: durationSeconds);

  @override
  List<Object?> get props => [id, userBookId, startedAt, endedAt, durationSeconds, pagesRead];
}

class ReadingStats extends Equatable {
  const ReadingStats({
    required this.totalMinutesToday,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalBooksRead,
    required this.totalPagesRead,
  });

  final int totalMinutesToday;
  final int currentStreak;
  final int longestStreak;
  final int totalBooksRead;
  final int totalPagesRead;

  @override
  List<Object?> get props => [totalMinutesToday, currentStreak, longestStreak, totalBooksRead, totalPagesRead];
}

class ActiveGoal extends Equatable {
  const ActiveGoal({
    required this.id,
    required this.targetMinutes,
    required this.minutesToday,
  });

  final String id;
  final int targetMinutes;
  final int minutesToday;

  double get progress => targetMinutes > 0 ? (minutesToday / targetMinutes).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => minutesToday >= targetMinutes;
  int get minutesLeft => (targetMinutes - minutesToday).clamp(0, targetMinutes);

  @override
  List<Object?> get props => [id, targetMinutes, minutesToday];
}

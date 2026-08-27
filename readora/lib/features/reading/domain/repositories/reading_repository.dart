import 'package:readora/features/reading/domain/entities/reading_session.dart';

abstract interface class ReadingRepository {
  // Sessions
  Future<ReadingSession> startSession(String userBookId);
  Future<ReadingSession> endSession(String sessionId, {required int pagesRead});
  Stream<ReadingSession?> watchActiveSession();

  // Stats (computed from local data)
  Stream<ReadingStats> watchStats();
  Stream<ActiveGoal?> watchTodayGoal();

  // Goal management
  Future<void> setDailyGoalMinutes(int minutes);
  Future<int?> getDailyGoalMinutes();
}

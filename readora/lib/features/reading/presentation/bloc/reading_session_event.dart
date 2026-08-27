part of 'reading_session_bloc.dart';

sealed class ReadingSessionEvent extends Equatable {
  const ReadingSessionEvent();
  @override
  List<Object?> get props => [];
}

class ReadingSessionStarted extends ReadingSessionEvent {
  const ReadingSessionStarted(this.userBookId);
  final String userBookId;
  @override
  List<Object?> get props => [userBookId];
}

class ReadingSessionEnded extends ReadingSessionEvent {
  const ReadingSessionEnded({this.pagesRead = 0});
  final int pagesRead;
  @override
  List<Object?> get props => [pagesRead];
}

class ReadingSessionTicked extends ReadingSessionEvent {
  const ReadingSessionTicked();
}

class _ActiveSessionLoaded extends ReadingSessionEvent {
  const _ActiveSessionLoaded(this.session);
  final ReadingSession? session;
  @override
  List<Object?> get props => [session];
}

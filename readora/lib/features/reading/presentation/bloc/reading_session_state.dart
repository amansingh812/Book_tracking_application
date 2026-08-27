part of 'reading_session_bloc.dart';

sealed class ReadingSessionState extends Equatable {
  const ReadingSessionState();
  @override
  List<Object?> get props => [];
}

class ReadingSessionIdle extends ReadingSessionState {
  const ReadingSessionIdle();
}

class ReadingSessionLoading extends ReadingSessionState {
  const ReadingSessionLoading();
}

class ReadingSessionActive extends ReadingSessionState {
  const ReadingSessionActive({required this.session, required this.elapsed});
  final ReadingSession session;
  final Duration elapsed;

  ReadingSessionActive copyWith({Duration? elapsed}) =>
      ReadingSessionActive(session: session, elapsed: elapsed ?? this.elapsed);

  @override
  List<Object?> get props => [session, elapsed];
}

class ReadingSessionError extends ReadingSessionState {
  const ReadingSessionError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

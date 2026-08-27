import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/features/reading/domain/entities/reading_session.dart';
import 'package:readora/features/reading/domain/repositories/reading_repository.dart';

part 'reading_session_event.dart';
part 'reading_session_state.dart';

class ReadingSessionBloc extends Bloc<ReadingSessionEvent, ReadingSessionState> {
  ReadingSessionBloc(this._repo) : super(const ReadingSessionIdle()) {
    on<ReadingSessionStarted>(_onStarted);
    on<ReadingSessionEnded>(_onEnded);
    on<ReadingSessionTicked>(_onTicked);
    on<_ActiveSessionLoaded>(_onActiveLoaded);
  }

  final ReadingRepository _repo;
  StreamSubscription<ReadingSession?>? _activeSub;
  Timer? _ticker;

  @override
  Future<void> onTransition(
      Transition<ReadingSessionEvent, ReadingSessionState> transition) {
    super.onTransition(transition);
    return Future.value();
  }

  void _onActiveLoaded(_ActiveSessionLoaded event, Emitter<ReadingSessionState> emit) {
    if (event.session == null) {
      _ticker?.cancel();
      emit(const ReadingSessionIdle());
    } else if (state is! ReadingSessionActive) {
      _startTicker();
      emit(ReadingSessionActive(session: event.session!, elapsed: _elapsed(event.session!)));
    }
  }

  void _onTicked(ReadingSessionTicked event, Emitter<ReadingSessionState> emit) {
    if (state is ReadingSessionActive) {
      final active = state as ReadingSessionActive;
      emit(active.copyWith(elapsed: _elapsed(active.session)));
    }
  }

  Future<void> _onStarted(ReadingSessionStarted event, Emitter<ReadingSessionState> emit) async {
    emit(const ReadingSessionLoading());
    try {
      final session = await _repo.startSession(event.userBookId);
      _activeSub?.cancel();
      _activeSub = _repo.watchActiveSession().listen((s) => add(_ActiveSessionLoaded(s)));
      _startTicker();
      emit(ReadingSessionActive(session: session, elapsed: Duration.zero));
    } catch (e) {
      emit(ReadingSessionError(e.toString()));
    }
  }

  Future<void> _onEnded(ReadingSessionEnded event, Emitter<ReadingSessionState> emit) async {
    final current = state;
    if (current is! ReadingSessionActive) return;
    _ticker?.cancel();
    emit(const ReadingSessionLoading());
    try {
      await _repo.endSession(current.session.id, pagesRead: event.pagesRead);
      emit(const ReadingSessionIdle());
    } catch (e) {
      emit(ReadingSessionError(e.toString()));
    }
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const ReadingSessionTicked());
    });
  }

  Duration _elapsed(ReadingSession session) =>
      DateTime.now().toUtc().difference(session.startedAt);

  @override
  Future<void> close() {
    _ticker?.cancel();
    _activeSub?.cancel();
    return super.close();
  }
}

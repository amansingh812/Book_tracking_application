import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:readora/core/error/error_mapper.dart';
import 'package:readora/core/error/failure.dart';
import 'package:readora/features/auth/domain/entities/app_user.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Owns identity for the whole app. The router listens to this and nothing else
/// decides whether a screen is reachable.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : _repository = repository,
        super(const AuthState()) {
    on<AuthIdentityChanged>(_onIdentityChanged);
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthGuestRequested>(_onGuest);
    on<AuthSignOutRequested>(_onSignOut);

    _sub = _repository.changes.listen((user) => add(AuthIdentityChanged(user)));
    add(AuthIdentityChanged(_repository.current));
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _sub;

  void _onIdentityChanged(AuthIdentityChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    emit(
      state.copyWith(
        status: switch (user) {
          null => AuthStatus.unauthenticated,
          final u when u.isGuest => AuthStatus.guest,
          _ => AuthStatus.authenticated,
        },
        user: user,
        isSubmitting: false,
      ),
    );
  }

  Future<void> _onSignIn(AuthSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final user = await _repository.signIn(email: event.email.trim(), password: event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user, isSubmitting: false));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, failure: mapError(error)));
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final user = await _repository.signUp(
        email: event.email.trim(),
        password: event.password,
        displayName: event.displayName?.trim(),
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user, isSubmitting: false));
    } on AuthFailure catch (failure) {
      // Email-confirmation flows return no session; that is success, not error.
      emit(state.copyWith(isSubmitting: false, infoMessage: failure.message));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, failure: mapError(error)));
    }
  }

  Future<void> _onGuest(AuthGuestRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isSubmitting: true, clearMessages: true));
    try {
      final user = await _repository.continueAsGuest();
      emit(state.copyWith(status: AuthStatus.guest, user: user, isSubmitting: false));
    } catch (error) {
      emit(state.copyWith(isSubmitting: false, failure: mapError(error)));
    }
  }

  Future<void> _onSignOut(AuthSignOutRequested event, Emitter<AuthState> emit) async {
    await _repository.signOut();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }
}

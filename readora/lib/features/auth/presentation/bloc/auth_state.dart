part of 'auth_bloc.dart';

enum AuthStatus {
  /// Still restoring the session from disk — show the splash, not the sign-in
  /// screen, or returning users flicker through a login form they don't need.
  unknown,
  unauthenticated,
  guest,
  authenticated,
}

final class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.isSubmitting = false,
    this.failure,
    this.infoMessage,
  });

  final AuthStatus status;
  final AppUser? user;
  final bool isSubmitting;
  final Failure? failure;

  /// One-shot message, e.g. "Check your inbox to confirm your email".
  final String? infoMessage;

  AuthState copyWith({
    AuthStatus? status,
    AppUser? user,
    bool? isSubmitting,
    Failure? failure,
    String? infoMessage,
    bool clearMessages = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearMessages ? null : failure ?? this.failure,
      infoMessage: clearMessages ? null : infoMessage ?? this.infoMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, isSubmitting, failure, infoMessage];
}

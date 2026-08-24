part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Fired once at startup, and again whenever the Supabase session changes.
final class AuthIdentityChanged extends AuthEvent {
  const AuthIdentityChanged(this.user);
  final AppUser? user;

  @override
  List<Object?> get props => [user];
}

final class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthSignUpRequested extends AuthEvent {
  const AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });
  final String email;
  final String password;
  final String? displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

final class AuthGuestRequested extends AuthEvent {
  const AuthGuestRequested();
}

final class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

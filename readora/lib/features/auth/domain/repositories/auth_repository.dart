import 'package:readora/features/auth/domain/entities/app_user.dart';

/// The domain's view of authentication. The presentation layer never imports
/// `supabase_flutter`; it talks to this.
abstract interface class AuthRepository {
  /// Emits on every identity change, including the initial value.
  Stream<AppUser?> get changes;

  /// Current identity, or null when nobody has started a session yet.
  AppUser? get current;

  /// Creates the account. If the caller is currently a guest (anonymous), the
  /// credentials are attached to that SAME user, so everything already tracked
  /// stays theirs — no migration step exists, by design.
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  Future<AppUser> signIn({required String email, required String password});

  Future<void> sendPasswordReset(String email);

  /// Starts an anonymous Supabase session. The reader gets a real uid and JWT,
  /// so RLS, sync, and the Edge Functions all work without an email address.
  Future<AppUser> continueAsGuest();

  Future<void> signOut();
}

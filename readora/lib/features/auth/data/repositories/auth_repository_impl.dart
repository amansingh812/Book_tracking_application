import 'dart:async';

import 'package:readora/core/error/error_mapper.dart';
import 'package:readora/core/error/failure.dart';
import 'package:readora/core/sync/sync_engine.dart';
import 'package:readora/features/auth/domain/entities/app_user.dart';
import 'package:readora/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required SupabaseClient supabase,
    required SyncEngine syncEngine,
  })  : _supabase = supabase,
        _syncEngine = syncEngine {
    _controller.add(current);
    _authSub = _supabase.auth.onAuthStateChange.listen((_) {
      _controller.add(current);
    });
  }

  final SupabaseClient _supabase;
  final SyncEngine _syncEngine;

  final _controller = StreamController<AppUser?>.broadcast();
  StreamSubscription<AuthState>? _authSub;

  @override
  Stream<AppUser?> get changes => _controller.stream;

  @override
  AppUser? get current {
    final user = _supabase.auth.currentUser;
    return user == null ? null : _fromSupabase(user);
  }

  AppUser _fromSupabase(User user) => AppUser(
        id: user.id,
        email: user.email,
        displayName: user.userMetadata?['display_name'] as String?,
        isGuest: user.isAnonymous,
      );

  @override
  Future<AppUser> continueAsGuest() {
    return guard(() async {
      // Already have a session (anonymous or not) — reuse it rather than
      // orphaning the reader's existing library behind a second uid.
      final existing = _supabase.auth.currentUser;
      if (existing != null) return _fromSupabase(existing);

      final res = await _supabase.auth.signInAnonymously();
      final user = res.user;
      if (user == null) {
        throw const AuthFailure('Could not start a guest session. Check your connection.');
      }
      unawaited(_syncEngine.syncNow());
      return _fromSupabase(user);
    });
  }

  @override
  Future<AppUser> signUp({
    required String email,
    required String password,
    String? displayName,
  }) {
    return guard(() async {
      final existing = _supabase.auth.currentUser;

      // Guest upgrade path. Supabase attaches the credentials to the SAME
      // anonymous user, so every book already tracked stays theirs and nothing
      // needs migrating.
      //
      // NOTE: if "Confirm email" is enabled in Supabase Auth settings, the email
      // is not applied until the reader clicks the link — the password is set
      // immediately, but the account stays anonymous until confirmation.
      if (existing != null && existing.isAnonymous) {
        final res = await _supabase.auth.updateUser(
          UserAttributes(
            email: email,
            password: password,
            data: {if (displayName != null) 'display_name': displayName},
          ),
        );
        final user = res.user;
        if (user == null) {
          throw const AuthFailure('Could not finish creating your account.');
        }
        return _fromSupabase(user);
      }

      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {if (displayName != null) 'display_name': displayName},
      );
      final user = res.user;
      if (user == null) {
        throw const AuthFailure('Check your inbox to confirm your email, then sign in.');
      }
      return _fromSupabase(user);
    });
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return guard(() async {
      final res = await _supabase.auth.signInWithPassword(email: email, password: password);
      final user = res.user!;
      // A fresh device must pull the whole library, not just what changed since
      // some cursor left over from a previous account.
      await _syncEngine.resetCursors();
      unawaited(_syncEngine.syncNow());
      return _fromSupabase(user);
    });
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      guard(() => _supabase.auth.resetPasswordForEmail(email));

  @override
  Future<void> signOut() async {
    await guard(() => _supabase.auth.signOut());
    await _syncEngine.resetCursors();
    _controller.add(null);
  }

  Future<void> dispose() async {
    await _authSub?.cancel();
    await _controller.close();
  }
}

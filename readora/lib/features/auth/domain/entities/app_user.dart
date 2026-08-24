import 'package:equatable/equatable.dart';

/// Who is using the app right now.
///
/// Readora has three identity states:
///   * guest      — a Supabase ANONYMOUS user. Real uid, real JWT, real sync.
///                  Everything works; there is simply no email on the account yet.
///   * signed in  — the same account, after an email and password were attached.
///   * + Plus     — entitlement, checked server-side, never trusted from here.
///
/// Guests are anonymous Supabase users rather than a local-only sentinel because
/// both RLS and the Edge Functions need a real uid to work at all. It also makes
/// "keep everything I tracked when I sign up" free: Supabase upgrades the SAME
/// user in place, so there is no data migration to write, or to get wrong.
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.isGuest = false,
    this.hasPlus = false,
  });

  final String id;
  final String? email;
  final String? displayName;

  /// True while the account is still anonymous — no email attached yet.
  final bool isGuest;

  final bool hasPlus;

  String get greetingName => displayName ?? email?.split('@').first ?? 'reader';

  AppUser copyWith({String? displayName, bool? hasPlus}) => AppUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        isGuest: isGuest,
        hasPlus: hasPlus ?? this.hasPlus,
      );

  @override
  List<Object?> get props => [id, email, displayName, isGuest, hasPlus];
}

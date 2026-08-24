import 'package:readora/core/config/flavor.dart';

/// Compile-time configuration.
///
/// Values arrive through `--dart-define-from-file=env/dev.json`, never from a
/// bundled `.env` asset — an asset ships inside the APK where anyone can read it.
///
///     flutter run --flavor dev --dart-define-from-file=env/dev.json -t lib/main_dev.dart
///
/// Only the Supabase **anon** key belongs here. The service-role key and the
/// OpenAI key live exclusively as Supabase Edge Function secrets.
abstract final class Env {
  static const flavorName = String.fromEnvironment('FLAVOR', defaultValue: 'dev');
  static Flavor get flavor => Flavor.fromName(flavorName);

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// RevenueCat public SDK keys — safe to ship, they only identify the app.
  static const revenueCatAndroidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  static const revenueCatIosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

  /// Free-tier AI allowance shown in the paywall copy. The server enforces the
  /// real limit in `consume_ai_credit()`; this is display only.
  static const freeAiInteractions = int.fromEnvironment(
    'FREE_AI_INTERACTIONS',
    defaultValue: 5,
  );

  /// Fails fast at startup rather than at the first network call.
  static void assertConfigured() {
    final missing = <String>[
      if (supabaseUrl.isEmpty) 'SUPABASE_URL',
      if (supabaseAnonKey.isEmpty) 'SUPABASE_ANON_KEY',
    ];
    if (missing.isNotEmpty) {
      throw StateError(
        'Missing dart-define values: ${missing.join(', ')}. '
        'Did you pass --dart-define-from-file=env/${flavor.name}.json ?',
      );
    }
  }
}

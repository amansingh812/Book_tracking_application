import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:readora/app/app.dart';
import 'package:readora/core/config/env.dart';
import 'package:readora/core/di/injector.dart';
import 'package:readora/core/logging/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single startup path for both flavors.
///
/// Everything that can fail at launch fails here, loudly, before the first
/// frame — a missing dart-define should be a clear error, not a blank screen
/// followed by a confusing network failure five taps later.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error('flutter', details.exception, details.stack);
    if (kDebugMode) FlutterError.presentError(details);
  };

  await runZonedGuarded(
    () async {
      Env.assertConfigured();

      await Supabase.initialize(
        url: Env.supabaseUrl,
        anonKey: Env.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );

      await configureDependencies();

      runApp(const ReadoraApp());
    },
    (error, stack) => AppLogger.error('uncaught', error, stack),
  );
}

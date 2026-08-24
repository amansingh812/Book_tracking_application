import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:readora/core/config/env.dart';

/// Minimal logger with an in-memory ring buffer.
///
/// Readora ships without Firebase or Sentry, so production errors are captured
/// here and flushed to `public.client_errors` on the next launch. Swap this for
/// a real crash reporter before public launch (docs/ROADMAP.md > Release prep).
abstract final class AppLogger {
  static const _maxBuffered = 100;
  static final Queue<LoggedError> _buffer = Queue<LoggedError>();

  static List<LoggedError> get buffered => List.unmodifiable(_buffer);

  static void debug(String message) {
    if (kDebugMode) developer.log(message, name: 'readora');
  }

  static void warn(String message, [Object? error]) {
    developer.log(message, name: 'readora', error: error, level: 900);
  }

  static void error(String message, Object error, [StackTrace? stack]) {
    developer.log(message, name: 'readora', error: error, stackTrace: stack, level: 1000);

    _buffer.addLast(
      LoggedError(
        occurredAt: DateTime.now().toUtc(),
        message: '$message: $error',
        stack: stack?.toString(),
        flavor: Env.flavorName,
      ),
    );
    while (_buffer.length > _maxBuffered) {
      _buffer.removeFirst();
    }
  }

  static void clear() => _buffer.clear();
}

class LoggedError {
  const LoggedError({
    required this.occurredAt,
    required this.message,
    required this.flavor,
    this.stack,
  });

  final DateTime occurredAt;
  final String message;
  final String? stack;
  final String flavor;

  Map<String, dynamic> toJson() => {
        'occurred_at': occurredAt.toIso8601String(),
        'message': message,
        'stack': stack,
        'flavor': flavor,
      };
}

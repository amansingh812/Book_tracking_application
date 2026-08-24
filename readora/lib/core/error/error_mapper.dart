import 'dart:async';
import 'dart:io';

import 'package:readora/core/error/failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Single place where SDK exceptions become [Failure]s.
///
/// Every repository method wraps its body in [guard] so that no Supabase or
/// dart:io type ever escapes the data layer.
Failure mapError(Object error) {
  return switch (error) {
    final Failure failure => failure,
    SocketException() => const NetworkFailure(),
    TimeoutException() => const NetworkFailure('That took too long. Try again.'),
    final FunctionException e => _mapFunctionError(e),
    AuthException(:final message) => AuthFailure(message),
    PostgrestException(:final message, :final code) => switch (code) {
        '42501' => const AuthFailure('You do not have access to that.'),
        '23505' => const ValidationFailure('That already exists in your library.'),
        _ => ServerFailure(message, code: code),
      },
    StorageException(:final message) => ServerFailure(message),
    _ => ServerFailure(error.toString()),
  };
}

Failure _mapFunctionError(FunctionException error) {
  final details = error.details;
  final code = details is Map && details['error'] is Map
      ? details['error']['code'] as String?
      : null;
  final message = details is Map && details['error'] is Map
      ? details['error']['message'] as String?
      : null;

  return switch (code) {
    'AI_QUOTA_EXCEEDED' => QuotaFailure(
        message ?? 'You have used all your free AI interactions this month.',
      ),
    'NO_NOTES' => ValidationFailure(message ?? 'Save a note first.', code: code),
    'UNAUTHENTICATED' => AuthFailure(message ?? 'Please sign in again.', code: code),
    _ => ServerFailure(message ?? 'The service is unavailable right now.', code: code),
  };
}

/// Runs [body], converting anything thrown into a [Failure].
///
///     Future<Result<Book>> getBook(String id) => guard(() async { ... });
Future<T> guard<T>(Future<T> Function() body) async {
  try {
    return await body();
  } catch (error) {
    throw mapError(error);
  }
}

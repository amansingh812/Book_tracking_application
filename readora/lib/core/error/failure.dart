import 'package:equatable/equatable.dart';

/// What the UI is allowed to know about a problem.
///
/// Repositories catch platform/SDK exceptions and return a [Failure]; Blocs
/// never see a `PostgrestException` or a `SocketException`. Every Failure
/// carries a `message` that is already safe and useful to show a reader —
/// if you cannot write one, the failure is a bug, not a Failure.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// No usable connection. Almost always recoverable by waiting — the app should
/// keep working from the local database rather than showing an error screen.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'You appear to be offline.']);
}

/// Signed out, expired session, or a row that RLS refused.
final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code});
}

/// The free AI allowance for this month is spent. The UI turns this into the
/// paywall rather than an error.
final class QuotaFailure extends Failure {
  const QuotaFailure(super.message) : super(code: 'AI_QUOTA_EXCEEDED');
}

/// The user asked for something the data does not support yet — e.g. generating
/// flashcards for a book with no notes.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Anything the server refused or broke on.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Local database problems. Rare, and always worth logging.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Could not read local data.']);
}

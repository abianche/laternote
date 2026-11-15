import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// App-level error. Repositories catch Supabase errors and rethrow them as
/// one of these, so nothing above the data layer depends on Supabase types.
sealed class AppError implements Exception {
  const AppError(this.message);

  /// A clear, recoverable message to show to the user.
  final String message;

  @override
  String toString() => message;
}

/// The device could not reach the backend.
final class NetworkError extends AppError {
  const NetworkError()
    : super('No connection. Check your network and try again.');
}

/// The backend rejected an auth request (bad credentials, weak password...).
final class AuthError extends AppError {
  const AuthError(super.message);
}

/// Sign-up was attempted for an email that already has an account.
final class AccountAlreadyExistsError extends AppError {
  const AccountAlreadyExistsError() : super('An account already exists.');
}

/// Anything not covered above.
final class UnexpectedError extends AppError {
  const UnexpectedError() : super('Something went wrong. Please try again.');
}

/// Maps an exception from a Supabase call to an [AppError].
AppError mapSupabaseError(Object error) => switch (error) {
  AppError() => error,
  AuthException(code: 'user_already_exists') =>
    const AccountAlreadyExistsError(),
  AuthException(:final message) => AuthError(message),
  SocketException() || TimeoutException() => const NetworkError(),
  _ => const UnexpectedError(),
};

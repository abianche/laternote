import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// App-level error. Repositories catch Supabase errors and rethrow them as
/// one of these, so nothing above the data layer depends on Supabase types.
/// Each case is turned into localized text in the presentation layer.
sealed class AppError implements Exception {
  const AppError();
}

/// The device could not reach the backend.
final class NetworkError extends AppError {
  const NetworkError();
}

/// The action needs a session and there is none.
final class SignedOutError extends AppError {
  const SignedOutError();
}

/// Why the backend rejected an auth request.
enum AuthFailure {
  invalidCredentials,
  emailNotConfirmed,
  weakPassword,
  samePassword,
  rateLimited,
  linkExpired,
  other,
}

/// The backend rejected an auth request (bad credentials, weak password...).
final class AuthError extends AppError {
  const AuthError(this.failure);

  final AuthFailure failure;
}

/// Sign-up was attempted for an email that already has an account.
final class AccountAlreadyExistsError extends AppError {
  const AccountAlreadyExistsError();
}

/// Input that a client-side check or the backend rejected.
enum ValidationProblem {
  bodyEmpty,
  bodyTooLong,

  /// The server rejected the body (check constraint).
  bodyInvalid,
  deliveryMissing,
  deliveryInPast,

  /// The server rejected the delivery time as already passed.
  deliveryPassed,
  alreadyOpening,
}

final class ValidationError extends AppError {
  const ValidationError(this.problem);

  final ValidationProblem problem;
}

/// Anything not covered above.
final class UnexpectedError extends AppError {
  const UnexpectedError();
}

/// Maps an exception from a Supabase call to an [AppError].
AppError mapSupabaseError(Object error) => switch (error) {
  AppError() => error,
  AuthException(code: 'user_already_exists') =>
    const AccountAlreadyExistsError(),
  AuthException(:final code) => AuthError(_authFailure(code)),
  SocketException() || TimeoutException() => const NetworkError(),
  _ => const UnexpectedError(),
};

/// Supabase Auth error codes the app explains; the rest are [AuthFailure.other].
AuthFailure _authFailure(String? code) => switch (code) {
  'invalid_credentials' => AuthFailure.invalidCredentials,
  'email_not_confirmed' => AuthFailure.emailNotConfirmed,
  'weak_password' => AuthFailure.weakPassword,
  'same_password' => AuthFailure.samePassword,
  'over_request_rate_limit' ||
  'over_email_send_rate_limit' => AuthFailure.rateLimited,
  'otp_expired' || 'flow_state_expired' => AuthFailure.linkExpired,
  _ => AuthFailure.other,
};

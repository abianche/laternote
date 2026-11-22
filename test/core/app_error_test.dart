import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  AuthFailure? failureOf(String? code) => switch (mapSupabaseError(
    AuthException('server text', code: code),
  )) {
    AuthError(:final failure) => failure,
    _ => null,
  };

  test('known auth error codes map to their failure', () {
    expect(failureOf('invalid_credentials'), AuthFailure.invalidCredentials);
    expect(failureOf('email_not_confirmed'), AuthFailure.emailNotConfirmed);
    expect(failureOf('weak_password'), AuthFailure.weakPassword);
    expect(failureOf('same_password'), AuthFailure.samePassword);
    expect(failureOf('over_request_rate_limit'), AuthFailure.rateLimited);
    expect(failureOf('over_email_send_rate_limit'), AuthFailure.rateLimited);
    expect(failureOf('otp_expired'), AuthFailure.linkExpired);
    expect(failureOf('flow_state_expired'), AuthFailure.linkExpired);
  });

  test('other auth errors map to AuthFailure.other', () {
    expect(failureOf('unexpected_failure'), AuthFailure.other);
    expect(failureOf(null), AuthFailure.other);
  });

  test('an existing account maps to AccountAlreadyExistsError', () {
    expect(
      mapSupabaseError(
        const AuthException('exists', code: 'user_already_exists'),
      ),
      isA<AccountAlreadyExistsError>(),
    );
  });

  test('network failures map to NetworkError', () {
    expect(
      mapSupabaseError(const SocketException('down')),
      isA<NetworkError>(),
    );
    expect(mapSupabaseError(TimeoutException('slow')), isA<NetworkError>());
  });

  test('anything else maps to UnexpectedError', () {
    expect(mapSupabaseError(StateError('boom')), isA<UnexpectedError>());
  });
}

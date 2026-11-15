import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('auth exceptions keep their message', () {
    expect(
      mapSupabaseError(const AuthException('Invalid login credentials')),
      isA<AuthError>().having(
        (e) => e.message,
        'message',
        'Invalid login credentials',
      ),
    );
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

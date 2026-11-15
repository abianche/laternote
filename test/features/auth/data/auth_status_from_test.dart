import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/auth/data/auth_repository.dart';
import 'package:laternote/features/auth/data/auth_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  final session = Session(
    accessToken: 'token',
    tokenType: 'bearer',
    user: const User(
      id: 'user-id',
      appMetadata: {},
      userMetadata: {},
      aud: 'authenticated',
      email: 'a@b.co',
      createdAt: '2026-01-01T00:00:00Z',
    ),
  );

  test('password recovery wins even with a session', () {
    expect(
      authStatusFrom(AuthChangeEvent.passwordRecovery, session),
      isA<PasswordRecovery>(),
    );
  });

  test('a session means signed in, with the user email', () {
    final status = authStatusFrom(AuthChangeEvent.signedIn, session);
    expect(status, isA<SignedIn>().having((s) => s.email, 'email', 'a@b.co'));
  });

  test('no session means signed out', () {
    expect(
      authStatusFrom(AuthChangeEvent.signedOut, null),
      isA<SignedOut>(),
    );
  });
}

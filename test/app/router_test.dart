import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/features/auth/data/auth_status.dart';

void main() {
  const signedIn = SignedIn(email: 'a@b.co');

  group('signed out', () {
    test('is sent to sign-in from app screens', () {
      expect(authRedirect(const SignedOut(), Routes.home), Routes.signIn);
      expect(authRedirect(const SignedOut(), Routes.account), Routes.signIn);
      expect(
        authRedirect(const SignedOut(), Routes.resetPassword),
        Routes.signIn,
      );
    });

    test('stays inside the sign-in flow', () {
      expect(authRedirect(const SignedOut(), Routes.signIn), isNull);
      expect(authRedirect(const SignedOut(), Routes.signUp), isNull);
      expect(authRedirect(const SignedOut(), Routes.forgotPassword), isNull);
    });
  });

  group('signed in', () {
    test('is sent home from the sign-in flow and reset screen', () {
      expect(authRedirect(signedIn, Routes.signIn), Routes.home);
      expect(authRedirect(signedIn, Routes.signUp), Routes.home);
      expect(authRedirect(signedIn, Routes.resetPassword), Routes.home);
    });

    test('stays on app screens', () {
      expect(authRedirect(signedIn, Routes.home), isNull);
      expect(authRedirect(signedIn, Routes.privacy), isNull);
    });
  });

  test('password recovery always goes to the reset screen', () {
    expect(
      authRedirect(const PasswordRecovery(), Routes.home),
      Routes.resetPassword,
    );
    expect(
      authRedirect(const PasswordRecovery(), Routes.signIn),
      Routes.resetPassword,
    );
    expect(
      authRedirect(const PasswordRecovery(), Routes.resetPassword),
      isNull,
    );
  });
}

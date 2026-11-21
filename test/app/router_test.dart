import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/features/auth/data/auth_status.dart';

void main() {
  const signedIn = SignedIn(email: 'a@b.co');
  const id = '0b7e2c1a-4f3d-4c2b-9a8e-1d2c3b4a5f6e';
  String? redirect(AuthStatus status, String location) =>
      authRedirect(status, Uri.parse(location));

  group('signed out', () {
    test('is sent to sign-in from app screens', () {
      expect(redirect(const SignedOut(), Routes.home), Routes.signIn);
      expect(redirect(const SignedOut(), Routes.account), Routes.signIn);
      expect(
        redirect(const SignedOut(), Routes.resetPassword),
        Routes.signIn,
      );
    });

    test('is sent to sign-in and then on to a message', () {
      expect(
        redirect(const SignedOut(), Routes.message(id)),
        '/sign-in?from=%2Fmessages%2F$id',
      );
    });

    test('stays inside the sign-in flow', () {
      expect(redirect(const SignedOut(), Routes.signIn), isNull);
      expect(redirect(const SignedOut(), Routes.signUp), isNull);
      expect(redirect(const SignedOut(), Routes.forgotPassword), isNull);
    });
  });

  group('signed in', () {
    test('is sent home from the sign-in flow and reset screen', () {
      expect(redirect(signedIn, Routes.signIn), Routes.home);
      expect(redirect(signedIn, Routes.signUp), Routes.home);
      expect(redirect(signedIn, Routes.resetPassword), Routes.home);
    });

    test('goes on to the message it signed in for', () {
      expect(
        redirect(signedIn, '/sign-in?from=/messages/$id'),
        '/messages/$id',
      );
    });

    test('goes home when the sign-in target is not a message', () {
      expect(redirect(signedIn, '/sign-in?from=/account'), Routes.home);
      expect(redirect(signedIn, '/sign-in?from=https://x.co'), Routes.home);
      expect(
        redirect(signedIn, '/sign-in?from=/messages/$id/../account'),
        Routes.home,
      );
    });

    test('stays on app screens', () {
      expect(redirect(signedIn, Routes.home), isNull);
      expect(redirect(signedIn, Routes.privacy), isNull);
      expect(redirect(signedIn, Routes.message('m1')), isNull);
    });
  });

  test('password recovery always goes to the reset screen', () {
    expect(
      redirect(const PasswordRecovery(), Routes.home),
      Routes.resetPassword,
    );
    expect(
      redirect(const PasswordRecovery(), Routes.signIn),
      Routes.resetPassword,
    );
    expect(
      redirect(const PasswordRecovery(), Routes.resetPassword),
      isNull,
    );
  });
}

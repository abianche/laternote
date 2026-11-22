import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/deep_link.dart';

void main() {
  DeepLink parse(String link) => parseDeepLink(Uri.parse(link));

  LinkProblem? problemOf(String link) => switch (parse(link)) {
    BrokenLink(:final problem) => problem,
    AuthCallbackLink() => null,
  };

  test('each kind has its own redirect URL', () {
    expect(
      authLinkUrl(AuthLinkKind.passwordReset),
      'io.laternote://auth/reset-password',
    );
    expect(
      authLinkUrl(AuthLinkKind.emailConfirmation),
      'io.laternote://auth/confirm-email',
    );
    expect(
      authLinkUrl(AuthLinkKind.magicLink),
      'io.laternote://auth/magic-link',
    );
  });

  test('recognizes every kind of auth callback by its path', () {
    for (final kind in AuthLinkKind.values) {
      final link = '${authLinkUrl(kind)}?code=abc';
      expect(
        parse(link),
        isA<AuthCallbackLink>()
            .having((l) => l.kind, 'kind', kind)
            .having((l) => l.uri, 'uri', Uri.parse(link)),
      );
    }
  });

  test('an expired link from Supabase is expired', () {
    expect(
      problemOf(
        'io.laternote://auth/reset-password#error=access_denied'
        '&error_code=otp_expired&error_description=Email+link+is+invalid',
      ),
      LinkProblem.expired,
    );
    expect(
      problemOf(
        'io.laternote://auth/confirm-email?error=x&error_code=flow_state_expired',
      ),
      LinkProblem.expired,
    );
  });

  test('other errors and missing codes are invalid', () {
    expect(
      problemOf('io.laternote://auth/magic-link#error=server_error'),
      LinkProblem.invalid,
    );
    expect(problemOf('io.laternote://auth/magic-link'), LinkProblem.invalid);
    expect(
      problemOf('io.laternote://auth/magic-link?code='),
      LinkProblem.invalid,
    );
  });

  test('anything else is unrecognized', () {
    for (final link in [
      'io.laternote://auth/unknown?code=abc',
      'io.laternote://auth/reset-password/extra?code=abc',
      'io.laternote://other/reset-password?code=abc',
      'https://laternote.io/auth/reset-password?code=abc',
      'io.laternote.auth://login-callback?code=abc',
    ]) {
      expect(problemOf(link), LinkProblem.unrecognized, reason: link);
    }
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_environment.dart';

void main() {
  const validKey = 'sb_publishable_abc123';

  bool check({
    String? flavor = 'development',
    String env = 'development',
    String url = 'https://project-ref.supabase.co',
    String publishableKey = validKey,
  }) {
    return isValidSupabaseConfig(
      flavor: flavor,
      env: env,
      url: url,
      publishableKey: publishableKey,
    );
  }

  test('valid development config over https', () {
    expect(check(), isTrue);
  });

  test('valid production config over https', () {
    expect(
      check(
        flavor: 'production',
        env: 'production',
        url: 'https://other-ref.supabase.co',
      ),
      isTrue,
    );
  });

  test('development config over http to loopback is allowed', () {
    expect(check(url: 'http://127.0.0.1:54321'), isTrue);
    expect(check(url: 'http://localhost:54321'), isTrue);
  });

  test('production config over http is rejected even to loopback', () {
    expect(
      check(
        flavor: 'production',
        env: 'production',
        url: 'http://127.0.0.1:54321',
      ),
      isFalse,
    );
  });

  test('http to a non-loopback host is rejected', () {
    expect(check(url: 'http://example.com'), isFalse);
  });

  test('flavor not matching the declared environment is rejected', () {
    expect(check(flavor: 'production'), isFalse);
  });

  test('missing flavor is rejected', () {
    expect(check(flavor: null), isFalse);
  });

  test('unrecognized environment name is rejected', () {
    expect(check(flavor: 'staging', env: 'staging'), isFalse);
  });

  test('non-publishable key is rejected', () {
    expect(check(publishableKey: 'sb_secret_abc123'), isFalse);
  });

  test('unparseable or hostless URL is rejected', () {
    expect(check(url: 'not a url'), isFalse);
    expect(check(url: 'https://'), isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/auth/validators.dart';

void main() {
  group('validateEmail', () {
    test('rejects empty input', () {
      expect(validateEmail(''), isNotNull);
    });

    test('rejects a string without an @', () {
      expect(validateEmail('not-an-email'), isNotNull);
    });

    test('accepts a well-formed address', () {
      expect(validateEmail('person@example.com'), isNull);
    });
  });

  group('validatePassword', () {
    test('rejects empty input', () {
      expect(validatePassword(''), isNotNull);
    });

    test('rejects a password shorter than 8 characters', () {
      expect(validatePassword('abc1234'), isNotNull);
    });

    test('accepts an 8+ character password', () {
      expect(validatePassword('abc12345'), isNull);
    });
  });

  group('validatePasswordConfirmation', () {
    test('rejects empty confirmation', () {
      expect(validatePasswordConfirmation('abc123', ''), isNotNull);
    });

    test('rejects a mismatched confirmation', () {
      expect(validatePasswordConfirmation('abc123', 'xyz789'), isNotNull);
    });

    test('accepts a matching confirmation', () {
      expect(validatePasswordConfirmation('abc123', 'abc123'), isNull);
    });
  });
}

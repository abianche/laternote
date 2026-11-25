import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/limits.dart';
import 'package:laternote/features/messages/application/message_draft.dart';

void main() {
  final now = DateTime(2030, 1, 1, 12);

  group('validateBody', () {
    test('rejects empty and whitespace-only text', () {
      expect(validateBody(''), isNotNull);
      expect(validateBody('  \n '), isNotNull);
      expect(validateBody(null), isNotNull);
    });

    test('accepts text up to the cap, rejects beyond it', () {
      expect(validateBody('a' * maxMessageLength), isNull);
      expect(validateBody('a' * (maxMessageLength + 1)), isNotNull);
    });

    test('counts code points, like Postgres char_length', () {
      // Each emoji is 2 UTF-16 units but 1 code point.
      expect(validateBody('😀' * maxMessageLength), isNull);
    });
  });

  group('validateDeliverAt', () {
    test('requires a time', () {
      expect(validateDeliverAt(null, now), isNotNull);
    });

    test('rejects now and the past', () {
      expect(validateDeliverAt(now, now), isNotNull);
      expect(
        validateDeliverAt(now.subtract(const Duration(minutes: 1)), now),
        isNotNull,
      );
    });

    test('accepts the future', () {
      expect(
        validateDeliverAt(now.add(const Duration(minutes: 1)), now),
        isNull,
      );
    });
  });
}

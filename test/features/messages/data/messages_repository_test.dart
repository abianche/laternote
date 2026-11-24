import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/database.dart';
import 'package:laternote/features/messages/data/available_message.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';

void main() {
  late AppDatabase db;
  late DateTime now;
  late int ids;
  late MessagesRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    now = DateTime.utc(2030, 1, 1, 12);
    ids = 0;
    repository = MessagesRepository(db, () => now, () => 'id-${++ids}');
  });

  tearDown(() => db.close());

  /// Seals a letter opening [after] from now and returns its id.
  Future<String> seal(Duration after, {String body = 'Dear me'}) async {
    await repository.createScheduledMessage(
      body: body,
      scheduledFor: now.add(after),
      timezone: 'Europe/Rome',
    );
    return 'id-$ids';
  }

  group('createScheduledMessage', () {
    test('saves body, UTC time, zone and seal time', () async {
      final at = DateTime(2030, 1, 2, 9, 30);
      await repository.createScheduledMessage(
        body: 'Hello future me',
        scheduledFor: at,
        timezone: 'Europe/Rome',
      );

      final row = await db.select(db.letters).getSingle();
      expect(row.id, 'id-1');
      expect(row.body, 'Hello future me');
      expect(row.scheduledFor.isAtSameMomentAs(at), isTrue);
      expect(row.timezone, 'Europe/Rome');
      expect(row.createdAt.isAtSameMomentAs(now), isTrue);
      expect(row.openedAt, isNull);
    });

    test('rejects a time that is not in the future', () async {
      await expectLater(
        seal(Duration.zero),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.problem,
            'problem',
            ValidationProblem.deliveryInPast,
          ),
        ),
      );
      expect(await db.select(db.letters).get(), isEmpty);
    });

    test('each seal is a new letter', () async {
      await seal(const Duration(days: 1));
      await seal(const Duration(days: 1));

      expect(await db.select(db.letters).get(), hasLength(2));
    });

    test('a storage failure maps to UnexpectedError', () async {
      await expectLater(
        seal(const Duration(days: 1), body: ''),
        throwsA(isA<UnexpectedError>()),
      );
    });
  });

  group('deleteScheduledMessage', () {
    test('deletes a letter before it is ready', () async {
      final id = await seal(const Duration(hours: 1));

      await repository.deleteScheduledMessage(id);

      expect(await db.select(db.letters).get(), isEmpty);
    });

    test('a ready letter is not deleted', () async {
      final id = await seal(const Duration(hours: 1));
      now = now.add(const Duration(hours: 1));

      await expectLater(
        repository.deleteScheduledMessage(id),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.problem,
            'problem',
            ValidationProblem.alreadyOpening,
          ),
        ),
      );
      expect(await db.select(db.letters).get(), hasLength(1));
    });

    test('an unknown id is rejected', () async {
      await expectLater(
        repository.deleteScheduledMessage('nope'),
        throwsA(isA<ValidationError>()),
      );
    });
  });

  group('listUpcoming', () {
    test('lists letters not ready yet, soonest first, in local time', () async {
      final later = await seal(const Duration(days: 2));
      final sooner = await seal(const Duration(days: 1));
      final ready = await seal(const Duration(hours: 1));
      now = now.add(const Duration(hours: 1));

      final upcoming = await repository.listUpcoming();

      expect(upcoming.map((m) => m.id), [sooner, later]);
      expect(upcoming.map((m) => m.id), isNot(contains(ready)));
      expect(
        upcoming.first,
        ScheduledMessage(
          id: sooner,
          scheduledFor: DateTime.utc(2030, 1, 2, 12).toLocal(),
          timezone: 'Europe/Rome',
          createdAt: DateTime.utc(2030, 1, 1, 12).toLocal(),
        ),
      );
    });
  });

  group('listAvailable', () {
    test('lists ready letters, newest first, new until opened', () async {
      final older = await seal(const Duration(hours: 1));
      final newer = await seal(const Duration(hours: 2));
      await seal(const Duration(days: 1));
      now = now.add(const Duration(hours: 2));
      await repository.markOpened(older);

      final items = await repository.listAvailable();

      expect(items.map((m) => m.id), [newer, older]);
      expect(
        items.first,
        InboxItem(
          id: newer,
          createdAt: DateTime.utc(2030, 1, 1, 12).toLocal(),
          scheduledFor: DateTime.utc(2030, 1, 1, 14).toLocal(),
          openedAt: null,
        ),
      );
      expect(items.last.isNew, isFalse);
    });
  });

  group('getAvailable', () {
    test('the body is hidden until the letter is ready', () async {
      final id = await seal(const Duration(hours: 1));

      expect(await repository.getAvailable(id), isNull);

      now = now.add(const Duration(hours: 1));
      expect(
        await repository.getAvailable(id),
        AvailableMessage(
          id: id,
          body: 'Dear me',
          scheduledFor: DateTime.utc(2030, 1, 1, 13).toLocal(),
          timezone: 'Europe/Rome',
          createdAt: DateTime.utc(2030, 1, 1, 12).toLocal(),
          openedAt: null,
        ),
      );
    });

    test('an unknown or malformed id is not available', () async {
      expect(await repository.getAvailable('nope'), isNull);
    });
  });

  group('markOpened', () {
    test('records the first open only', () async {
      final id = await seal(const Duration(hours: 1));
      now = now.add(const Duration(hours: 1));

      await repository.markOpened(id);
      final first = now;
      now = now.add(const Duration(days: 3));
      await repository.markOpened(id);

      final message = await repository.getAvailable(id);
      expect(message!.openedAt, first.toLocal());
    });

    test('ignores a letter that is not ready', () async {
      final id = await seal(const Duration(hours: 1));

      await repository.markOpened(id);

      final row = await db.select(db.letters).getSingle();
      expect(row.openedAt, isNull);
    });
  });
}

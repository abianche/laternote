import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/data/available_message.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late http.Request? sent;

  MessagesRepository repository({
    int status = 201,
    Map<String, Object?>? error,
    Object? rows,
    String? userId = 'user-1',
  }) {
    sent = null;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        error != null
            ? jsonEncode(error)
            : rows != null
            ? jsonEncode(rows)
            : '',
        status,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });
    return MessagesRepository(
      PostgrestClient('http://localhost/rest/v1', httpClient: client),
      () => userId,
    );
  }

  Future<void> create(MessagesRepository repo) => repo.createScheduledMessage(
    body: 'Hello future me',
    scheduledFor: DateTime.utc(2030, 1, 2, 8, 30),
    timezone: 'Europe/Rome',
  );

  test('inserts the owner, body, UTC time and zone', () async {
    await create(repository());

    expect(sent!.method, 'POST');
    expect(sent!.url.path, '/rest/v1/messages');
    expect(jsonDecode(sent!.body), {
      'user_id': 'user-1',
      'body': 'Hello future me',
      'scheduled_for': '2030-01-02T08:30:00.000Z',
      'timezone': 'Europe/Rome',
    });
  });

  test('converts a local time to UTC', () async {
    final local = DateTime(2030, 1, 2, 9, 30);
    await repository().createScheduledMessage(
      body: 'x',
      scheduledFor: local,
      timezone: 'Europe/Rome',
    );

    final body = jsonDecode(sent!.body) as Map<String, Object?>;
    expect(DateTime.parse(body['scheduled_for']! as String), local.toUtc());
    expect((body['scheduled_for']! as String).endsWith('Z'), isTrue);
  });

  test('a signed-out user gets an AuthError and nothing is sent', () async {
    await expectLater(
      create(repository(userId: null)),
      throwsA(isA<AuthError>()),
    );
    expect(sent, isNull);
  });

  test('an RLS rejection maps to a past-time ValidationError', () async {
    final repo = repository(
      status: 403,
      error: {'code': '42501', 'message': 'row-level security'},
    );
    await expectLater(
      create(repo),
      throwsA(
        isA<ValidationError>().having(
          (e) => e.message,
          'message',
          contains('already passed'),
        ),
      ),
    );
  });

  test('a body check violation maps to a ValidationError', () async {
    final repo = repository(
      status: 400,
      error: {'code': '23514', 'message': 'check constraint'},
    );
    await expectLater(create(repo), throwsA(isA<ValidationError>()));
  });

  test('other database errors map to UnexpectedError', () async {
    final repo = repository(
      status: 500,
      error: {'code': 'XX000', 'message': 'boom'},
    );
    await expectLater(create(repo), throwsA(isA<UnexpectedError>()));
  });

  group('listUpcoming', () {
    test('selects metadata of scheduled rows only, soonest first', () async {
      await repository(status: 200, rows: []).listUpcoming();

      final query = sent!.url.queryParameters;
      expect(sent!.method, 'GET');
      expect(sent!.url.path, '/rest/v1/messages');
      expect(query['select'], 'id,scheduled_for,timezone,created_at');
      expect(query['select'], isNot(contains('body')));
      expect(query['status'], 'eq.scheduled');
      expect(query['order'], 'scheduled_for.asc.nullslast');
    });

    test('maps rows to local-time messages', () async {
      final messages = await repository(
        status: 200,
        rows: [
          {
            'id': 'm1',
            'scheduled_for': '2030-01-02T08:30:00+00:00',
            'timezone': 'Europe/Rome',
            'created_at': '2029-12-01T10:00:00+00:00',
          },
        ],
      ).listUpcoming();

      expect(messages, [
        ScheduledMessage(
          id: 'm1',
          scheduledFor: DateTime.utc(2030, 1, 2, 8, 30).toLocal(),
          timezone: 'Europe/Rome',
          createdAt: DateTime.utc(2029, 12, 1, 10).toLocal(),
        ),
      ]);
      expect(messages.single.scheduledFor.isUtc, isFalse);
    });

    test('database errors map to an AppError', () async {
      final repo = repository(
        status: 500,
        error: {'code': 'XX000', 'message': 'boom'},
      );
      await expectLater(repo.listUpcoming(), throwsA(isA<UnexpectedError>()));
    });
  });

  group('deleteScheduledMessage', () {
    test('deletes the row by id and asks for it back', () async {
      await repository(
        status: 200,
        rows: [
          {'id': 'm1'},
        ],
      ).deleteScheduledMessage('m1');

      expect(sent!.method, 'DELETE');
      expect(sent!.url.path, '/rest/v1/messages');
      expect(sent!.url.queryParameters['id'], 'eq.m1');
      expect(sent!.url.queryParameters['select'], 'id');
    });

    test('no deleted row means it is already opening', () async {
      await expectLater(
        repository(status: 200, rows: []).deleteScheduledMessage('m1'),
        throwsA(
          isA<ValidationError>().having(
            (e) => e.message,
            'message',
            contains('already opening'),
          ),
        ),
      );
    });

    test('database errors map to an AppError', () async {
      final repo = repository(
        status: 500,
        error: {'code': 'XX000', 'message': 'boom'},
      );
      await expectLater(
        repo.deleteScheduledMessage('m1'),
        throwsA(isA<UnexpectedError>()),
      );
    });
  });

  group('listAvailable', () {
    test('selects metadata of released rows only, newest first', () async {
      await repository(status: 200, rows: []).listAvailable();

      final query = sent!.url.queryParameters;
      expect(sent!.method, 'GET');
      expect(sent!.url.path, '/rest/v1/messages');
      expect(query['select'], 'id,created_at,released_at,opened_at');
      expect(query['status'], 'eq.available');
      expect(query['order'], 'released_at.desc.nullslast');
    });

    test('maps rows to local-time items, new while unopened', () async {
      final items = await repository(
        status: 200,
        rows: [
          {
            'id': 'm1',
            'created_at': '2029-12-01T10:00:00+00:00',
            'released_at': '2030-01-02T08:30:00+00:00',
            'opened_at': null,
          },
          {
            'id': 'm2',
            'created_at': '2029-11-01T10:00:00+00:00',
            'released_at': '2030-01-01T08:30:00+00:00',
            'opened_at': '2030-01-01T09:00:00+00:00',
          },
        ],
      ).listAvailable();

      expect(
        items.first,
        InboxItem(
          id: 'm1',
          createdAt: DateTime.utc(2029, 12, 1, 10).toLocal(),
          releasedAt: DateTime.utc(2030, 1, 2, 8, 30).toLocal(),
          openedAt: null,
        ),
      );
      expect(items.first.isNew, isTrue);
      expect(items.last.isNew, isFalse);
      expect(items.last.openedAt, DateTime.utc(2030, 1, 1, 9).toLocal());
    });

    test('database errors map to an AppError', () async {
      final repo = repository(
        status: 500,
        error: {'code': 'XX000', 'message': 'boom'},
      );
      await expectLater(repo.listAvailable(), throwsA(isA<UnexpectedError>()));
    });
  });

  group('getAvailable', () {
    test('calls the checked RPC and maps the message', () async {
      final message = await repository(
        status: 200,
        rows: [
          {
            'id': 'm1',
            'body': 'Hello me',
            'scheduled_for': '2030-01-02T08:30:00+00:00',
            'timezone': 'Europe/Rome',
            'created_at': '2029-12-01T10:00:00+00:00',
            'released_at': '2030-01-02T08:30:10+00:00',
            'opened_at': null,
          },
        ],
      ).getAvailable('m1');

      expect(sent!.method, 'POST');
      expect(sent!.url.path, '/rest/v1/rpc/get_available_message');
      expect(jsonDecode(sent!.body), {'p_message_id': 'm1'});
      expect(
        message,
        AvailableMessage(
          id: 'm1',
          body: 'Hello me',
          scheduledFor: DateTime.utc(2030, 1, 2, 8, 30).toLocal(),
          timezone: 'Europe/Rome',
          createdAt: DateTime.utc(2029, 12, 1, 10).toLocal(),
          releasedAt: DateTime.utc(2030, 1, 2, 8, 30, 10).toLocal(),
          openedAt: null,
        ),
      );
    });

    test('no row means not available', () async {
      expect(
        await repository(status: 200, rows: []).getAvailable('m1'),
        isNull,
      );
    });

    test('a malformed id means not available', () async {
      final repo = repository(
        status: 400,
        error: {
          'code': '22P02',
          'message': 'invalid input syntax for type uuid: "not-a-uuid"',
        },
      );
      expect(await repo.getAvailable('not-a-uuid'), isNull);
    });

    test('database errors map to an AppError', () async {
      final repo = repository(
        status: 500,
        error: {'code': 'XX000', 'message': 'boom'},
      );
      await expectLater(
        repo.getAvailable('m1'),
        throwsA(isA<UnexpectedError>()),
      );
    });
  });

  group('markOpened', () {
    test('calls the RPC with the id', () async {
      await repository(status: 204).markOpened('m1');

      expect(sent!.method, 'POST');
      expect(sent!.url.path, '/rest/v1/rpc/mark_message_opened');
      expect(jsonDecode(sent!.body), {'p_message_id': 'm1'});
    });

    test('database errors map to an AppError', () async {
      final repo = repository(
        status: 500,
        error: {'code': 'XX000', 'message': 'boom'},
      );
      await expectLater(
        repo.markOpened('m1'),
        throwsA(isA<UnexpectedError>()),
      );
    });
  });
}

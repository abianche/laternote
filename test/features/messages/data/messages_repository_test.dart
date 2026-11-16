import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late http.Request? sent;

  MessagesRepository repository({
    int status = 201,
    Map<String, Object?>? error,
    String? userId = 'user-1',
  }) {
    sent = null;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        error == null ? '' : jsonEncode(error),
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
}

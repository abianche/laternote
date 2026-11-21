import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/notifications/data/device_token_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  late http.Request? sent;

  DeviceTokenRepository repository({
    int status = 200,
    Map<String, Object?>? error,
  }) {
    sent = null;
    final client = MockClient((request) async {
      sent = request;
      return http.Response(
        error != null ? jsonEncode(error) : '',
        status,
        headers: {'content-type': 'application/json'},
        request: request,
      );
    });
    return DeviceTokenRepository(
      PostgrestClient('http://localhost/rest/v1', httpClient: client),
    );
  }

  test('registers through the RPC', () async {
    await repository(status: 204).register('fid-1', 'android');

    expect(sent!.method, 'POST');
    expect(sent!.url.path, '/rest/v1/rpc/register_device_token');
    expect(jsonDecode(sent!.body), {
      'p_token': 'fid-1',
      'p_platform': 'android',
    });
  });

  test('removes only the given token', () async {
    await repository(status: 204).remove('fid-1');

    expect(sent!.method, 'DELETE');
    expect(sent!.url.path, '/rest/v1/device_tokens');
    expect(sent!.url.queryParameters['token'], 'eq.fid-1');
  });

  test('maps failures to app errors', () async {
    final repo = repository(
      status: 401,
      error: {'code': '42501', 'message': 'permission denied'},
    );

    await expectLater(
      repo.register('fid-1', 'android'),
      throwsA(isA<AppError>()),
    );
    await expectLater(repo.remove('fid-1'), throwsA(isA<AppError>()));
  });
}

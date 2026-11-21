import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/auth/application/auth_status_provider.dart';
import 'package:laternote/features/auth/data/auth_status.dart';
import 'package:laternote/features/notifications/application/notification_permission.dart';
import 'package:laternote/features/notifications/application/push_registration.dart';
import 'package:laternote/features/notifications/data/device_token_repository.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';

import '../fake_push_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const signedIn = SignedIn(email: 'a@b.co');
  late StreamController<AuthStatus> auth;
  late FakePushRepository push;
  late FakeDeviceTokenRepository tokens;
  late ProviderContainer container;

  Future<void> start(AuthStatus status) async {
    container = ProviderContainer.test(
      overrides: [
        authStatusProvider.overrideWith((_) => auth.stream),
        pushRepositoryProvider.overrideWithValue(push),
        deviceTokenRepositoryProvider.overrideWithValue(tokens),
      ],
    );
    container.listen(pushRegistrationProvider, (_, _) {});
    auth.add(status);
    await pumpEventQueue();
  }

  setUp(() {
    auth = StreamController<AuthStatus>.broadcast();
    push = FakePushRepository();
    tokens = FakeDeviceTokenRepository();
  });

  tearDown(() => auth.close());

  test('registers this device after sign-in', () async {
    await start(signedIn);

    expect(tokens.calls, ['register:fid-1:android']);
  });

  test('does not register while signed out', () async {
    await start(const SignedOut());

    expect(push.calls, ['unregister']);
    expect(tokens.calls, isEmpty);
  });

  test('waits for permission before registering', () async {
    push
      ..status = PushPermission.notDetermined
      ..afterRequest = PushPermission.granted;
    await start(signedIn);
    expect(tokens.calls, isEmpty);

    await container.read(notificationPermissionProvider.notifier).request();
    await pumpEventQueue();

    expect(tokens.calls, ['register:fid-1:android']);
  });

  test('never registers when permission is denied', () async {
    push.status = PushPermission.denied;
    await start(signedIn);

    expect(push.calls, isEmpty);
    expect(tokens.calls, isEmpty);
  });

  test('registers again when FCM does', () async {
    await start(signedIn);
    push.registered.add('fid-2');
    await pumpEventQueue();

    expect(tokens.calls, ['register:fid-1:android', 'register:fid-2:android']);
  });

  test('unregister removes the registered device once', () async {
    await start(signedIn);
    final notifier = container.read(pushRegistrationProvider.notifier);
    await notifier.unregister();
    await notifier.unregister();

    expect(tokens.calls, ['register:fid-1:android', 'remove:fid-1']);
  });

  test('sign-out stops FCM and ignores later registrations', () async {
    await start(signedIn);
    auth.add(const SignedOut());
    await pumpEventQueue();
    push.registered.add('fid-2');
    await pumpEventQueue();

    expect(push.calls, ['register', 'unregister']);
    expect(tokens.calls, ['register:fid-1:android']);
  });

  test('failures never surface', () async {
    push.error = const NetworkError();
    await start(signedIn);
    expect(tokens.calls, isEmpty);

    push.error = null;
    tokens.error = const NetworkError();
    push.registered.add('fid-2');
    await pumpEventQueue();
    await container.read(pushRegistrationProvider.notifier).unregister();

    // The failed registration was never stored, so there's nothing to remove.
    expect(tokens.calls, ['register:fid-2:android']);
  });
}

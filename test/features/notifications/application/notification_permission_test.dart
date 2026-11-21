import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/notifications/application/notification_permission.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';

import '../fake_push_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePushRepository push;
  late ProviderContainer container;

  setUp(() {
    push = FakePushRepository(status: PushPermission.notDetermined);
    container = ProviderContainer.test(
      overrides: [pushRepositoryProvider.overrideWithValue(push)],
    );
  });

  test('reads the current permission', () async {
    expect(
      await container.read(notificationPermissionProvider.future),
      PushPermission.notDetermined,
    );
  });

  test('request shows the prompt and keeps the answer', () async {
    push.afterRequest = PushPermission.denied;
    await container.read(notificationPermissionProvider.future);
    await container.read(notificationPermissionProvider.notifier).request();

    expect(push.calls, ['requestPermission']);
    expect(
      container.read(notificationPermissionProvider).value,
      PushPermission.denied,
    );
  });

  test('re-reads the permission when the app resumes', () async {
    container.listen(notificationPermissionProvider, (_, _) {});
    await container.read(notificationPermissionProvider.future);
    push.status = PushPermission.granted;

    TestWidgetsFlutterBinding.instance
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(
      await container.read(notificationPermissionProvider.future),
      PushPermission.granted,
    );
  });
}

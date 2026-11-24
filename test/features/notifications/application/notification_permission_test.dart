import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/notifications/application/notification_permission.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';

import '../fake_local_notifications_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeLocalNotificationsRepository notifications;
  late ProviderContainer container;

  setUp(() {
    notifications = FakeLocalNotificationsRepository(
      status: NotificationAccess.notDetermined,
    );
    container = ProviderContainer.test(
      overrides: [
        localNotificationsRepositoryProvider.overrideWithValue(notifications),
      ],
    );
  });

  test('reads the current permission', () async {
    expect(
      await container.read(notificationPermissionProvider.future),
      NotificationAccess.notDetermined,
    );
  });

  test('request shows the prompt and keeps the answer', () async {
    notifications.afterRequest = NotificationAccess.denied;
    await container.read(notificationPermissionProvider.future);
    await container.read(notificationPermissionProvider.notifier).request();

    expect(notifications.calls, ['requestPermission']);
    expect(
      container.read(notificationPermissionProvider).value,
      NotificationAccess.denied,
    );
  });

  test('re-reads the permission when the app resumes', () async {
    container.listen(notificationPermissionProvider, (_, _) {});
    await container.read(notificationPermissionProvider.future);
    notifications.status = NotificationAccess.granted;

    TestWidgetsFlutterBinding.instance
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(
      await container.read(notificationPermissionProvider.future),
      NotificationAccess.granted,
    );
  });
}

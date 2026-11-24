import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laternote/app/notification_routing.dart';
import 'package:laternote/app/router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:material_ui/material_ui.dart';

import '../features/messages/fake_messages_repository.dart';
import '../features/notifications/fake_local_notifications_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const id = '0b7e2c1a-4f3d-4c2b-9a8e-1d2c3b4a5f6e';
  late FakeLocalNotificationsRepository notifications;
  late FakeMessagesRepository messages;
  late GoRouter router;

  String location() => router.routeInformationProvider.value.uri.toString();

  Future<void> start() async {
    final container = ProviderContainer.test(
      overrides: [
        localNotificationsRepositoryProvider.overrideWithValue(notifications),
        messagesRepositoryProvider.overrideWithValue(messages),
        routerProvider.overrideWithValue(router),
      ],
    );
    container.listen(notificationRoutingProvider, (_, _) {});
    await pumpEventQueue();
  }

  setUp(() {
    notifications = FakeLocalNotificationsRepository();
    messages = FakeMessagesRepository()..available.add(released(id));
    router = GoRouter(
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, _) => const SizedBox(),
          routes: [
            GoRoute(path: 'messages/:id', builder: (_, _) => const SizedBox()),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(notifications.close);
  });

  test('opens the letter whose notification launched the app', () async {
    notifications.launchId = id;
    await start();

    expect(location(), Routes.message(id));
  });

  test('opens the letter whose notification is tapped', () async {
    await start();
    expect(location(), Routes.home);

    notifications.taps.add(id);
    await pumpEventQueue();

    expect(location(), Routes.message(id));
  });

  test('opens the inbox when the letter is gone', () async {
    messages.available.clear();
    router.go(Routes.message('other'));
    await start();

    notifications.taps.add(id);
    await pumpEventQueue();

    expect(location(), Routes.home);
  });
}

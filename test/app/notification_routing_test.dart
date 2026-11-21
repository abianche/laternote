import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laternote/app/notification_routing.dart';
import 'package:laternote/app/router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/features/messages/application/inbox.dart';
import 'package:laternote/features/messages/application/upcoming_messages.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';
import 'package:material_ui/material_ui.dart';

import '../features/messages/fake_messages_repository.dart';
import '../features/notifications/fake_push_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const id = '0b7e2c1a-4f3d-4c2b-9a8e-1d2c3b4a5f6e';
  late FakePushRepository push;
  late FakeMessagesRepository messages;
  late GoRouter router;
  late ProviderContainer container;

  String location() => router.routeInformationProvider.value.uri.toString();

  Future<void> start() async {
    container = ProviderContainer.test(
      overrides: [
        pushRepositoryProvider.overrideWithValue(push),
        messagesRepositoryProvider.overrideWithValue(messages),
        routerProvider.overrideWithValue(router),
      ],
    );
    container.listen(notificationRoutingProvider, (_, _) {});
    await pumpEventQueue();
  }

  setUp(() {
    push = FakePushRepository();
    messages = FakeMessagesRepository();
    router = GoRouter(
      routes: [GoRoute(path: Routes.home, builder: (_, _) => const SizedBox())],
    );
    addTearDown(router.dispose);
  });

  test('opens the message whose notification launched the app', () async {
    push.initialMessageId = id;
    await start();

    expect(location(), Routes.message(id));
  });

  test('opens the message whose notification is tapped', () async {
    await start();
    expect(location(), Routes.home);

    push.opened.add(id);
    await pumpEventQueue();

    expect(location(), Routes.message(id));
  });

  test('refreshes the lists when a notification arrives', () async {
    await start();
    container
      ..listen(availableMessagesProvider, (_, _) {})
      ..listen(upcomingMessagesProvider, (_, _) {});
    await pumpEventQueue();
    final before = messages.listCalls;

    push.received.add(null);
    await pumpEventQueue();

    expect(messages.listCalls, before + 2);
    expect(location(), Routes.home);
  });
}

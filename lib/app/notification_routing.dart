import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/messages/application/inbox.dart';
import '../features/messages/application/upcoming_messages.dart';
import '../features/notifications/data/push_repository.dart';
import 'router.dart';
import 'routes.dart';

part 'notification_routing.g.dart';

/// Opens the message whose notification the user tapped, both the one that
/// launched the app and any tapped while it runs. Signed out, the router
/// sends them to sign-in first and on to the message after. A notification
/// arriving while the app is open refreshes the lists instead.
@Riverpod(keepAlive: true)
void notificationRouting(Ref ref) {
  final push = ref.watch(pushRepositoryProvider);
  void open(String id) => ref.read(routerProvider).go(Routes.message(id));

  final taps = push.openedMessageIds.listen(open, onError: (Object _) {});
  ref.onDispose(taps.cancel);
  unawaited(
    push.initialOpenedMessageId().then(
      (id) {
        if (id != null && ref.mounted) open(id);
      },
      onError: (Object _) {},
    ),
  );

  final received = push.foregroundMessages.listen((_) {
    ref
      ..invalidate(availableMessagesProvider)
      ..invalidate(upcomingMessagesProvider);
  }, onError: (Object _) {});
  ref.onDispose(received.cancel);
}

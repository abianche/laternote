import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/messages/data/messages_repository.dart';
import '../features/notifications/data/local_notifications_repository.dart';
import 'router.dart';
import 'routes.dart';

part 'notification_routing.g.dart';

/// Opens the letter whose notification the user tapped, both the one that
/// launched the app and any tapped while it runs, or the inbox if the
/// letter is gone. Signed out, the router sends them to sign-in first and
/// on to the letter after.
@Riverpod(keepAlive: true)
void notificationRouting(Ref ref) {
  final notifications = ref.watch(localNotificationsRepositoryProvider);

  Future<void> open(String id) async {
    bool ready;
    try {
      ready =
          await ref.read(messagesRepositoryProvider).getAvailable(id) != null;
    } on Object {
      // The letter screen explains a letter it can't read.
      ready = true;
    }
    if (!ref.mounted) return;
    ref.read(routerProvider).go(ready ? Routes.message(id) : Routes.home);
  }

  final taps = notifications.tappedLetterIds.listen(open);
  ref.onDispose(taps.cancel);
  unawaited(
    notifications.launchLetterId().then(
      (id) => id == null ? null : open(id),
      onError: (Object _) {},
    ),
  );
}

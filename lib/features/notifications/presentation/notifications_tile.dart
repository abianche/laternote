import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/notification_permission.dart';
import '../data/push_repository.dart';

/// Account row with the notification status; turns them on while the user
/// hasn't decided yet.
class NotificationsTile extends ConsumerWidget {
  const NotificationsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(notificationPermissionProvider);
    final undecided = permission.value == PushPermission.notDetermined;

    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: const Text('Notifications'),
      subtitle: Text(switch (permission) {
        AsyncData(value: PushPermission.granted) =>
          "On. You'll hear when a message opens.",
        AsyncData(value: PushPermission.denied) =>
          'Off. Turn them on in your device settings.',
        AsyncData(value: PushPermission.notDetermined) =>
          'Off. Tap to turn on.',
        AsyncError() => 'Not available on this device.',
        _ => '…',
      }),
      onTap: undecided
          ? () => ref.read(notificationPermissionProvider.notifier).request()
          : null,
    );
  }
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/notification_permission.dart';
import '../data/local_notifications_repository.dart';

/// Settings row with the notification status; turns them on while the user
/// hasn't decided yet.
class NotificationsTile extends ConsumerWidget {
  const NotificationsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permission = ref.watch(notificationPermissionProvider);
    final undecided = permission.value == NotificationAccess.notDetermined;
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.notifications_outlined),
      title: Text(l10n.notificationsTitle),
      subtitle: Text(switch (permission) {
        AsyncData(value: NotificationAccess.granted) => l10n.notificationsOn,
        AsyncData(value: NotificationAccess.denied) => l10n.notificationsDenied,
        AsyncData(value: NotificationAccess.notDetermined) =>
          l10n.notificationsUndecided,
        AsyncError() => l10n.notificationsUnavailable,
        _ => '…',
      }),
      onTap: undecided
          ? () => ref.read(notificationPermissionProvider.notifier).request()
          : null,
    );
  }
}

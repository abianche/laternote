import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/notification_permission.dart';
import '../data/local_notifications_repository.dart';

/// Explains notifications before the system prompt, as long as the user
/// hasn't decided. "Not now" asks again after the next seal; the system's
/// answer is final and changes only in the device settings.
Future<void> offerNotifications(BuildContext context, WidgetRef ref) async {
  final NotificationAccess permission;
  try {
    permission = await ref.read(notificationPermissionProvider.future);
  } on Object {
    return;
  }
  if (permission != NotificationAccess.notDetermined || !context.mounted) {
    return;
  }

  final l10n = AppLocalizations.of(context);
  final turnOn = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.notifications_outlined),
      title: Text(l10n.notificationsPromptTitle),
      content: Text(l10n.notificationsPromptContent),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.notificationsNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.notificationsTurnOn),
        ),
      ],
    ),
  );
  if (turnOn ?? false) {
    await ref.read(notificationPermissionProvider.notifier).request();
  }
}

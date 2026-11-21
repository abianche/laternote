import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/notification_permission.dart';
import '../data/push_repository.dart';

/// Explains notifications before the system prompt, as long as the user
/// hasn't decided. "Not now" asks again after the next seal; the system's
/// answer is final and changes only in the device settings.
Future<void> offerNotifications(BuildContext context, WidgetRef ref) async {
  final PushPermission permission;
  try {
    permission = await ref.read(notificationPermissionProvider.future);
  } on Object {
    return;
  }
  if (permission != PushPermission.notDetermined || !context.mounted) return;

  final turnOn = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.notifications_outlined),
      title: const Text('Know when it opens'),
      content: const Text(
        "We'll send a notification when a message is ready to read. "
        'It never shows what you wrote.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Not now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Turn on'),
        ),
      ],
    ),
  );
  if (turnOn ?? false) {
    await ref.read(notificationPermissionProvider.notifier).request();
  }
}

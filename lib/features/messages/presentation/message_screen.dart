import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/error_message.dart';
import '../application/compose_controllers.dart';
import '../application/inbox.dart';
import '../data/available_message.dart';
import 'delivery_format.dart';
import 'list_notice.dart';

/// A released message: its text and when it was written, set to open and
/// arrived. Opening it moves it from New to Read in the inbox.
class MessageScreen extends ConsumerWidget {
  const MessageScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(openedMessageProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Message')),
      body: switch (message) {
        AsyncData(value: final message?) => _MessageView(message),
        AsyncData() => const ListNotice(
          icon: Icons.lock_clock,
          text:
              'This message isn\'t available. It may not have opened yet, '
              'or it was deleted.',
        ),
        AsyncError() when !message.isLoading => ListNotice(
          icon: Icons.cloud_off_outlined,
          text: errorMessage(message)!,
          action: TextButton(
            onPressed: () => ref.invalidate(openedMessageProvider(id)),
            child: const Text('Retry'),
          ),
        ),
        _ => const ListNotice(progress: true, text: 'Opening your message…'),
      },
    );
  }
}

class _MessageView extends ConsumerWidget {
  const _MessageView(this.message);

  final AvailableMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    // Device-local times, labelled with the device's current zone.
    final zone = ref.watch(deviceTimezoneProvider).value;
    final dates = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Written on ${l10n.formatFullDate(message.createdAt)}',
            style: dates,
          ),
          Text(
            'Set to open ${formatDelivery(context, message.scheduledFor, zone)}',
            style: dates,
          ),
          Text(
            'Arrived ${formatDelivery(context, message.releasedAt, zone)}',
            style: dates,
          ),
          const Divider(height: 32),
          SelectableText(message.body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

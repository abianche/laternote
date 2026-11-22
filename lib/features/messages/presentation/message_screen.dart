import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.messageTitle)),
      body: switch (message) {
        AsyncData(value: final message?) => _MessageView(message),
        AsyncData() => ListNotice(
          icon: Icons.lock_clock,
          text: l10n.messageUnavailable,
        ),
        AsyncError() when !message.isLoading => ListNotice(
          icon: Icons.cloud_off_outlined,
          text: errorMessage(context, message)!,
          action: TextButton(
            onPressed: () => ref.invalidate(openedMessageProvider(id)),
            child: Text(l10n.commonRetry),
          ),
        ),
        _ => ListNotice(progress: true, text: l10n.messageOpening),
      },
    );
  }
}

class _MessageView extends ConsumerWidget {
  const _MessageView(this.message);

  final AvailableMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final material = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
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
            l10n.messageWrittenOn(material.formatFullDate(message.createdAt)),
            style: dates,
          ),
          Text(
            l10n.messageSetToOpen(
              formatDelivery(context, message.scheduledFor, zone),
            ),
            style: dates,
          ),
          Text(
            l10n.messageArrived(
              formatDelivery(context, message.releasedAt, zone),
            ),
            style: dates,
          ),
          const Divider(height: 32),
          SelectableText(message.body, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

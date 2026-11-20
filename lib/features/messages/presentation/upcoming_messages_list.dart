import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/error_message.dart';
import '../application/compose_controllers.dart';
import '../application/delete_message_controller.dart';
import '../application/upcoming_messages.dart';
import '../data/scheduled_message.dart';
import 'delivery_format.dart';
import 'list_notice.dart';

/// The user's sealed messages, showing only when each opens and when it
/// was sealed. Pull down to refresh. A message can be deleted until it
/// starts opening.
class UpcomingMessagesList extends ConsumerWidget {
  const UpcomingMessagesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(upcomingMessagesProvider);
    // Also keeps the controller alive while a deletion runs.
    ref.listen(deleteMessageControllerProvider, (previous, next) {
      if (!(previous?.isLoading ?? false) || next.isLoading) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(errorMessage(next) ?? 'Message deleted.')),
        );
    });
    Future<void> refresh() => ref.refresh(upcomingMessagesProvider.future);

    const loading = ListNotice(
      progress: true,
      text: 'Loading your sealed messages… You can start a new one meanwhile.',
    );

    return messages.when(
      data: (list) => RefreshIndicator(
        onRefresh: refresh,
        child: list.isEmpty
            ? const FillScroll(
                child: ListNotice(
                  icon: Icons.mark_email_unread_outlined,
                  text:
                      'Nothing sealed yet. Tap New message to write to your '
                      'future self.',
                ),
              )
            : ListView.builder(
                // Room for the floating action button.
                padding: const EdgeInsets.only(bottom: 88),
                itemCount: list.length,
                itemBuilder: (context, i) => _MessageTile(list[i]),
              ),
      ),
      // A refresh after an error keeps the error; show progress instead.
      error: (_, _) => messages.isLoading
          ? loading
          : RefreshIndicator(
              onRefresh: refresh,
              child: FillScroll(
                child: ListNotice(
                  icon: Icons.cloud_off_outlined,
                  text: errorMessage(messages)!,
                  action: TextButton(
                    onPressed: () => ref.invalidate(upcomingMessagesProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
      loading: () => loading,
    );
  }
}

class _MessageTile extends ConsumerWidget {
  const _MessageTile(this.message);

  final ScheduledMessage message;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    // `scheduledFor` is device-local, so label it with the device's current
    // zone, not the one saved at composition. Omitted while loading or failed.
    final zone = ref.watch(deviceTimezoneProvider).value;
    final sealed = MaterialLocalizations.of(
      context,
    ).formatShortDate(message.createdAt);
    final openingSoon = message.isOpeningSoon(now);
    final deleting = ref.watch(deleteMessageControllerProvider).isLoading;
    return ListTile(
      leading: Icon(openingSoon ? Icons.hourglass_top : Icons.lock_clock),
      title: Text(
        openingSoon
            ? 'Opening soon'
            : 'Opens ${formatDelivery(context, message.scheduledFor, zone)}',
      ),
      subtitle: Text('Sealed on $sealed'),
      // Past its time the server refuses deletion, so don't offer it.
      trailing: openingSoon
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: deleting ? null : () => _confirmDelete(context, ref),
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // Read before awaiting: this tile may be gone once the dialog closes.
    final controller = ref.read(deleteMessageControllerProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this sealed message?'),
        content: const Text(
          'It will never open. This can\'t be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await controller.delete(message.id);
    }
  }
}

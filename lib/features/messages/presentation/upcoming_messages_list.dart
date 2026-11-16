import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/error_message.dart';
import '../application/upcoming_messages.dart';
import '../data/scheduled_message.dart';
import 'delivery_format.dart';

/// The user's sealed messages, showing only when each opens and when it
/// was sealed. Pull down to refresh.
class UpcomingMessagesList extends ConsumerWidget {
  const UpcomingMessagesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(upcomingMessagesProvider);
    Future<void> refresh() => ref.refresh(upcomingMessagesProvider.future);

    const loading = _Notice(
      progress: true,
      text: 'Loading your sealed messages… You can start a new one meanwhile.',
    );

    return messages.when(
      data: (list) => RefreshIndicator(
        onRefresh: refresh,
        child: list.isEmpty
            ? const _FillScroll(
                child: _Notice(
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
              child: _FillScroll(
                child: _Notice(
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
    final sealed = MaterialLocalizations.of(
      context,
    ).formatShortDate(message.createdAt);
    final openingSoon = message.isOpeningSoon(now);
    return ListTile(
      leading: Icon(openingSoon ? Icons.hourglass_top : Icons.lock_clock),
      title: Text(
        openingSoon
            ? 'Opening soon'
            : 'Opens ${formatDelivery(context, message.scheduledFor, message.timezone)}',
      ),
      subtitle: Text('Sealed on $sealed'),
    );
  }
}

/// Fills the viewport while staying scrollable, so pull-to-refresh works
/// without a list.
class _FillScroll extends StatelessWidget {
  const _FillScroll({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(height: constraints.maxHeight, child: child),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.text,
    this.icon,
    this.progress = false,
    this.action,
  });

  final String text;
  final IconData? icon;
  final bool progress;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (progress) const CircularProgressIndicator(),
            if (icon case final icon?) Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(text, textAlign: TextAlign.center),
            ?action,
          ],
        ),
      ),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/error_message.dart';
import '../application/inbox.dart';
import '../data/available_message.dart';
import 'list_notice.dart';

/// Released messages: new ones first, then the read archive. Lists dates
/// only; tapping an item opens it. Pull down to refresh.
class InboxList extends ConsumerWidget {
  const InboxList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(availableMessagesProvider);
    Future<void> refresh() => ref.refresh(availableMessagesProvider.future);

    const loading = ListNotice(progress: true, text: 'Loading your inbox…');

    return messages.when(
      data: (list) {
        if (list.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: const FillScroll(
              child: ListNotice(
                icon: Icons.inbox_outlined,
                text:
                    'Nothing has opened yet. Your messages arrive here when '
                    'their time comes.',
              ),
            ),
          );
        }
        final fresh = list.where((m) => m.isNew).toList();
        final read = list.where((m) => !m.isNew).toList();
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            // Room for the floating action button.
            padding: const EdgeInsets.only(bottom: 88),
            children: [
              if (fresh.isNotEmpty) ...[
                const _Header('New'),
                for (final m in fresh) _InboxTile(m),
              ],
              if (read.isNotEmpty) ...[
                const _Header('Read'),
                for (final m in read) _InboxTile(m),
              ],
            ],
          ),
        );
      },
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
                    onPressed: () => ref.invalidate(availableMessagesProvider),
                    child: const Text('Retry'),
                  ),
                ),
              ),
            ),
      loading: () => loading,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile(this.message);

  final InboxItem message;

  @override
  Widget build(BuildContext context) {
    final l10n = MaterialLocalizations.of(context);
    final arrived = l10n.formatShortDate(message.releasedAt);
    final written = l10n.formatShortDate(message.createdAt);
    return ListTile(
      leading: Icon(
        message.isNew ? Icons.mark_email_unread : Icons.drafts_outlined,
      ),
      title: Text(
        'Arrived $arrived',
        style: message.isNew
            ? const TextStyle(fontWeight: FontWeight.bold)
            : null,
      ),
      subtitle: Text('Written on $written'),
      onTap: () => context.go(Routes.message(message.id)),
    );
  }
}

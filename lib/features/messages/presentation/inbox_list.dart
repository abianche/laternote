import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/ui/envelope.dart';
import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../application/inbox.dart';
import '../data/available_message.dart';
import 'envelope_tile.dart';
import 'list_notice.dart';

/// Ready letters: new ones first, then the read archive. Lists dates
/// only; tapping an item opens it. Pull down to refresh.
class InboxList extends ConsumerWidget {
  const InboxList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(availableMessagesProvider);
    final l10n = AppLocalizations.of(context);
    Future<void> refresh() => ref.refresh(availableMessagesProvider.future);

    final loading = ListNotice(progress: true, text: l10n.inboxLoading);

    return messages.when(
      data: (list) {
        if (list.isEmpty) {
          return RefreshIndicator(
            onRefresh: refresh,
            child: FillScroll(
              child: ListNotice(
                illustration: const Opacity(
                  opacity: 0.6,
                  child: Envelope(width: 120, flap: 1, sealed: false),
                ),
                text: l10n.inboxEmpty,
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
            padding: const EdgeInsets.only(top: 4, bottom: 88),
            children: [
              if (fresh.isNotEmpty) ...[
                EnvelopeGroupHeader(l10n.inboxNewHeader),
                for (final m in fresh) _InboxTile(m),
              ],
              if (read.isNotEmpty) ...[
                EnvelopeGroupHeader(l10n.inboxReadHeader),
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
                  text: errorMessage(context, messages)!,
                  action: TextButton(
                    onPressed: () => ref.invalidate(availableMessagesProvider),
                    child: Text(l10n.commonRetry),
                  ),
                ),
              ),
            ),
      loading: () => loading,
    );
  }
}

class _InboxTile extends StatelessWidget {
  const _InboxTile(this.message);

  final InboxItem message;

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final l10n = AppLocalizations.of(context);
    final arrived = material.formatShortDate(message.scheduledFor);
    final written = material.formatShortDate(message.createdAt);
    return EnvelopeTile(
      envelope: Envelope(
        width: 56,
        flap: message.isNew ? 0 : 1,
        undone: message.isNew ? 0 : 1,
        stamped: true,
      ),
      title: l10n.inboxArrived(arrived),
      subtitle: l10n.inboxWrittenOn(written),
      emphasized: message.isNew,
      faded: !message.isNew,
      onTap: () => context.go(Routes.message(message.id)),
    );
  }
}

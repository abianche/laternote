import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/ui/envelope.dart';
import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../application/compose_controllers.dart';
import '../application/delete_message_controller.dart';
import '../application/upcoming_messages.dart';
import '../data/scheduled_message.dart';
import 'countdown.dart';
import 'delivery_format.dart';
import 'envelope_tile.dart';
import 'list_notice.dart';

/// The user's sealed messages, showing only when each opens and when it
/// was sealed. Pull down to refresh. A message can be deleted until it
/// starts opening.
class UpcomingMessagesList extends ConsumerWidget {
  const UpcomingMessagesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(upcomingMessagesProvider);
    final l10n = AppLocalizations.of(context);
    // Also keeps the controller alive while a deletion runs.
    ref.listen(deleteMessageControllerProvider, (previous, next) {
      if (!(previous?.isLoading ?? false) || next.isLoading) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(errorMessage(context, next) ?? l10n.sealedDeleted),
          ),
        );
    });
    Future<void> refresh() => ref.refresh(upcomingMessagesProvider.future);

    final loading = ListNotice(progress: true, text: l10n.sealedLoading);

    return messages.when(
      data: (list) => RefreshIndicator(
        onRefresh: refresh,
        child: list.isEmpty
            ? FillScroll(
                child: ListNotice(
                  illustration: const Envelope(
                    width: 120,
                    flap: 1,
                    sealed: false,
                    calm: true,
                    letter: 0.45,
                  ),
                  text: l10n.sealedEmpty,
                ),
              )
            : ListView.builder(
                // Room for the floating action button.
                padding: const EdgeInsets.only(top: 12, bottom: 88),
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
                  text: errorMessage(context, messages)!,
                  action: TextButton(
                    onPressed: () => ref.invalidate(upcomingMessagesProvider),
                    child: Text(l10n.commonRetry),
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
    final l10n = AppLocalizations.of(context);
    return EnvelopeTile(
      envelope: openingSoon
          ? const _GlowingEnvelope()
          : const Envelope(width: 56, calm: true),
      title: openingSoon
          ? l10n.sealedOpeningSoon
          : l10n.sealedOpens(
              formatDelivery(context, message.scheduledFor, zone),
            ),
      subtitle: l10n.sealedOn(sealed),
      note: openingSoon
          ? null
          : l10n.sealedCountdown(
              formatCountdown(
                l10n,
                countdownBetween(now, message.scheduledFor),
              ),
            ),
      // Past its time the letter can't be deleted, so don't offer it.
      trailing: openingSoon
          ? null
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.commonDelete,
              onPressed: deleting ? null : () => _confirmDelete(context, ref),
            ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    // Read before awaiting: this tile may be gone once the dialog closes.
    final controller = ref.read(deleteMessageControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.sealedDeleteTitle),
        content: Text(l10n.sealedDeleteContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await controller.delete(message.id);
    }
  }
}

/// An envelope about to open: its button glows a few times, then stays warm.
class _GlowingEnvelope extends StatefulWidget {
  const _GlowingEnvelope();

  @override
  State<_GlowingEnvelope> createState() => _GlowingEnvelopeState();
}

class _GlowingEnvelopeState extends State<_GlowingEnvelope>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.value = 1;
    } else if (!_pulse.isAnimating && _pulse.value == 0) {
      // A cancelled ticker (on dispose) never completes this future.
      _pulse.repeat(reverse: true, count: 6).then((_) {
        if (mounted) _pulse.value = 1;
      });
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (context, _) => Envelope(
      width: 56,
      glow: 0.35 + 0.65 * Curves.easeInOut.transform(_pulse.value),
    ),
  );
}

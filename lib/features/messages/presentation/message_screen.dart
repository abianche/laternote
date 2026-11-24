import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/error_message.dart';
import '../../../core/ui/envelope.dart';
import '../../../core/ui/letter_paper.dart';
import '../../../core/ui/stitches.dart';
import '../../../core/ui/date_patch.dart';
import '../../../core/ui/knit.dart';
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
      body: Woven(
        child: switch (message) {
          AsyncData(value: final message?) => _MessageView(message),
          AsyncData() => ListNotice(
            illustration: const Envelope(width: 120),
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
      ),
    );
  }
}

/// The letter, on paper. The first time it's opened, the button comes undone
/// and the letter rises out of its envelope; a tap skips that.
class _MessageView extends ConsumerStatefulWidget {
  const _MessageView(this.message);

  final AvailableMessage message;

  @override
  ConsumerState<_MessageView> createState() => _MessageViewState();
}

class _MessageViewState extends ConsumerState<_MessageView>
    with SingleTickerProviderStateMixin {
  late final _opening = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
    // Already read: no envelope to open.
    value: widget.message.openedAt == null ? 0 : 1,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _opening.value = 1;
    } else if (_opening.isDismissed) {
      _opening.forward();
    }
  }

  @override
  void dispose() {
    _opening.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: _opening,
      child: _Letter(widget.message),
      builder: (context, letter) {
        final t = _opening.value;
        double phase(double from, double to) => Curves.easeInOut.transform(
          ((t - from) / (to - from)).clamp(0, 1),
        );
        final reveal = phase(0.8, 1);
        return Stack(
          children: [
            Opacity(opacity: reveal, child: letter),
            if (!_opening.isCompleted)
              Positioned.fill(
                child: Semantics(
                  button: true,
                  label: l10n.messageOpeningEnvelope,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _opening.value = 1,
                    child: Opacity(
                      opacity: 1 - reveal,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 80),
                          child: Envelope(
                            width: 220,
                            stamped: true,
                            undone: phase(0.05, 0.3),
                            flap: phase(0.3, 0.55),
                            letter: phase(0.55, 0.85),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Letter extends ConsumerWidget {
  const _Letter(this.message);

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.messageWrittenOn(
                        material.formatFullDate(message.createdAt),
                      ),
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              DatePatch(date: message.releasedAt, size: 72),
            ],
          ),
          const SizedBox(height: 20),
          LetterPaper(
            child: SelectableText(
              message.body,
              style: Knit.of(context).letter,
            ),
          ),
        ],
      ),
    );
  }
}

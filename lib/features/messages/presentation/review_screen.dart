import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/routes.dart';
import '../../../core/error_message.dart';
import '../../../core/ui/envelope.dart';
import '../../../core/ui/letter_paper.dart';
import '../../../core/ui/stitches.dart';
import '../../../core/ui/date_patch.dart';
import '../../../core/ui/knit.dart';
import '../../../core/ui/button_seal.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_form_widgets.dart';
import '../../notifications/presentation/notification_prompt.dart';
import '../application/compose_controllers.dart';
import '../application/message_draft.dart';
import 'delivery_format.dart';

/// The draft read back before sealing. "Seal message" tucks the letter into
/// its envelope while the message is saved; the button is sewn on once the
/// letter is saved, then the app moves on to the sealed list. A failed save
/// takes the letter back out and shows why.
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

/// Points along the sealing animation.
const _flapClosed = 0.7;
const _buttonSewn = 0.82;

class _ReviewScreenState extends ConsumerState<ReviewScreen>
    with SingleTickerProviderStateMixin {
  late final _sealing = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  );

  /// The letter going into the envelope; null before sealing starts.
  Future<void>? _tuckingIn;

  @override
  void dispose() {
    _sealing.dispose();
    super.dispose();
  }

  /// Jumps there instead when the OS turns animations off.
  Future<void> _animateTo(double target) async {
    if (!mounted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _sealing.value = target;
      return;
    }
    try {
      await _sealing.animateTo(target).orCancel;
    } on TickerCanceled {
      // The screen went away mid-animation.
    }
  }

  void _seal(MessageDraft draft) {
    final tuckingIn = _animateTo(_flapClosed);
    setState(() {
      _tuckingIn = tuckingIn;
    });
    ref.read(sealMessageControllerProvider.notifier).seal(draft);
  }

  Future<void> _sewButton() async {
    await _tuckingIn;
    await _animateTo(_buttonSewn);
    unawaited(HapticFeedback.heavyImpact());
    await _animateTo(1);
  }

  Future<void> _takeBackOut() async {
    await _tuckingIn;
    await _animateTo(0);
    if (!mounted) return;
    setState(() {
      _tuckingIn = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(composeDraftProvider).requireValue;
    final timezone = ref.watch(deviceTimezoneProvider).value;
    final state = ref.watch(sealMessageControllerProvider);
    final l10n = AppLocalizations.of(context);

    ref.listen(sealMessageControllerProvider, (_, next) async {
      if (next case AsyncData(value: final sealedFor?)) {
        await _sewButton();
        if (!context.mounted) return;
        await offerNotifications(context, ref);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.reviewSealedUntil(
                formatDelivery(context, sealedFor, timezone),
              ),
            ),
          ),
        );
        context.go(Routes.sealed);
      } else if (next is AsyncError) {
        await _takeBackOut();
      }
    });

    if (_tuckingIn != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.reviewTitle),
          automaticallyImplyLeading: false,
        ),
        body: Woven(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SealingStage(_sealing, label: l10n.reviewSealing),
                const SizedBox(height: 32),
                Text(
                  l10n.reviewSealing,
                  style: Knit.of(context).letter.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final deliverAt = draft.deliverAt;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
      body: Woven(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            LetterPaper(
              child: Text(draft.body, style: Knit.of(context).letter),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                DatePatch(date: deliverAt, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deliverAt == null
                            ? l10n.reviewNoDeliveryTime
                            : formatDelivery(context, deliverAt, timezone),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        l10n.reviewSealedHint,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            FormErrorText(errorMessage(context, state)),
            const SizedBox(height: 24),
            SubmitButton(
              label: l10n.reviewSealButton,
              isLoading: state.isLoading,
              onPressed: () => _seal(draft),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: state.isLoading ? null : () => context.pop(),
              child: Text(l10n.reviewEdit),
            ),
          ],
        ),
      ),
    );
  }
}

/// The letter slides into its envelope, the flap closes and a button is
/// sewn onto it, following [progress] from 0 to 1.
class _SealingStage extends StatelessWidget {
  const _SealingStage(this.progress, {required this.label});

  final Animation<double> progress;
  final String label;

  static const _width = 220.0;

  @override
  Widget build(BuildContext context) {
    final button = Envelope.buttonCenter(_width);
    final buttonSize = Envelope.buttonRadius(_width) / ButtonSeal.radiusFactor;
    const headroom = _width * 0.3;
    return Semantics(
      label: label,
      liveRegion: true,
      child: AnimatedBuilder(
        animation: progress,
        builder: (context, _) {
          final t = progress.value;
          double phase(
            double from,
            double to, [
            Curve curve = Curves.easeInOut,
          ]) => curve.transform(((t - from) / (to - from)).clamp(0, 1));
          final press = phase(_flapClosed, _buttonSewn, Curves.easeIn);
          return Padding(
            // Room for the letter above the envelope.
            padding: const EdgeInsets.only(top: headroom),
            child: SizedBox(
              width: _width,
              height: _width * Envelope.aspect,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Envelope(
                    width: _width,
                    sealed: false,
                    letter: 1 - phase(0, 0.45),
                    flap: 1 - phase(0.45, _flapClosed),
                  ),
                  if (t > _flapClosed)
                    Positioned(
                      left: button.dx - buttonSize / 2,
                      top: button.dy - buttonSize / 2,
                      // The button spins down onto the flap and is sewn on.
                      child: Opacity(
                        opacity: (press * 2).clamp(0, 1),
                        child: Transform.rotate(
                          angle: -2.4 * (1 - press),
                          child: Transform.scale(
                            scale: 2.4 - 1.4 * press,
                            child: ButtonSeal(size: buttonSize),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

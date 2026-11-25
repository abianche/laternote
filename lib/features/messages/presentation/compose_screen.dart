import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/clock.dart';
import '../../../core/error_message.dart';
import '../../../core/limits.dart';
import '../../../core/ui/letter_paper.dart';
import '../../../core/ui/stitches.dart';
import '../../../core/ui/date_patch.dart';
import '../../../core/ui/knit.dart';
import '../../../core/ui/button_seal.dart';
import '../../../l10n/app_localizations.dart';
import '../application/compose_controllers.dart';
import '../application/message_draft.dart';
import 'delivery_format.dart';

/// Edits the device-local draft. Nothing leaves the device until "Seal…"
/// leads to the review screen and the user seals it there.
class ComposeScreen extends ConsumerWidget {
  const ComposeScreen({super.key});

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.composeDiscardTitle),
        content: Text(l10n.composeDiscardContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.composeKeep),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.composeDiscard),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(composeDraftProvider.notifier).clear();
    if (context.mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(composeDraftProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.composeTitle),
        actions: [
          IconButton(
            tooltip: l10n.composeDiscardTooltip,
            icon: const Icon(Icons.delete_outline),
            onPressed: draft.hasValue ? () => _discard(context, ref) : null,
          ),
        ],
      ),
      body: Woven(
        child: switch (draft) {
          AsyncData() => const _ComposeForm(),
          AsyncError() => Center(child: Text(errorMessage(context, draft)!)),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _ComposeForm extends ConsumerStatefulWidget {
  const _ComposeForm();

  @override
  ConsumerState<_ComposeForm> createState() => _ComposeFormState();
}

class _ComposeFormState extends ConsumerState<_ComposeForm> {
  final _formKey = GlobalKey<FormState>();
  late final _bodyController = TextEditingController(
    text: ref.read(composeDraftProvider).requireValue.body,
  );
  late final AppLifecycleListener _lifecycle;
  bool _showDeliveryError = false;

  @override
  void initState() {
    super.initState();
    // The OS may kill a backgrounded app before a delayed save runs.
    _lifecycle = AppLifecycleListener(
      onHide: () => ref.read(composeDraftProvider.notifier).flush(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickDelivery() async {
    final now = ref.read(clockProvider)();
    final current = ref.read(composeDraftProvider).requireValue.deliverAt;
    final date = await showDatePicker(
      context: context,
      initialDate: current ?? now.add(const Duration(days: 1)),
      firstDate: DateUtils.dateOnly(now),
      lastDate: DateTime(now.year + 100),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(current ?? now),
    );
    if (time == null) return;
    ref
        .read(composeDraftProvider.notifier)
        .setDeliverAt(
          DateTime(date.year, date.month, date.day, time.hour, time.minute),
        );
    setState(() => _showDeliveryError = true);
  }

  void _review() {
    final bodyValid = _formKey.currentState!.validate();
    final draft = ref.read(composeDraftProvider).requireValue;
    final deliveryValid =
        validateDeliverAt(draft.deliverAt, ref.read(clockProvider)()) == null;
    setState(() => _showDeliveryError = true);
    if (bodyValid && deliveryValid) context.go(Routes.composeReview);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final knit = Knit.of(context);
    final draft = ref.watch(composeDraftProvider).requireValue;
    final saveFailed = ref.watch(draftSaveFailedProvider);
    final timezone = ref.watch(deviceTimezoneProvider).value;
    final deliverAt = draft.deliverAt;
    final deliveryError = _showDeliveryError
        ? validateDeliverAt(deliverAt, ref.read(clockProvider)())
        : null;

    return Form(
      key: _formKey,
      // Not a lazy list: the status line below the letter is always built.
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LetterPaper(
              child: TextFormField(
                controller: _bodyController,
                style: knit.letter,
                // Written straight onto the paper's rules: no field chrome.
                decoration: InputDecoration(
                  hintText: l10n.composeBodyHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                minLines: 10,
                maxLines: null,
                maxLength: maxMessageLength,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  final problem = validateBody(value);
                  return problem == null ? null : validationText(l10n, problem);
                },
                onChanged: ref.read(composeDraftProvider.notifier).setBody,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _pickDelivery,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Row(
                    children: [
                      DatePatch(date: deliverAt, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.composeDeliverOn,
                              style: knit.label.copyWith(
                                color: theme.colorScheme.secondary,
                              ),
                            ),
                            Text(
                              deliverAt == null
                                  ? l10n.composePickDateTime
                                  : formatDelivery(
                                      context,
                                      deliverAt,
                                      timezone,
                                    ),
                              style: theme.textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.edit_calendar_outlined,
                        color: theme.hintColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (deliveryError != null)
              Text(
                validationText(l10n, deliveryError),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _review,
              // A cream disc so the red sewn button shows on the red one.
              icon: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary,
                  shape: BoxShape.circle,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(1),
                  child: ButtonSeal(size: 22),
                ),
              ),
              label: Text(l10n.composeSeal),
            ),
            const SizedBox(height: 8),
            Text(
              saveFailed ? l10n.composeSaveFailed : l10n.composeSavedLocally,
              style: theme.textTheme.bodySmall?.copyWith(
                color: saveFailed
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

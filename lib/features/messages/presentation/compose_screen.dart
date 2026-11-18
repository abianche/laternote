import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/clock.dart';
import '../../../core/error_message.dart';
import '../application/compose_controllers.dart';
import '../application/message_draft.dart';
import 'delivery_format.dart';

/// Edits the device-local draft. Nothing leaves the device until "Seal…"
/// leads to the review screen and the user seals it there.
class ComposeScreen extends ConsumerWidget {
  const ComposeScreen({super.key});

  Future<void> _discard(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard draft?'),
        content: const Text('It will be deleted from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('New message'),
        actions: [
          IconButton(
            tooltip: 'Discard draft',
            icon: const Icon(Icons.delete_outline),
            onPressed: draft.hasValue ? () => _discard(context, ref) : null,
          ),
        ],
      ),
      body: switch (draft) {
        AsyncData() => const _ComposeForm(),
        AsyncError() => Center(child: Text(errorMessage(draft)!)),
        _ => const Center(child: CircularProgressIndicator()),
      },
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
  bool _showDeliveryError = false;

  @override
  void dispose() {
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
    final draft = ref.watch(composeDraftProvider).requireValue;
    final timezone = ref.watch(deviceTimezoneProvider).value;
    final deliverAt = draft.deliverAt;
    final deliveryError = _showDeliveryError
        ? validateDeliverAt(deliverAt, ref.read(clockProvider)())
        : null;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(
              labelText: 'Your message',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            minLines: 8,
            maxLines: null,
            maxLength: maxMessageLength,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            validator: validateBody,
            onChanged: ref.read(composeDraftProvider.notifier).setBody,
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.schedule),
            title: const Text('Deliver on'),
            subtitle: Text(
              deliverAt == null
                  ? 'Pick a date and time'
                  : formatDelivery(context, deliverAt, timezone),
            ),
            onTap: _pickDelivery,
          ),
          if (deliveryError != null)
            Text(
              deliveryError,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 24),
          FilledButton(onPressed: _review, child: const Text('Seal…')),
          const SizedBox(height: 8),
          Text(
            'Your draft is saved on this device only. Nothing is sent until you seal it.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

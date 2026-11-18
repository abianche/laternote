import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/clock.dart';
import '../application/compose_controllers.dart';
import '../application/message_draft.dart';
import 'delivery_format.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key});

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _bodyController = TextEditingController(
    text: ref.read(composeDraftProvider).body,
  );
  bool _showDeliveryError = false;

  @override
  void dispose() {
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _pickDelivery() async {
    final now = ref.read(clockProvider)();
    final current = ref.read(composeDraftProvider).deliverAt;
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
    final draft = ref.read(composeDraftProvider);
    final deliveryValid = validateDeliverAt(draft.deliverAt, ref.read(clockProvider)()) == null;
    setState(() => _showDeliveryError = true);
    if (bodyValid && deliveryValid) context.go(Routes.composeReview);
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(composeDraftProvider);
    final timezone = ref.watch(deviceTimezoneProvider).value;
    final deliverAt = draft.deliverAt;
    final deliveryError = _showDeliveryError ? validateDeliverAt(deliverAt, ref.read(clockProvider)()) : null;

    return Scaffold(
      appBar: AppBar(title: const Text('New message')),
      body: Form(
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
                deliverAt == null ? 'Pick a date and time' : formatDelivery(context, deliverAt, timezone),
              ),
              onTap: _pickDelivery,
            ),
            if (deliveryError != null)
              Text(
                deliveryError,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _review, child: const Text('Review')),
          ],
        ),
      ),
    );
  }
}

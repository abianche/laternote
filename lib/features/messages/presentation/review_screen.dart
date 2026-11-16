import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/error_message.dart';
import '../../auth/presentation/auth_form_widgets.dart';
import '../application/compose_controllers.dart';
import 'delivery_format.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(composeDraftProvider);
    final timezone = ref.watch(deviceTimezoneProvider).value;
    final state = ref.watch(sealMessageControllerProvider);
    final deliverAt = draft.deliverAt;

    ref.listen(sealMessageControllerProvider, (_, next) {
      if (next case AsyncData(value: true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sealed until ${formatDelivery(context, deliverAt!, timezone)}.',
            ),
          ),
        );
        context.go(Routes.home);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(draft.body),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_clock),
            title: Text(
              deliverAt == null
                  ? 'No delivery time'
                  : formatDelivery(context, deliverAt, timezone),
            ),
            subtitle: const Text(
              "Once sealed, you can't read it until then.",
            ),
          ),
          FormErrorText(errorMessage(state)),
          const SizedBox(height: 24),
          SubmitButton(
            label: 'Seal message',
            isLoading: state.isLoading,
            onPressed: () =>
                ref.read(sealMessageControllerProvider.notifier).seal(draft),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: state.isLoading ? null : () => context.pop(),
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }
}

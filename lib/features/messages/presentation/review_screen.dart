import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_form_widgets.dart';
import '../../notifications/presentation/notification_prompt.dart';
import '../application/compose_controllers.dart';
import 'delivery_format.dart';

class ReviewScreen extends ConsumerWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(composeDraftProvider).requireValue;
    final timezone = ref.watch(deviceTimezoneProvider).value;
    final state = ref.watch(sealMessageControllerProvider);
    final deliverAt = draft.deliverAt;
    final l10n = AppLocalizations.of(context);

    ref.listen(sealMessageControllerProvider, (_, next) async {
      if (next case AsyncData(value: final sealedFor?)) {
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
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.reviewTitle)),
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
                  ? l10n.reviewNoDeliveryTime
                  : formatDelivery(context, deliverAt, timezone),
            ),
            subtitle: Text(l10n.reviewSealedHint),
          ),
          FormErrorText(errorMessage(context, state)),
          const SizedBox(height: 24),
          SubmitButton(
            label: l10n.reviewSealButton,
            isLoading: state.isLoading,
            onPressed: () =>
                ref.read(sealMessageControllerProvider.notifier).seal(draft),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: state.isLoading ? null : () => context.pop(),
            child: Text(l10n.reviewEdit),
          ),
        ],
      ),
    );
  }
}

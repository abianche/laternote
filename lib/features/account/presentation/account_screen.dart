import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../../core/error_message.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/application/auth_controllers.dart';
import '../../notifications/presentation/notifications_tile.dart';
import '../application/account_deletion.dart';
import '../application/current_email_provider.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _requestAccountDeletion(
    BuildContext context,
    String? email,
  ) async {
    final launched = await launchUrl(deletionRequestUri(email));
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            ).accountMailAppMissing(deletionRequestEmail),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(signOutControllerProvider, (_, next) {
      final message = errorMessage(context, next);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    final signOut = ref.watch(signOutControllerProvider);
    final email = ref.watch(currentEmailProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(l10n.accountSignedInAs),
            subtitle: Text(switch (email) {
              AsyncData(value: final email?) => email,
              AsyncLoading() => '…',
              _ => l10n.accountUnknownEmail,
            }),
          ),
          const Divider(),
          const NotificationsTile(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.accountPrivacy),
            onTap: () => context.go(Routes.privacy),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.accountRequestDeletion),
            onTap: () => _requestAccountDeletion(context, email.value),
          ),
          const Divider(),
          ListTile(
            leading: signOut.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            title: Text(l10n.accountSignOut),
            onTap: signOut.isLoading
                ? null
                : () => ref.read(signOutControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

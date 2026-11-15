import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes.dart';
import '../../auth/application/auth_controllers.dart';
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
        const SnackBar(
          content: Text(
            'Could not open a mail app. Email $deletionRequestEmail '
            'directly to request deletion.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(signOutControllerProvider, (_, next) {
      final message = errorMessage(next);
      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
    final signOut = ref.watch(signOutControllerProvider);
    final email = ref.watch(currentEmailProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Signed in as'),
            subtitle: Text(switch (email) {
              AsyncData(value: final email?) => email,
              AsyncLoading() => '…',
              _ => 'Unknown',
            }),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy & data'),
            onTap: () => context.go(Routes.privacy),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Request account deletion'),
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
            title: const Text('Sign out'),
            onTap: signOut.isLoading
                ? null
                : () => ref.read(signOutControllerProvider.notifier).signOut(),
          ),
        ],
      ),
    );
  }
}

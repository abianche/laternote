import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../auth/auth_error.dart';
import 'privacy_screen.dart';

/// Placeholder support address for the MVP's manual deletion process.
/// Replace once a real support inbox exists.
const _deletionRequestEmail = 'privacy@laternote.app';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(describeAuthError(error))),
      );
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _requestAccountDeletion() async {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';
    final uri = Uri(
      scheme: 'mailto',
      path: _deletionRequestEmail,
      query:
          'subject=${Uri.encodeComponent('Account deletion request')}'
          '&body=${Uri.encodeComponent(
            'Please delete the Laternote account for: $email',
          )}',
    );
    final launched = await launchUrl(uri);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open a mail app. Email $_deletionRequestEmail '
            'directly to request deletion.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email;
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Signed in as'),
            subtitle: Text(email ?? 'Unknown'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy & data'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyScreen()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: const Text('Request account deletion'),
            onTap: _requestAccountDeletion,
          ),
          const Divider(),
          ListTile(
            leading: _isSigningOut
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.logout),
            title: const Text('Sign out'),
            onTap: _isSigningOut ? null : _signOut,
          ),
        ],
      ),
    );
  }
}

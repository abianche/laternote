import 'package:material_ui/material_ui.dart';

/// Plain-language privacy notice. Keep in sync with PRIVACY.md.
const privacySections = <(String, String)>[
  (
    'Drafts stay on this device',
    'While you write, your draft is saved encrypted on this device only. '
        'It is never sent to our servers, and it is deleted when you seal '
        'it, discard it, or sign out.',
  ),
  (
    'Sealed messages',
    'When you seal a message we store it with its opening time, time '
        'zone and status. Access is enforced by the database itself, not '
        'just the app: only your account can see your messages, and nobody, '
        'not even you, can read one before it opens.',
  ),
  (
    'Notifications',
    'A notification only says "A message is ready". It never contains '
        'what you wrote, so nothing private shows on your lock screen. To '
        'send it we keep a notification address for this device from '
        'Firebase Cloud Messaging, removed when you sign out.',
  ),
  (
    'No tracking',
    'Laternote has no analytics, ads or crash reporting. Our logs record '
        'counts only, never message content.',
  ),
  (
    'Deleting your account',
    'During this early MVP, account deletion is handled manually: use '
        '"Request account deletion" on the Account screen to send a '
        'request. We delete your account, messages and device addresses by '
        'hand, normally within a few business days, and confirm by email.',
  ),
  (
    'Backups',
    'Encrypted backups age out after about 30 days. If one is ever '
        'restored, deletion requests made since then are applied again.',
  ),
];

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & data')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          for (final (title, text) in privacySections) ...[
            Text(title, style: titleStyle),
            const SizedBox(height: 8),
            Text(text),
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & data')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'What we store',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Laternote stores the messages you write, their scheduled '
            'delivery time, and a device token used to notify you when a '
            'message becomes available. Only you can access your own '
            'messages.',
          ),
          const SizedBox(height: 24),
          Text(
            'Deleting your account',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'During this early MVP, account deletion is handled manually: '
            'use "Request account deletion" on the Account screen to send '
            'a request. We will delete your account and all associated '
            'messages and device tokens by hand, normally within a few '
            'business days, and confirm by email once it is done.',
          ),
          const SizedBox(height: 24),
          Text(
            'More detail',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text('See PRIVACY.md in the project repository.'),
        ],
      ),
    );
  }
}

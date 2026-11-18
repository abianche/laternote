import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../messages/presentation/upcoming_messages_list.dart';

/// Signed-in landing page: the user's sealed messages.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laternote'),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            tooltip: 'Account',
            onPressed: () => context.go(Routes.account),
          ),
        ],
      ),
      body: const UpcomingMessagesList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.compose),
        icon: const Icon(Icons.edit_outlined),
        label: const Text('New message'),
      ),
    );
  }
}

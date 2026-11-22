import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../messages/presentation/inbox_list.dart';
import '../../messages/presentation/upcoming_messages_list.dart';

/// Home's tabs, in order.
enum HomeTab { inbox, sealed }

/// Signed-in landing page: the inbox of released messages and the list of
/// sealed ones, in two tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, this.initialTab = HomeTab.inbox});

  final HomeTab initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: HomeTab.values.length,
      initialIndex: initialTab.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Laternote'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle_outlined),
              tooltip: l10n.homeAccountTooltip,
              onPressed: () => context.go(Routes.account),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.homeInboxTab),
              Tab(text: l10n.homeSealedTab),
            ],
          ),
        ),
        body: const TabBarView(
          children: [InboxList(), UpcomingMessagesList()],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => context.go(Routes.compose),
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.homeNewMessage),
        ),
      ),
    );
  }
}

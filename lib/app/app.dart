import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/messages/application/draft_cleanup.dart';
import '../features/notifications/application/ready_notifications.dart';
import 'deep_link_routing.dart';
import 'localization.dart';
import 'notification_routing.dart';
import 'router.dart';
import 'theme.dart';

class LaternoteApp extends ConsumerWidget {
  const LaternoteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref
      ..watch(draftCleanupProvider)
      ..watch(readyNotificationsProvider)
      ..watch(notificationRoutingProvider)
      ..watch(deepLinkRoutingProvider);
    return MaterialApp.router(
      title: 'Laternote',
      theme: appTheme,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: appSupportedLocales,
      routerConfig: ref.watch(routerProvider),
    );
  }
}

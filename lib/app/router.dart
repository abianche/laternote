import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/home/presentation/home_shell.dart';
import '../features/messages/presentation/compose_screen.dart';
import '../features/messages/presentation/message_screen.dart';
import '../features/messages/presentation/review_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'routes.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final router = GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        builder: (_, state) {
          final tab = state.uri.queryParameters['tab'] == 'sealed'
              ? HomeTab.sealed
              : HomeTab.inbox;
          // Keyed so going to the other tab rebuilds with it selected.
          return HomeShell(key: ValueKey(tab), initialTab: tab);
        },
        routes: [
          GoRoute(
            path: 'compose',
            builder: (_, _) => const ComposeScreen(),
            routes: [
              GoRoute(
                path: 'review',
                builder: (_, _) => const ReviewScreen(),
              ),
            ],
          ),
          GoRoute(
            path: 'messages/:id',
            builder: (_, state) =>
                MessageScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'settings',
            builder: (_, _) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'privacy',
                builder: (_, _) => const PrivacyScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
}

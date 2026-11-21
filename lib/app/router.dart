import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/account/presentation/account_screen.dart';
import '../features/account/presentation/privacy_screen.dart';
import '../features/auth/application/auth_status_provider.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/data/auth_status.dart';
import '../features/auth/presentation/forgot_password_screen.dart';
import '../features/auth/presentation/reset_password_screen.dart';
import '../features/auth/presentation/sign_in_screen.dart';
import '../features/auth/presentation/sign_up_screen.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/messages/presentation/compose_screen.dart';
import '../features/messages/presentation/message_screen.dart';
import '../features/messages/presentation/review_screen.dart';
import 'routes.dart';

part 'router.g.dart';

/// Where to send the user for [uri] given their [status], or null to stay.
/// Password recovery wins over everything; signed-out users are kept
/// inside the sign-in flow, remembering a message they were opening (e.g.
/// from a notification); signed-in users are kept out of it, continuing to
/// that message.
String? authRedirect(AuthStatus status, Uri uri) {
  final location = uri.path;
  final inSignInFlow =
      location == Routes.signIn || location.startsWith('${Routes.signIn}/');
  return switch (status) {
    PasswordRecovery() =>
      location == Routes.resetPassword ? null : Routes.resetPassword,
    SignedOut() => inSignInFlow ? null : Routes.signInThen(location),
    SignedIn() when inSignInFlow => switch (uri.queryParameters['from']) {
      final from? when Routes.isMessage(from) => from,
      _ => Routes.home,
    },
    SignedIn() => location == Routes.resetPassword ? Routes.home : null,
  };
}

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final status = ValueNotifier<AuthStatus>(
    ref.read(authRepositoryProvider).currentStatus,
  );
  ref.listen(authStatusProvider, (_, next) {
    if (next case AsyncData(:final value)) status.value = value;
  });

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: status,
    redirect: (_, state) => authRedirect(status.value, state.uri),
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
            path: 'account',
            builder: (_, _) => const AccountScreen(),
            routes: [
              GoRoute(
                path: 'privacy',
                builder: (_, _) => const PrivacyScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => const SignInScreen(),
        routes: [
          GoRoute(path: 'sign-up', builder: (_, _) => const SignUpScreen()),
          GoRoute(
            path: 'forgot-password',
            builder: (_, _) => const ForgotPasswordScreen(),
          ),
        ],
      ),
      GoRoute(
        path: Routes.resetPassword,
        builder: (_, _) => const ResetPasswordScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    status.dispose();
  });
  return router;
}

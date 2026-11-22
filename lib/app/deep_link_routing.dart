import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/app_error.dart';
import '../core/deep_link.dart';
import '../core/deep_link_repository.dart';
import '../features/auth/data/auth_repository.dart';
import 'router.dart';
import 'routes.dart';

part 'deep_link_routing.g.dart';

/// Follows every link the OS hands to the app, whether it launched the app
/// or arrived while it was in the background or foreground. Auth links are
/// exchanged for a session, then the user lands on the screen for that
/// kind of link; anything that fails lands on an explanation.
@Riverpod(keepAlive: true)
void deepLinkRouting(Ref ref) {
  void go(String location) => ref.read(routerProvider).go(location);

  Future<void> follow(Uri uri) async {
    switch (parseDeepLink(uri)) {
      case BrokenLink(:final problem):
        go(Routes.linkProblemFor(problem));
      case AuthCallbackLink(:final kind, :final uri):
        try {
          await ref.read(authRepositoryProvider).completeSignInFromLink(uri);
        } on AppError catch (error) {
          if (ref.mounted) go(Routes.linkProblemFor(_problemFor(error)));
          return;
        }
        if (!ref.mounted) return;
        go(switch (kind) {
          AuthLinkKind.passwordReset => Routes.resetPassword,
          AuthLinkKind.emailConfirmation => Routes.emailConfirmed,
          AuthLinkKind.magicLink => Routes.home,
        });
    }
  }

  final links = ref
      .watch(deepLinkRepositoryProvider)
      .links
      .listen(follow, onError: (Object _) {});
  ref.onDispose(links.cancel);
}

LinkProblem _problemFor(AppError error) => switch (error) {
  NetworkError() => LinkProblem.network,
  AuthError(failure: AuthFailure.linkExpired) => LinkProblem.expired,
  _ => LinkProblem.invalid,
};

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laternote/app/deep_link_routing.dart';
import 'package:laternote/app/router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/deep_link.dart';
import 'package:laternote/core/deep_link_repository.dart';
import 'package:laternote/features/auth/data/auth_repository.dart';
import 'package:material_ui/material_ui.dart';

import '../core/fake_deep_link_repository.dart';
import '../features/auth/fake_auth_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeDeepLinkRepository links;
  late FakeAuthRepository auth;
  late GoRouter router;

  String location() => router.routeInformationProvider.value.uri.toString();

  Future<void> start() async {
    final container = ProviderContainer.test(
      overrides: [
        deepLinkRepositoryProvider.overrideWithValue(links),
        authRepositoryProvider.overrideWithValue(auth),
        routerProvider.overrideWithValue(router),
      ],
    );
    container.listen(deepLinkRoutingProvider, (_, _) {});
    await pumpEventQueue();
  }

  Future<void> open(String link) async {
    links.incoming.add(Uri.parse(link));
    await pumpEventQueue();
  }

  setUp(() {
    links = FakeDeepLinkRepository();
    addTearDown(links.close);
    auth = FakeAuthRepository();
    router = GoRouter(
      routes: [
        for (final path in [
          Routes.home,
          Routes.resetPassword,
          Routes.emailConfirmed,
          Routes.linkProblem,
        ])
          GoRoute(path: path, builder: (_, _) => const SizedBox()),
      ],
    );
    addTearDown(router.dispose);
  });

  test('signs in from each auth link and opens its screen', () async {
    await start();
    for (final (kind, route) in [
      (AuthLinkKind.passwordReset, Routes.resetPassword),
      (AuthLinkKind.emailConfirmation, Routes.emailConfirmed),
      (AuthLinkKind.magicLink, Routes.home),
    ]) {
      router.go(Routes.linkProblem);
      final link = '${authLinkUrl(kind)}?code=abc';

      await open(link);

      expect(auth.calls.last, 'completeSignInFromLink:$link');
      expect(location(), route, reason: kind.name);
    }
  });

  test(
    'a link that failed at Supabase is explained without signing in',
    () async {
      await start();

      await open('io.laternote://auth/reset-password#error_code=otp_expired');

      expect(auth.calls, isEmpty);
      expect(location(), Routes.linkProblemFor(LinkProblem.expired));
    },
  );

  test('an unrecognized link is explained', () async {
    await start();

    await open('io.laternote://auth/elsewhere?code=abc');

    expect(auth.calls, isEmpty);
    expect(location(), Routes.linkProblemFor(LinkProblem.unrecognized));
  });

  test('a failed sign-in is explained by its cause', () async {
    await start();
    for (final (error, problem) in [
      (const AuthError(AuthFailure.linkExpired), LinkProblem.expired),
      (const AuthError(AuthFailure.other), LinkProblem.invalid),
      (const NetworkError(), LinkProblem.network),
    ]) {
      auth.error = error;

      await open('${authLinkUrl(AuthLinkKind.magicLink)}?code=abc');

      expect(location(), Routes.linkProblemFor(problem));
    }
  });
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/app/theme.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/auth/data/auth_repository.dart';
import 'package:laternote/core/ui/button_seal.dart';
import 'package:laternote/features/auth/presentation/sign_in_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: const MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        home: SignInScreen(),
      ),
    ),
  );

  setUp(() => repository = FakeAuthRepository());

  testWidgets('shows validation errors for empty fields', (tester) async {
    await pumpScreen(tester);

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('shows the error from a failed sign-in', (tester) async {
    repository.error = const AuthError(AuthFailure.invalidCredentials);
    await pumpScreen(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(repository.calls, ['signIn:a@b.co:secret123']);
    expect(find.text('Wrong email or password.'), findsOneWidget);
  });

  testWidgets('builds under the app theme with button, wordmark and tagline', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          theme: appTheme,
          localizationsDelegates: appLocalizationsDelegates,
          home: const SignInScreen(),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(ButtonSeal), findsOneWidget);
    expect(find.text('Laternote'), findsOneWidget);
    expect(find.text("A message to the person you'll become."), findsOneWidget);
    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.style, isNull, reason: 'styled by the theme');
  });
}

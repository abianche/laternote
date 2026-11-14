import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:laternote/features/auth/sign_in_screen.dart';

void main() {
  testWidgets('SignInScreen shows validation errors for empty fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignInScreen()),
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter a password.'), findsOneWidget);
  });
}

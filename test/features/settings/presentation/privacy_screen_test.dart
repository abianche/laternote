import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/features/settings/presentation/privacy_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('explains how content and data are handled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        home: PrivacyScreen(),
      ),
    );

    for (final title in [
      'Drafts stay on this device',
      'Sealed messages stay on this device',
      'Notifications',
      'No tracking',
      'Deleting your messages',
      'Backups',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 100);
      expect(find.text(title), findsOneWidget);
    }
    expect(find.textContaining('PRIVACY.md'), findsNothing);
    final localOnly = find.textContaining(
      'never leave it except in backups of your device or exports you make',
    );
    await tester.scrollUntilVisible(localOnly, -100);
    expect(localOnly, findsOneWidget);
  });
}

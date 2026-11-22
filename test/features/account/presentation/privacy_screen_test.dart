import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/account/presentation/privacy_screen.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('explains how content and data are handled', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PrivacyScreen()));

    for (final title in [
      'Drafts stay on this device',
      'Sealed messages',
      'Notifications',
      'No tracking',
      'Deleting your account',
      'Backups',
    ]) {
      await tester.scrollUntilVisible(find.text(title), 100);
      expect(find.text(title), findsOneWidget);
    }
    expect(find.textContaining('PRIVACY.md'), findsNothing);
  });
}

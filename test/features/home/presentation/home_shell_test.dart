import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/features/home/presentation/home_shell.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:material_ui/material_ui.dart';

import '../../messages/fake_messages_repository.dart';

void main() {
  Future<void> pump(WidgetTester tester, HomeShell shell) => tester.pumpWidget(
    ProviderScope(
      overrides: [
        messagesRepositoryProvider.overrideWithValue(
          FakeMessagesRepository(),
        ),
        deviceTimezoneProvider.overrideWithValue(
          const AsyncData('Europe/Rome'),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        home: shell,
      ),
    ),
  );

  testWidgets('opens on the inbox and switches to sealed messages', (
    tester,
  ) async {
    await pump(tester, const HomeShell());
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing has opened yet'), findsOneWidget);

    await tester.tap(find.text('Sealed'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing sealed yet'), findsOneWidget);
  });

  testWidgets('can open on the sealed tab', (tester) async {
    await pump(tester, const HomeShell(initialTab: HomeTab.sealed));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing sealed yet'), findsOneWidget);
  });
}

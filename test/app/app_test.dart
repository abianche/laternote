import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/app.dart';
import 'package:laternote/app/theme.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:material_ui/material_ui.dart';

import '../features/messages/fake_messages_repository.dart';
import '../features/notifications/fake_local_notifications_repository.dart';

void main() {
  Future<void> launch(WidgetTester tester) async {
    final notifications = FakeLocalNotificationsRepository();
    addTearDown(notifications.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messagesRepositoryProvider.overrideWithValue(
            FakeMessagesRepository(),
          ),
          localNotificationsRepositoryProvider.overrideWithValue(
            notifications,
          ),
          deviceTimezoneProvider.overrideWithValue(
            const AsyncData('Europe/Rome'),
          ),
        ],
        child: const LaternoteApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('a fresh launch opens straight to home', (tester) async {
    await launch(tester);

    expect(find.text('Inbox'), findsOneWidget);
    expect(find.textContaining('Nothing has opened yet'), findsOneWidget);
    expect(find.text('New message'), findsOneWidget);
  });

  testWidgets('follows the OS light/dark setting', (tester) async {
    await launch(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, appTheme);
    expect(app.darkTheme, appDarkTheme);
    expect(app.themeMode, ThemeMode.system);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Inbox'))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('settings has notifications, export, import and privacy', (
    tester,
  ) async {
    await launch(tester);

    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(4));
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Export letters'), findsOneWidget);
    expect(find.text('Import letters'), findsOneWidget);

    await tester.tap(find.text('Privacy & data'));
    await tester.pumpAndSettle();

    expect(find.text('Sealed messages stay on this device'), findsOneWidget);
  });
}

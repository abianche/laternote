import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:laternote/features/notifications/presentation/notification_prompt.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_local_notifications_repository.dart';

void main() {
  late FakeLocalNotificationsRepository notifications;
  var done = false;

  Future<void> offer(WidgetTester tester) async {
    done = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localNotificationsRepositoryProvider.overrideWithValue(notifications),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          home: Consumer(
            builder: (context, ref, _) => TextButton(
              onPressed: () async {
                await offerNotifications(context, ref);
                done = true;
              },
              child: const Text('Seal'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Seal'));
    await tester.pumpAndSettle();
  }

  testWidgets('explains first, then asks the system', (tester) async {
    notifications = FakeLocalNotificationsRepository(
      status: NotificationAccess.notDetermined,
    );
    await offer(tester);

    expect(find.text('Know when it opens'), findsOneWidget);
    expect(find.textContaining('never shows what you wrote'), findsOneWidget);
    expect(notifications.calls, isEmpty);

    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();

    expect(notifications.calls, ['requestPermission']);
    expect(done, isTrue);
  });

  testWidgets('"Not now" skips the system prompt', (tester) async {
    notifications = FakeLocalNotificationsRepository(
      status: NotificationAccess.notDetermined,
    );
    await offer(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(notifications.calls, isEmpty);
    expect(done, isTrue);
  });

  for (final decided in [
    NotificationAccess.granted,
    NotificationAccess.denied,
  ]) {
    testWidgets('stays quiet once ${decided.name}', (tester) async {
      notifications = FakeLocalNotificationsRepository(status: decided);
      await offer(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(done, isTrue);
    });
  }
}

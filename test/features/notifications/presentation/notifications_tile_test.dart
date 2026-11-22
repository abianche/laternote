import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';
import 'package:laternote/features/notifications/presentation/notifications_tile.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_push_repository.dart';

void main() {
  late FakePushRepository push;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pushRepositoryProvider.overrideWithValue(push)],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          home: Scaffold(body: NotificationsTile()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows when they are on', (tester) async {
    push = FakePushRepository();
    await pump(tester);

    expect(find.textContaining('On.'), findsOneWidget);
  });

  testWidgets('points to the device settings when denied', (tester) async {
    push = FakePushRepository(status: PushPermission.denied);
    await pump(tester);
    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(find.textContaining('device settings'), findsOneWidget);
    expect(push.calls, isEmpty);
  });

  testWidgets('turns them on while undecided', (tester) async {
    push = FakePushRepository(status: PushPermission.notDetermined);
    await pump(tester);
    expect(find.text('Off. Tap to turn on.'), findsOneWidget);

    await tester.tap(find.byType(ListTile));
    await tester.pumpAndSettle();

    expect(push.calls, ['requestPermission']);
    expect(find.textContaining('On.'), findsOneWidget);
  });
}

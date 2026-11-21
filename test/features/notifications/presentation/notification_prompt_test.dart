import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';
import 'package:laternote/features/notifications/presentation/notification_prompt.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_push_repository.dart';

void main() {
  late FakePushRepository push;
  var done = false;

  Future<void> offer(WidgetTester tester) async {
    done = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [pushRepositoryProvider.overrideWithValue(push)],
        child: MaterialApp(
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
    push = FakePushRepository(status: PushPermission.notDetermined);
    await offer(tester);

    expect(find.text('Know when it opens'), findsOneWidget);
    expect(find.textContaining('never shows what you wrote'), findsOneWidget);
    expect(push.calls, isEmpty);

    await tester.tap(find.text('Turn on'));
    await tester.pumpAndSettle();

    expect(push.calls, ['requestPermission']);
    expect(done, isTrue);
  });

  testWidgets('"Not now" skips the system prompt', (tester) async {
    push = FakePushRepository(status: PushPermission.notDetermined);
    await offer(tester);
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();

    expect(push.calls, isEmpty);
    expect(done, isTrue);
  });

  for (final decided in [PushPermission.granted, PushPermission.denied]) {
    testWidgets('stays quiet once ${decided.name}', (tester) async {
      push = FakePushRepository(status: decided);
      await offer(tester);

      expect(find.byType(AlertDialog), findsNothing);
      expect(done, isTrue);
    });
  }
}

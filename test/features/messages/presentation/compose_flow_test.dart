import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/presentation/compose_screen.dart';
import 'package:laternote/features/messages/presentation/review_screen.dart';
import 'package:laternote/features/messages/presentation/upcoming_messages_list.dart';

import '../fake_messages_repository.dart';

void main() {
  final now = DateTime(2030, 1, 1, 12);
  final deliverAt = DateTime(2030, 6, 1, 9);
  late FakeMessagesRepository repository;
  late ProviderContainer container;

  Future<void> pumpApp(WidgetTester tester) async {
    final router = GoRouter(
      initialLocation: Routes.compose,
      routes: [
        GoRoute(
          path: Routes.home,
          builder: (_, _) => const Scaffold(body: UpcomingMessagesList()),
          routes: [
            GoRoute(
              path: 'compose',
              builder: (_, _) => const ComposeScreen(),
              routes: [
                GoRoute(
                  path: 'review',
                  builder: (_, _) => const ReviewScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    repository = FakeMessagesRepository();
    container = ProviderContainer.test(
      overrides: [
        messagesRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => now),
        deviceTimezoneProvider.overrideWithValue(
          const AsyncData('Europe/Rome'),
        ),
      ],
    );
  });

  Future<void> tapButton(WidgetTester tester, String label) async {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  testWidgets('empty content and missing time block review', (tester) async {
    await pumpApp(tester);

    await tapButton(tester, 'Review');

    expect(find.text('Write something to your future self.'), findsOneWidget);
    expect(find.text('Pick a delivery date and time.'), findsOneWidget);
    expect(find.byType(ReviewScreen), findsNothing);
  });

  testWidgets('shows the chosen time with its zone', (tester) async {
    await pumpApp(tester);
    container.read(composeDraftProvider.notifier).setDeliverAt(deliverAt);
    await tester.pump();

    expect(find.textContaining('(Europe/Rome)'), findsOneWidget);
  });

  testWidgets('review then seal saves and lists it at home', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField), 'Dear me');
    container.read(composeDraftProvider.notifier).setDeliverAt(deliverAt);
    await tapButton(tester, 'Review');

    expect(find.byType(ReviewScreen), findsOneWidget);
    expect(find.text('Dear me'), findsOneWidget);
    expect(find.textContaining('(Europe/Rome)'), findsOneWidget);

    await tapButton(tester, 'Seal message');

    expect(repository.calls.single, (
      body: 'Dear me',
      scheduledFor: deliverAt,
      timezone: 'Europe/Rome',
    ));
    expect(find.byType(UpcomingMessagesList), findsOneWidget);
    expect(find.textContaining('Sealed until'), findsOneWidget);
    expect(find.textContaining('Opens '), findsOneWidget);
    expect(find.text('Dear me'), findsNothing);
  });

  testWidgets('a failed save shows the error and keeps the draft', (
    tester,
  ) async {
    repository.error = const NetworkError();
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField), 'Dear me');
    container.read(composeDraftProvider.notifier).setDeliverAt(deliverAt);
    await tapButton(tester, 'Review');
    await tapButton(tester, 'Seal message');

    expect(find.text(const NetworkError().message), findsOneWidget);
    expect(find.byType(ReviewScreen), findsOneWidget);

    await tapButton(tester, 'Edit');
    expect(find.text('Dear me'), findsOneWidget);
  });
}

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laternote/app/routes.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/data/draft_repository.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/presentation/compose_screen.dart';
import 'package:laternote/features/messages/presentation/review_screen.dart';
import 'package:laternote/features/messages/presentation/upcoming_messages_list.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';

import '../../notifications/fake_push_repository.dart';
import '../fake_draft_repository.dart';
import '../fake_messages_repository.dart';

void main() {
  final now = DateTime(2030, 1, 1, 12);
  final deliverAt = DateTime(2030, 6, 1, 9);
  late FakeMessagesRepository repository;
  late FakeDraftRepository drafts;
  late FakePushRepository push;
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
    drafts = FakeDraftRepository();
    push = FakePushRepository();
    container = ProviderContainer.test(
      overrides: [
        pushRepositoryProvider.overrideWithValue(push),
        messagesRepositoryProvider.overrideWithValue(repository),
        draftRepositoryProvider.overrideWithValue(drafts),
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

  testWidgets('empty content and missing time block sealing', (tester) async {
    await pumpApp(tester);

    await tapButton(tester, 'Seal…');

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
    await tapButton(tester, 'Seal…');

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
    expect(drafts.stored, isNull);
  });

  testWidgets('offers notifications after sealing while undecided', (
    tester,
  ) async {
    push.status = PushPermission.notDetermined;
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField), 'Dear me');
    container.read(composeDraftProvider.notifier).setDeliverAt(deliverAt);
    await tapButton(tester, 'Seal…');
    await tapButton(tester, 'Seal message');

    expect(repository.calls, hasLength(1));
    expect(find.text('Know when it opens'), findsOneWidget);

    await tapButton(tester, 'Turn on');

    expect(push.calls, ['requestPermission']);
    expect(find.byType(UpcomingMessagesList), findsOneWidget);
  });

  testWidgets('reopening compose restores the saved draft', (tester) async {
    drafts.stored = (body: 'Half written', deliverAt: deliverAt);
    await pumpApp(tester);

    expect(find.text('Half written'), findsOneWidget);
    expect(find.textContaining('(Europe/Rome)'), findsOneWidget);
  });

  testWidgets('edits are saved locally, not sealed', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField), 'Dear me');
    await tester.pump(draftSaveDelay);

    expect(drafts.stored?.body, 'Dear me');
    expect(repository.calls, isEmpty);
  });

  testWidgets('discarding deletes the draft and goes home', (tester) async {
    drafts.stored = (body: 'Never mind', deliverAt: null);
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Discard draft'));
    await tester.pumpAndSettle();
    await tapButton(tester, 'Discard');

    expect(drafts.stored, isNull);
    expect(repository.calls, isEmpty);
    expect(find.byType(UpcomingMessagesList), findsOneWidget);
  });

  testWidgets('cancelling discard keeps the draft', (tester) async {
    drafts.stored = (body: 'Keep me', deliverAt: null);
    await pumpApp(tester);

    await tester.tap(find.byTooltip('Discard draft'));
    await tester.pumpAndSettle();
    await tapButton(tester, 'Keep');

    expect(drafts.stored?.body, 'Keep me');
    expect(find.text('Keep me'), findsOneWidget);
  });

  testWidgets('a failed save shows the error and keeps the draft', (
    tester,
  ) async {
    repository.error = const NetworkError();
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField), 'Dear me');
    container.read(composeDraftProvider.notifier).setDeliverAt(deliverAt);
    await tapButton(tester, 'Seal…');
    await tapButton(tester, 'Seal message');

    expect(find.text(const NetworkError().message), findsOneWidget);
    expect(find.byType(ReviewScreen), findsOneWidget);

    await tapButton(tester, 'Edit');
    expect(find.text('Dear me'), findsOneWidget);
    expect(drafts.stored?.body, 'Dear me');
  });

  testWidgets('a failed local save says the draft is not saved', (
    tester,
  ) async {
    drafts.saveError = Exception('disk full');
    await pumpApp(tester);
    expect(find.textContaining('saved on this device only'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Dear me');
    await tester.pump(draftSaveDelay);
    expect(find.textContaining('Not saved on this device'), findsOneWidget);

    drafts.saveError = null;
    await tester.enterText(find.byType(TextFormField), 'Dear me!');
    await tester.pump(draftSaveDelay);
    expect(find.textContaining('saved on this device only'), findsOneWidget);
  });

  testWidgets('backgrounding the app saves a pending edit', (tester) async {
    await pumpApp(tester);
    await tester.enterText(find.byType(TextFormField), 'Dear me');
    expect(drafts.stored, isNull);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pump();

    expect(drafts.stored?.body, 'Dear me');
  });
}

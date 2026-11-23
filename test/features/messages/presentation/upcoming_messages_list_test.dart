import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/application/upcoming_messages.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';
import 'package:laternote/features/messages/presentation/envelope_tile.dart';
import 'package:laternote/features/messages/presentation/upcoming_messages_list.dart';
import 'package:laternote/l10n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_messages_repository.dart';

void main() {
  final now = DateTime(2030, 1, 1, 12);
  late FakeMessagesRepository repository;

  Future<void> pump(
    WidgetTester tester, {
    AsyncValue<String> deviceZone = const AsyncData('Europe/Rome'),
    List<Override> extra = const [],
  }) => tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        messagesRepositoryProvider.overrideWithValue(repository),
        clockProvider.overrideWithValue(() => now),
        deviceTimezoneProvider.overrideWithValue(deviceZone),
        ...extra,
      ],
      child: const MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        home: Scaffold(body: UpcomingMessagesList()),
      ),
    ),
  );

  setUp(() => repository = FakeMessagesRepository());

  testWidgets('loading explains what to do meanwhile', (tester) async {
    await pump(
      tester,
      extra: [
        upcomingMessagesProvider.overrideWith(
          (_) => Completer<List<ScheduledMessage>>().future,
        ),
      ],
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.textContaining('start a new one'), findsOneWidget);
  });

  testWidgets('empty list points to New message', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('Tap New message'), findsOneWidget);
  });

  testWidgets('shows delivery and sealed dates, never content', (
    tester,
  ) async {
    repository.upcoming.addAll([
      ScheduledMessage(
        id: 'future',
        scheduledFor: DateTime(2030, 6, 1, 9),
        timezone: 'Europe/Rome',
        createdAt: DateTime(2029, 12, 24),
      ),
      ScheduledMessage(
        id: 'overdue',
        scheduledFor: now.subtract(const Duration(minutes: 1)),
        timezone: 'Europe/Rome',
        createdAt: DateTime(2029, 11, 2),
      ),
    ]);
    await pump(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Opens Saturday, June 1, 2030 at 9:00 AM (Europe/Rome)'),
      findsOneWidget,
    );
    expect(find.text('Sealed on Dec 24, 2029'), findsOneWidget);
    // Only the one still waiting counts down.
    expect(find.text('in 4 months, 30 days'), findsOneWidget);
    expect(find.textContaining('in '), findsOneWidget);
    expect(find.text('Opening soon'), findsOneWidget);
    expect(find.text('Sealed on Nov 2, 2029'), findsOneWidget);
  });

  testWidgets('labels the opening time with the current device zone', (
    tester,
  ) async {
    repository.upcoming.add(
      ScheduledMessage(
        id: 'moved',
        scheduledFor: DateTime(2030, 6, 1, 9),
        timezone: 'Europe/Rome',
        createdAt: DateTime(2029, 12, 24),
      ),
    );
    await pump(
      tester,
      deviceZone: const AsyncData('America/New_York'),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Opens Saturday, June 1, 2030 at 9:00 AM (America/New_York)'),
      findsOneWidget,
    );
    expect(find.textContaining('Europe/Rome'), findsNothing);
  });

  testWidgets('omits the zone while the device zone is unknown', (
    tester,
  ) async {
    repository.upcoming.add(
      ScheduledMessage(
        id: 'unknown',
        scheduledFor: DateTime(2030, 6, 1, 9),
        timezone: 'Europe/Rome',
        createdAt: DateTime(2029, 12, 24),
      ),
    );
    await pump(
      tester,
      deviceZone: AsyncError(StateError('no zone'), StackTrace.empty),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Opens Saturday, June 1, 2030 at 9:00 AM'),
      findsOneWidget,
    );
  });

  testWidgets('an error offers retry', (tester) async {
    repository.error = const NetworkError();
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().errorNetwork), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tap New message'), findsOneWidget);
  });

  group('delete', () {
    ScheduledMessage message(String id, DateTime at) => ScheduledMessage(
      id: id,
      scheduledFor: at,
      timezone: 'Europe/Rome',
      createdAt: DateTime(2029, 12, 24),
    );

    testWidgets('is offered only before a message starts opening', (
      tester,
    ) async {
      repository.upcoming.addAll([
        message('future', DateTime(2030, 6, 1, 9)),
        message('overdue', now.subtract(const Duration(minutes: 1))),
      ]);
      await pump(tester);
      await tester.pumpAndSettle();

      expect(find.byTooltip('Delete'), findsOneWidget);
      expect(
        find.descendant(
          of: find.widgetWithText(EnvelopeTile, 'Opening soon'),
          matching: find.byTooltip('Delete'),
        ),
        findsNothing,
      );
    });

    testWidgets('cancel keeps the message', (tester) async {
      repository.upcoming.add(message('m1', DateTime(2030, 6, 1, 9)));
      await pump(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Delete this sealed message?'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(repository.deleted, isEmpty);
      expect(find.textContaining('Opens'), findsOneWidget);
    });

    testWidgets('confirming removes it from the list', (tester) async {
      repository.upcoming.add(message('m1', DateTime(2030, 6, 1, 9)));
      await pump(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(repository.deleted, ['m1']);
      expect(find.text('Message deleted.'), findsOneWidget);
      expect(find.textContaining('Tap New message'), findsOneWidget);
    });

    testWidgets('a failed delete is explained', (tester) async {
      repository.upcoming.add(message('m1', DateTime(2030, 6, 1, 9)));
      await pump(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();

      repository.deleteGate = Completer<void>();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pump();
      repository.error = const NetworkError();
      repository.deleteGate!.complete();
      await tester.pumpAndSettle();

      expect(find.text(AppLocalizationsEn().errorNetwork), findsWidgets);
    });
  });
}

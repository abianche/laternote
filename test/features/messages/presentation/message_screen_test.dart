import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/ui/envelope.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/application/inbox.dart';
import 'package:laternote/features/messages/data/available_message.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/presentation/message_screen.dart';
import 'package:laternote/l10n/app_localizations_en.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_messages_repository.dart';

void main() {
  late FakeMessagesRepository repository;

  Future<void> pump(
    WidgetTester tester, {
    List<Override> extra = const [],
    bool animations = true,
  }) => tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        messagesRepositoryProvider.overrideWithValue(repository),
        deviceTimezoneProvider.overrideWithValue(
          const AsyncData('Europe/Rome'),
        ),
        ...extra,
      ],
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: !animations),
          child: child!,
        ),
        home: const MessageScreen(id: 'm1'),
      ),
    ),
  );

  setUp(() => repository = FakeMessagesRepository());

  testWidgets('shows the text and its dates, and records the open', (
    tester,
  ) async {
    repository.available.add(
      AvailableMessage(
        id: 'm1',
        body: 'Dear future me',
        scheduledFor: DateTime(2030, 6, 1, 9),
        timezone: 'Europe/Rome',
        createdAt: DateTime(2029, 12, 24),
        releasedAt: DateTime(2030, 6, 1, 9, 1),
        openedAt: null,
      ),
    );
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('Dear future me'), findsOneWidget);
    expect(find.text('Written on Monday, December 24, 2029'), findsOneWidget);
    expect(
      find.text('Set to open Saturday, June 1, 2030 at 9:00 AM (Europe/Rome)'),
      findsOneWidget,
    );
    expect(
      find.text('Arrived Saturday, June 1, 2030 at 9:01 AM (Europe/Rome)'),
      findsOneWidget,
    );
    expect(repository.opened, ['m1']);
  });

  testWidgets('shows progress while opening', (tester) async {
    await pump(
      tester,
      extra: [
        openedMessageProvider(
          'm1',
        ).overrideWith((_) => Completer<AvailableMessage?>().future),
      ],
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('a message that is not available says so', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('isn\'t available'), findsOneWidget);
  });

  testWidgets('an error offers retry', (tester) async {
    repository.error = const NetworkError();
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizationsEn().errorNetwork), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('isn\'t available'), findsOneWidget);
  });

  group('the envelope', () {
    AvailableMessage letter({DateTime? openedAt}) => AvailableMessage(
      id: 'm1',
      body: 'Dear future me',
      scheduledFor: DateTime(2030, 6, 1, 9),
      timezone: 'Europe/Rome',
      createdAt: DateTime(2029, 12, 24),
      releasedAt: DateTime(2030, 6, 1, 9, 1),
      openedAt: openedAt,
    );
    const opening = 'Opening the envelope. Tap to skip.';

    testWidgets('opens on first read, then shows the letter', (tester) async {
      repository.available.add(letter());
      await pump(tester);
      await tester.pump();

      expect(find.bySemanticsLabel(opening), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byType(Envelope), findsNothing);
      expect(find.text('Dear future me'), findsOneWidget);
    });

    testWidgets('a tap skips the opening', (tester) async {
      repository.available.add(letter());
      await pump(tester);
      await tester.pump();

      await tester.tap(find.byType(Envelope));
      await tester.pump();

      expect(find.byType(Envelope), findsNothing);
    });

    testWidgets('a message already read shows the letter at once', (
      tester,
    ) async {
      repository.available.add(letter(openedAt: DateTime(2030, 6, 2)));
      await pump(tester);
      await tester.pump();

      expect(find.byType(Envelope), findsNothing);
      expect(find.text('Dear future me'), findsOneWidget);
    });

    testWidgets('no opening when the OS turns animations off', (tester) async {
      repository.available.add(letter());
      await pump(tester, animations: false);
      await tester.pump();

      expect(find.byType(Envelope), findsNothing);
      expect(repository.opened, ['m1']);
    });
  });
}

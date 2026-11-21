import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/application/inbox.dart';
import 'package:laternote/features/messages/data/available_message.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/presentation/inbox_list.dart';
import 'package:material_ui/material_ui.dart';

import '../fake_messages_repository.dart';

void main() {
  late FakeMessagesRepository repository;

  Future<void> pump(
    WidgetTester tester, {
    List<Override> extra = const [],
  }) => tester.pumpWidget(
    ProviderScope(
      retry: (_, _) => null,
      overrides: [
        messagesRepositoryProvider.overrideWithValue(repository),
        ...extra,
      ],
      child: MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Scaffold(body: InboxList()),
            ),
            GoRoute(
              path: '/messages/:id',
              builder: (_, state) =>
                  Text('Opened ${state.pathParameters['id']}'),
            ),
          ],
        ),
      ),
    ),
  );

  setUp(() => repository = FakeMessagesRepository());

  testWidgets('shows progress while loading', (tester) async {
    await pump(
      tester,
      extra: [
        availableMessagesProvider.overrideWith(
          (_) => Completer<List<InboxItem>>().future,
        ),
      ],
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading your inbox…'), findsOneWidget);
  });

  testWidgets('an empty inbox explains when messages arrive', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing has opened yet'), findsOneWidget);
  });

  testWidgets('lists new messages before read ones, dates only', (
    tester,
  ) async {
    repository.available.addAll([
      released('read', openedAt: DateTime(2030, 1, 5)),
      AvailableMessage(
        id: 'new',
        body: 'secret text',
        scheduledFor: DateTime(2030, 3, 1, 9),
        timezone: 'Europe/Rome',
        createdAt: DateTime(2029, 7, 4),
        releasedAt: DateTime(2030, 3, 1, 9, 0, 20),
        openedAt: null,
      ),
    ]);
    await pump(tester);
    await tester.pumpAndSettle();

    final newHeader = tester.getTopLeft(find.text('New')).dy;
    final readHeader = tester.getTopLeft(find.text('Read')).dy;
    final newItem = tester.getTopLeft(find.text('Arrived Mar 1, 2030')).dy;
    final readItem = tester.getTopLeft(find.text('Arrived Jan 1, 2030')).dy;
    expect(newHeader, lessThan(newItem));
    expect(newItem, lessThan(readHeader));
    expect(readHeader, lessThan(readItem));
    expect(find.text('Written on Jul 4, 2029'), findsOneWidget);
    expect(find.textContaining('secret'), findsNothing);
  });

  testWidgets('only read messages show no New section', (tester) async {
    repository.available.add(released('read', openedAt: DateTime(2030, 1, 5)));
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text('New'), findsNothing);
    expect(find.text('Read'), findsOneWidget);
  });

  testWidgets('tapping a message opens it', (tester) async {
    repository.available.add(released('m1'));
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Arrived Jan 1, 2030'));
    await tester.pumpAndSettle();

    expect(find.text('Opened m1'), findsOneWidget);
  });

  testWidgets('an error offers retry', (tester) async {
    repository.error = const NetworkError();
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(const NetworkError().message), findsOneWidget);

    repository.error = null;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing has opened yet'), findsOneWidget);
  });
}

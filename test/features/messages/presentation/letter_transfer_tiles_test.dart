import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/app/localization.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/core/database.dart';
import 'package:laternote/features/messages/data/letter_file_repository.dart';
import 'package:laternote/features/messages/data/letters_file.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/presentation/letter_transfer_tiles.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:laternote/features/notifications/presentation/ready_notification_text.dart';
import 'package:material_ui/material_ui.dart';

import '../../notifications/fake_local_notifications_repository.dart';
import '../fake_letter_file_repository.dart';
import '../fake_messages_repository.dart';

const text = (title: 'A message is ready', body: 'Tap', channelName: 'Ready');

void main() {
  late FakeMessagesRepository messages;
  late FakeLetterFileRepository files;

  Future<void> pump(WidgetTester tester) async {
    messages = FakeMessagesRepository();
    files = FakeLetterFileRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          messagesRepositoryProvider.overrideWithValue(messages),
          letterFileRepositoryProvider.overrideWithValue(files),
          localNotificationsRepositoryProvider.overrideWithValue(
            FakeLocalNotificationsRepository(),
          ),
          clockProvider.overrideWithValue(() => DateTime.utc(2030)),
          readyNotificationTextProvider.overrideWithValue(text),
        ],
        child: const MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          home: Scaffold(body: LetterTransferTiles()),
        ),
      ),
    );
  }

  Uint8List fileWith(List<String> ids) => encodeLetters([
    for (final id in ids)
      LetterRow(
        id: id,
        body: 'Body',
        scheduledFor: DateTime.utc(2031),
        timezone: 'Europe/Rome',
        createdAt: DateTime.utc(2029),
      ),
  ], DateTime.utc(2030));

  testWidgets('warns before exporting and shares only once confirmed', (
    tester,
  ) async {
    await pump(tester);

    await tester.tap(find.text('Export letters'));
    await tester.pumpAndSettle();
    expect(find.textContaining("The file isn't encrypted"), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(files.shared, isEmpty);

    await tester.tap(find.text('Export letters'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Export'));
    await tester.pumpAndSettle();
    expect(files.shared, hasLength(1));
  });

  testWidgets('says how many letters an import added', (tester) async {
    await pump(tester);
    files.toPick = fileWith(['a', 'b']);

    await tester.tap(find.text('Import letters'));
    await tester.pumpAndSettle();
    expect(find.text('2 letters added'), findsOneWidget);

    await tester.tap(find.text('Import letters'));
    await tester.pumpAndSettle();
    expect(find.text('No new letters in this file'), findsOneWidget);
  });

  testWidgets('shows an error for an invalid file', (tester) async {
    await pump(tester);
    files.toPick = utf8.encode('not a letters file');

    await tester.tap(find.text('Import letters'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nothing was imported'), findsOneWidget);
    expect(messages.letters, isEmpty);
  });
}

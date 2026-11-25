import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/core/database.dart';
import 'package:laternote/features/messages/application/letter_transfer.dart';
import 'package:laternote/features/messages/data/letter_file_repository.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:laternote/features/notifications/presentation/ready_notification_text.dart';

import '../../notifications/fake_local_notifications_repository.dart';
import '../fake_letter_file_repository.dart';

final now = DateTime.utc(2030, 1, 1, 12);
const text = (title: 'A message is ready', body: 'Tap', channelName: 'Ready');

/// Runs export and import on a real in-memory database.
class Device {
  Device()
    : db = AppDatabase(NativeDatabase.memory()),
      files = FakeLetterFileRepository(),
      notifications = FakeLocalNotificationsRepository() {
    container = ProviderContainer.test(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        letterFileRepositoryProvider.overrideWithValue(files),
        localNotificationsRepositoryProvider.overrideWithValue(notifications),
        clockProvider.overrideWithValue(() => now),
        readyNotificationTextProvider.overrideWithValue(text),
      ],
    );
    container.listen(letterTransferProvider, (_, _) {});
    addTearDown(db.close);
  }

  final AppDatabase db;
  final FakeLetterFileRepository files;
  final FakeLocalNotificationsRepository notifications;
  late final ProviderContainer container;

  LetterTransfer get transfer =>
      container.read(letterTransferProvider.notifier);
  AsyncValue<TransferOutcome?> get state =>
      container.read(letterTransferProvider);
  Future<List<LetterRow>> letters() =>
      (db.select(db.letters)..orderBy([(l) => OrderingTerm.asc(l.id)])).get();

  Future<void> add(String id, {required Duration after, DateTime? openedAt}) =>
      db
          .into(db.letters)
          .insert(
            LetterRow(
              id: id,
              body: 'Body of $id',
              scheduledFor: now.add(after),
              timezone: 'Europe/Rome',
              createdAt: DateTime.utc(2029, 6, 1),
              openedAt: openedAt,
            ),
          );
}

void main() {
  late Device phone;

  // Each test runs two devices, each with its own in-memory database.
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  setUp(() async {
    phone = Device();
    await phone.add('past', after: -const Duration(days: 1), openedAt: now);
    await phone.add('future', after: const Duration(days: 1));
  });

  Future<Device> exportToNewDevice() async {
    await phone.transfer.export(ExportTarget.share);
    final fresh = Device()..files.toPick = phone.files.shared.single.bytes;
    return fresh;
  }

  test('shares every letter as a dated file', () async {
    await phone.transfer.export(ExportTarget.share);

    final file = phone.files.shared.single;
    expect(file.name, 'laternote-2030-01-01.json');
    expect(utf8.decode(file.bytes), contains('Body of future'));
    expect(phone.state.value, isNull);
  });

  test('saves the same file and reports it', () async {
    await phone.transfer.export(ExportTarget.share);
    await phone.transfer.export(ExportTarget.save);

    final file = phone.files.saved.single;
    expect(file.name, 'laternote-2030-01-01.json');
    expect(file.bytes, phone.files.shared.single.bytes);
    expect(phone.state.value, isA<ExportSaved>());
  });

  test('a cancelled save reports nothing', () async {
    phone.files.cancelSave = true;

    await phone.transfer.export(ExportTarget.save);

    expect(phone.state.value, isNull);
  });

  test('import into an empty store gives the same letters', () async {
    final fresh = await exportToNewDevice();

    await fresh.transfer.import();

    expect(
      fresh.state.value,
      isA<LettersImported>().having((o) => o.added, 'added', 2),
    );
    expect(await fresh.letters(), await phone.letters());
  });

  test('schedules notifications for imported future letters', () async {
    final fresh = await exportToNewDevice();

    await fresh.transfer.import();
    await pumpEventQueue();

    expect(fresh.notifications.pending.keys, ['future']);
  });

  test('importing the same file twice adds nothing', () async {
    final fresh = await exportToNewDevice();
    await fresh.transfer.import();

    await fresh.transfer.import();

    expect(
      fresh.state.value,
      isA<LettersImported>().having((o) => o.added, 'added', 0),
    );
    expect(await fresh.letters(), hasLength(2));
  });

  test('a corrupt file is rejected with no changes', () async {
    final fresh = await exportToNewDevice();
    final bytes = fresh.files.toPick!;
    fresh.files.toPick = bytes.sublist(0, bytes.length - 10);

    await fresh.transfer.import();

    expect(fresh.state.error, isA<InvalidFileError>());
    expect(await fresh.letters(), isEmpty);
    expect(fresh.notifications.pending, isEmpty);
  });

  test('a cancelled pick changes nothing', () async {
    await phone.transfer.import();

    expect(phone.state.value, isNull);
    expect(await phone.letters(), hasLength(2));
  });

  test('a failing share sheet is reported', () async {
    phone.files.error = const UnexpectedError();

    await phone.transfer.export(ExportTarget.share);

    expect(phone.state.error, isA<UnexpectedError>());
  });
}

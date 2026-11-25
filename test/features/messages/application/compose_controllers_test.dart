import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/application/message_draft.dart';
import 'package:laternote/features/messages/application/upcoming_messages.dart';
import 'package:laternote/features/messages/data/draft_repository.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:laternote/features/notifications/presentation/ready_notification_text.dart';

import '../../notifications/fake_local_notifications_repository.dart';
import '../fake_draft_repository.dart';
import '../fake_messages_repository.dart';

void main() {
  final now = DateTime(2030, 1, 1, 12);
  late FakeMessagesRepository repository;
  late FakeDraftRepository drafts;
  late FakeLocalNotificationsRepository notifications;
  late ProviderContainer container;

  setUp(() {
    repository = FakeMessagesRepository();
    drafts = FakeDraftRepository();
    notifications = FakeLocalNotificationsRepository();
    container = ProviderContainer.test(
      overrides: [
        localNotificationsRepositoryProvider.overrideWithValue(notifications),
        readyNotificationTextProvider.overrideWithValue(
          (title: 'Ready', body: 'Tap', channelName: 'Ready'),
        ),
        messagesRepositoryProvider.overrideWithValue(repository),
        draftRepositoryProvider.overrideWithValue(drafts),
        clockProvider.overrideWithValue(() => now),
        deviceTimezoneProvider.overrideWithValue(
          const AsyncData('Europe/Rome'),
        ),
      ],
    );
    container.listen(sealMessageControllerProvider, (_, _) {});
  });

  Future<ComposeDraft> loadDraft() async {
    container.listen(composeDraftProvider, (_, _) {});
    await container.read(composeDraftProvider.future);
    return container.read(composeDraftProvider.notifier);
  }

  Future<AsyncValue<DateTime?>> seal(MessageDraft draft) async {
    await container.read(sealMessageControllerProvider.notifier).seal(draft);
    return container.read(sealMessageControllerProvider);
  }

  test('ComposeDraft starts empty without a saved draft', () async {
    await loadDraft();

    final draft = container.read(composeDraftProvider).requireValue;
    expect(draft.body, '');
    expect(draft.deliverAt, isNull);
  });

  test('ComposeDraft restores the saved draft', () async {
    final at = now.add(const Duration(days: 1));
    drafts.stored = (body: 'Saved', deliverAt: at);
    await loadDraft();

    final draft = container.read(composeDraftProvider).requireValue;
    expect(draft.body, 'Saved');
    expect(draft.deliverAt, at);
  });

  test('ComposeDraft autosaves edits locally', () async {
    final at = now.add(const Duration(days: 1));
    final notifier = await loadDraft();

    notifier.setDeliverAt(at);
    await Future<void>.delayed(Duration.zero);
    expect(drafts.stored, (body: '', deliverAt: at));

    notifier
      ..setBody('H')
      ..setBody('Hi');
    expect(drafts.stored?.body, '');
    await Future<void>.delayed(draftSaveDelay * 2);
    expect(drafts.stored, (body: 'Hi', deliverAt: at));
    expect(drafts.saves, 2);
    expect(repository.calls, isEmpty);
  });

  test('ComposeDraft saves a pending edit when disposed', () async {
    final sub = container.listen(composeDraftProvider, (_, _) {});
    await container.read(composeDraftProvider.future);
    container.read(composeDraftProvider.notifier).setBody('Hi');

    sub.close();
    await Future<void>.delayed(Duration.zero);

    expect(drafts.stored?.body, 'Hi');
  });

  test('ComposeDraft.clear discards the draft and any pending save', () async {
    drafts.stored = (body: 'Saved', deliverAt: null);
    final notifier = await loadDraft();
    notifier.setBody('Edited');

    await notifier.clear();
    await Future<void>.delayed(draftSaveDelay * 2);

    expect(drafts.stored, isNull);
    expect(container.read(composeDraftProvider).requireValue.body, '');
  });

  test('seals a valid draft with the device zone', () async {
    final at = now.add(const Duration(hours: 1));
    await loadDraft();
    final state = await seal(MessageDraft(body: 'Hi', deliverAt: at));

    expect(state, AsyncData<DateTime?>(at));
    expect(repository.calls.single, (
      body: 'Hi',
      scheduledFor: at,
      timezone: 'Europe/Rome',
    ));
  });

  test('sealing schedules its notification', () async {
    final at = now.add(const Duration(hours: 1));
    await loadDraft();
    await seal(MessageDraft(body: 'Hi', deliverAt: at));
    await pumpEventQueue();

    expect(notifications.pending, {'sealed-1': at});
  });

  test('a seal whose notification fails still succeeds', () async {
    final at = now.add(const Duration(hours: 1));
    notifications.error = const UnexpectedError();
    await loadDraft();
    final state = await seal(MessageDraft(body: 'Hi', deliverAt: at));
    await pumpEventQueue();

    expect(state, AsyncData<DateTime?>(at));
    expect(notifications.pending, isEmpty);
  });

  test('sealing deletes the local draft', () async {
    final at = now.add(const Duration(hours: 1));
    drafts.stored = (body: 'Hi', deliverAt: at);
    await loadDraft();

    await seal(MessageDraft(body: 'Hi', deliverAt: at));

    expect(drafts.stored, isNull);
  });

  test('sealing refreshes the upcoming list', () async {
    await loadDraft();
    container.listen(upcomingMessagesProvider, (_, _) {});
    expect(await container.read(upcomingMessagesProvider.future), isEmpty);

    await seal(
      MessageDraft(body: 'Hi', deliverAt: now.add(const Duration(hours: 1))),
    );

    final upcoming = await container.read(upcomingMessagesProvider.future);
    expect(upcoming.single.scheduledFor, now.add(const Duration(hours: 1)));
  });

  test('rejects empty content without saving', () async {
    final state = await seal(
      MessageDraft(body: ' ', deliverAt: now.add(const Duration(hours: 1))),
    );

    expect(state.error, isA<ValidationError>());
    expect(repository.calls, isEmpty);
  });

  test('rejects a time that passed during review', () async {
    final state = await seal(MessageDraft(body: 'Hi', deliverAt: now));

    expect(state.error, isA<ValidationError>());
    expect(repository.calls, isEmpty);
  });

  test('surfaces save failures and keeps the draft', () async {
    drafts.stored = (body: 'Hi', deliverAt: now.add(const Duration(hours: 1)));
    await loadDraft();
    repository.error = const NetworkError();
    final state = await seal(
      MessageDraft(body: 'Hi', deliverAt: now.add(const Duration(hours: 1))),
    );

    expect(state.error, isA<NetworkError>());
    expect(drafts.stored, isNotNull);
  });

  test('ComposeDraft reports a failed save until one succeeds', () async {
    container.listen(draftSaveFailedProvider, (_, _) {});
    final notifier = await loadDraft();
    drafts.saveError = Exception('disk full');

    notifier.setDeliverAt(now.add(const Duration(days: 1)));
    await Future<void>.delayed(Duration.zero);
    expect(container.read(draftSaveFailedProvider), isTrue);

    drafts.saveError = null;
    notifier.setBody('Hi');
    await Future<void>.delayed(draftSaveDelay * 2);
    expect(container.read(draftSaveFailedProvider), isFalse);
  });

  test('ComposeDraft.flush saves a pending edit now', () async {
    final notifier = await loadDraft();
    notifier
      ..setBody('Hi')
      ..flush();
    await Future<void>.delayed(Duration.zero);

    expect(drafts.stored?.body, 'Hi');
    expect(drafts.saves, 1);
  });

  test('a seal whose local clear fails still succeeds, once', () async {
    final at = now.add(const Duration(hours: 1));
    drafts.stored = (body: 'Hi', deliverAt: at);
    drafts.clearError = Exception('keychain locked');
    await loadDraft();

    expect(
      await seal(MessageDraft(body: 'Hi', deliverAt: at)),
      AsyncData<DateTime?>(at),
    );
    await seal(MessageDraft(body: 'Hi', deliverAt: at));

    expect(repository.calls, hasLength(1));
  });
}

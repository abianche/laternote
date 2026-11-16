import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/features/messages/application/compose_controllers.dart';
import 'package:laternote/features/messages/application/message_draft.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';

import '../fake_messages_repository.dart';

void main() {
  final now = DateTime(2030, 1, 1, 12);
  late FakeMessagesRepository repository;
  late ProviderContainer container;

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
    container.listen(sealMessageControllerProvider, (_, _) {});
  });

  Future<AsyncValue<bool>> seal(MessageDraft draft) async {
    await container.read(sealMessageControllerProvider.notifier).seal(draft);
    return container.read(sealMessageControllerProvider);
  }

  test('ComposeDraft keeps body and delivery time', () {
    container.listen(composeDraftProvider, (_, _) {});
    final notifier = container.read(composeDraftProvider.notifier);
    notifier.setBody('Hi');
    notifier.setDeliverAt(now.add(const Duration(days: 1)));

    final draft = container.read(composeDraftProvider);
    expect(draft.body, 'Hi');
    expect(draft.deliverAt, now.add(const Duration(days: 1)));
  });

  test('seals a valid draft with the device zone', () async {
    final at = now.add(const Duration(hours: 1));
    final state = await seal(MessageDraft(body: 'Hi', deliverAt: at));

    expect(state, const AsyncData(true));
    expect(repository.calls.single, (
      body: 'Hi',
      scheduledFor: at,
      timezone: 'Europe/Rome',
    ));
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

  test('surfaces save failures', () async {
    repository.error = const NetworkError();
    final state = await seal(
      MessageDraft(body: 'Hi', deliverAt: now.add(const Duration(hours: 1))),
    );

    expect(state.error, isA<NetworkError>());
  });
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/application/delete_message_controller.dart';
import 'package:laternote/features/messages/application/upcoming_messages.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';

import '../fake_messages_repository.dart';

void main() {
  late FakeMessagesRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeMessagesRepository()
      ..upcoming.add(
        ScheduledMessage(
          id: 'm1',
          scheduledFor: DateTime(2030, 6, 1),
          timezone: 'Europe/Rome',
          createdAt: DateTime(2030),
        ),
      );
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [messagesRepositoryProvider.overrideWithValue(repository)],
    );
    container.listen(deleteMessageControllerProvider, (_, _) {});
    container.listen(upcomingMessagesProvider, (_, _) {});
  });

  DeleteMessageController controller() =>
      container.read(deleteMessageControllerProvider.notifier);

  test('deletes the message and refreshes the upcoming list', () async {
    expect(await container.read(upcomingMessagesProvider.future), hasLength(1));

    await controller().delete('m1');

    expect(repository.deleted, ['m1']);
    expect(container.read(deleteMessageControllerProvider).hasError, isFalse);
    expect(await container.read(upcomingMessagesProvider.future), isEmpty);
  });

  test('reports a failure and still refreshes the list', () async {
    await container.read(upcomingMessagesProvider.future);
    final listsBefore = repository.listCalls;
    repository.error = const ValidationError(ValidationProblem.alreadyOpening);

    await controller().delete('m1');

    expect(
      container.read(deleteMessageControllerProvider).error,
      isA<ValidationError>(),
    );
    repository.error = null;
    await container.read(upcomingMessagesProvider.future);
    expect(repository.listCalls, listsBefore + 1);
  });

  test('ignores a second delete while one is running', () async {
    repository.deleteGate = Completer<void>();

    final first = controller().delete('m1');
    await controller().delete('m1');
    repository.deleteGate!.complete();
    await first;

    expect(repository.deleted, ['m1']);
  });
}

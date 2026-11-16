import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/application/upcoming_messages.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';

import '../fake_messages_repository.dart';

void main() {
  late FakeMessagesRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeMessagesRepository();
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [messagesRepositoryProvider.overrideWithValue(repository)],
    );
  });

  Future<List<ScheduledMessage>> load() {
    container.listen(upcomingMessagesProvider, (_, _) {});
    return container.read(upcomingMessagesProvider.future);
  }

  test('loads the repository list', () async {
    final message = ScheduledMessage(
      id: 'm1',
      scheduledFor: DateTime(2030, 6, 1),
      timezone: 'Europe/Rome',
      createdAt: DateTime(2030),
    );
    repository.upcoming.add(message);

    expect(await load(), [message]);
  });

  test('surfaces repository errors', () async {
    repository.error = const NetworkError();

    await expectLater(load(), throwsA(isA<NetworkError>()));
  });
}

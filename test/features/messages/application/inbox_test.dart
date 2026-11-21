import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/application/inbox.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';

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

  Future<T> load<T>(ProviderListenable<AsyncValue<T>> provider) async {
    container.listen(provider, (_, _) {});
    while (container.read(provider).isLoading) {
      await Future<void>.delayed(Duration.zero);
    }
    return container.read(provider).requireValue;
  }

  group('availableMessages', () {
    test('lists released messages from the repository', () async {
      repository.available.add(released('m1'));

      final items = await load(availableMessagesProvider);

      expect(items.single.id, 'm1');
      expect(items.single.isNew, isTrue);
    });

    test('surfaces repository errors', () async {
      repository.error = const NetworkError();
      container.listen(availableMessagesProvider, (_, _) {});

      await expectLater(
        container.read(availableMessagesProvider.future),
        throwsA(isA<NetworkError>()),
      );
    });
  });

  group('openedMessage', () {
    test('returns the message and records the first open', () async {
      repository.available.add(released('m1'));
      await load(availableMessagesProvider);
      final listsBefore = repository.listCalls;

      final message = await load(openedMessageProvider('m1'));

      expect(message!.body, 'Body of m1');
      expect(repository.opened, ['m1']);
      // The inbox refreshes so the message moves to Read.
      await load(availableMessagesProvider);
      expect(repository.listCalls, listsBefore + 1);
      expect(
        container.read(availableMessagesProvider).value!.single.isNew,
        isFalse,
      );
    });

    test('does not record an already opened message again', () async {
      repository.available.add(released('m1', openedAt: DateTime(2030, 1, 2)));

      expect(await load(openedMessageProvider('m1')), isNotNull);
      expect(repository.opened, isEmpty);
    });

    test('a message that is not available is null and not recorded', () async {
      expect(await load(openedMessageProvider('sealed')), isNull);
      expect(repository.opened, isEmpty);
    });

    test('failing to record the open still shows the message', () async {
      repository.available.add(released('m1'));
      repository.markOpenedError = const NetworkError();

      expect((await load(openedMessageProvider('m1')))!.body, 'Body of m1');
    });

    test('surfaces errors loading the message', () async {
      repository.error = const NetworkError();
      container.listen(openedMessageProvider('m1'), (_, _) {});

      await expectLater(
        container.read(openedMessageProvider('m1').future),
        throwsA(isA<NetworkError>()),
      );
    });
  });
}

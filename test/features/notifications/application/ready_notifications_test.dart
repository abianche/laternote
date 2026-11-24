import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/clock.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';
import 'package:laternote/features/notifications/application/ready_notifications.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';
import 'package:laternote/features/notifications/presentation/ready_notification_text.dart';

import '../../messages/fake_messages_repository.dart';
import '../fake_local_notifications_repository.dart';

final now = DateTime(2030, 1, 1, 12);
const text = (title: 'A message is ready', body: 'Tap', channelName: 'Ready');

/// Letter `l<n>`, ready [n] hours from [now].
ScheduledMessage letter(int n) => ScheduledMessage(
  id: 'l$n',
  scheduledFor: now.add(Duration(hours: n)),
  timezone: 'Europe/Rome',
  createdAt: DateTime(2029),
);

void main() {
  group('lettersToNotify', () {
    test('keeps every future letter when under the cap, soonest first', () {
      final picked = lettersToNotify([letter(3), letter(1), letter(2)], now);

      expect(picked.map((m) => m.id), ['l1', 'l2', 'l3']);
    });

    test('keeps only the nearest 64 when over the cap', () {
      final picked = lettersToNotify(
        [for (var n = 100; n >= 1; n--) letter(n)],
        now,
      );

      expect(picked, hasLength(maxPendingNotifications));
      expect(picked.first.id, 'l1');
      expect(picked.last.id, 'l64');
    });

    test('skips letters already past due', () {
      final picked = lettersToNotify([letter(-1), letter(0), letter(1)], now);

      expect(picked.map((m) => m.id), ['l1']);
    });
  });

  group('ReadyNotifications', () {
    late FakeMessagesRepository messages;
    late FakeLocalNotificationsRepository notifications;
    late ProviderContainer container;

    setUp(() {
      messages = FakeMessagesRepository();
      notifications = FakeLocalNotificationsRepository();
      container = ProviderContainer.test(
        overrides: [
          messagesRepositoryProvider.overrideWithValue(messages),
          localNotificationsRepositoryProvider.overrideWithValue(
            notifications,
          ),
          clockProvider.overrideWithValue(() => now),
          readyNotificationTextProvider.overrideWithValue(text),
        ],
      );
    });

    ReadyNotifications notifier() =>
        container.read(readyNotificationsProvider.notifier);

    test('schedules the nearest letters when the app starts', () async {
      messages.upcoming.addAll([for (var n = 1; n <= 70; n++) letter(n)]);
      container.listen(readyNotificationsProvider, (_, _) {});
      await pumpEventQueue();

      expect(notifications.pending, hasLength(maxPendingNotifications));
      expect(notifications.pending['l1'], now.add(const Duration(hours: 1)));
      expect(notifications.pending, isNot(contains('l65')));
      expect(notifications.texts['l1'], text);
    });

    test('cancels notifications for letters no longer among them', () async {
      messages.upcoming.add(letter(1));
      notifications.pending.addAll({'gone': now, 'l1': now});

      await notifier().sync();

      expect(notifications.calls, ['cancel:gone']);
      expect(notifications.pending.keys, ['l1']);
    });

    test('a deleted letter is cancelled and the next takes its slot', () async {
      messages.upcoming.addAll([for (var n = 1; n <= 65; n++) letter(n)]);
      await notifier().sync();
      expect(notifications.pending, isNot(contains('l65')));

      messages.upcoming.removeWhere((m) => m.id == 'l1');
      await notifier().letterDeleted('l1');

      expect(notifications.calls, contains('cancel:l1'));
      expect(notifications.pending, isNot(contains('l1')));
      expect(notifications.pending, contains('l65'));
    });

    test('swallows failures', () async {
      messages.upcoming.add(letter(1));
      notifications.error = const UnexpectedError();

      await expectLater(notifier().sync(), completes);
      expect(notifications.pending, isEmpty);
    });
  });
}

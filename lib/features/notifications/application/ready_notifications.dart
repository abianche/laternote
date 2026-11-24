import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/clock.dart';
import '../../messages/data/messages_repository.dart';
import '../../messages/data/scheduled_message.dart';
import '../data/local_notifications_repository.dart';
import '../presentation/ready_notification_text.dart';

part 'ready_notifications.g.dart';

/// The letters that should have a pending notification: the
/// [maxPendingNotifications] nearest ones still in the future.
List<ScheduledMessage> lettersToNotify(
  Iterable<ScheduledMessage> upcoming,
  DateTime now,
) =>
    (upcoming.where((m) => m.scheduledFor.isAfter(now)).toList()
          ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor)))
        .take(maxPendingNotifications)
        .toList();

/// Keeps one notification pending for each of the nearest letters. Synced
/// when the app starts (OS updates, reinstalls and restores can drop them)
/// and after every seal and delete. Notifications are best effort: every
/// failure is swallowed so they never get in the way of sealing or deleting.
@Riverpod(keepAlive: true)
class ReadyNotifications extends _$ReadyNotifications {
  /// Runs syncs one after another.
  Future<void> _queue = Future.value();

  @override
  void build() => unawaited(sync());

  /// Schedules the nearest letters and cancels notifications for any other.
  Future<void> sync() => _queue = _queue.then((_) => _sync());

  /// Cancels letter [id]'s notification after it was deleted, then lets the
  /// next letter take its slot.
  Future<void> letterDeleted(String id) => _queue = _queue.then((_) async {
    try {
      await ref.read(localNotificationsRepositoryProvider).cancel(id);
    } on Object {
      // Best effort (see class doc); the sync below retries it.
    }
    await _sync();
  });

  Future<void> _sync() async {
    if (!ref.mounted) return;
    try {
      final notifications = ref.read(localNotificationsRepositoryProvider);
      final wanted = lettersToNotify(
        await ref.read(messagesRepositoryProvider).listUpcoming(),
        ref.read(clockProvider)(),
      );
      final wantedIds = {for (final m in wanted) m.id};
      for (final id in await notifications.pendingLetterIds()) {
        if (!wantedIds.contains(id)) await notifications.cancel(id);
      }
      // Rescheduling a pending one refreshes its text, e.g. after the
      // device language changed.
      final text = ref.read(readyNotificationTextProvider);
      for (final m in wanted) {
        await notifications.schedule(m.id, m.scheduledFor, text);
      }
    } on Object {
      // Best effort (see class doc); the next sync tries again.
    }
  }
}

import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../notifications/application/ready_notifications.dart';
import '../data/messages_repository.dart';
import 'upcoming_messages.dart';

part 'delete_message_controller.g.dart';

/// Deletes a sealed message before it opens, cancels its notification and
/// refreshes the upcoming list. Holds the outcome of the last deletion.
@riverpod
class DeleteMessageController extends _$DeleteMessageController {
  @override
  FutureOr<void> build() {}

  Future<void> delete(String id) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => ref.read(messagesRepositoryProvider).deleteScheduledMessage(id),
    );
    if (!ref.mounted) return;
    // Refresh on failure too: a message that can't be deleted has usually
    // just started opening, and the list should say so.
    ref.invalidate(upcomingMessagesProvider);
    if (result.hasValue) {
      unawaited(
        ref.read(readyNotificationsProvider.notifier).letterDeleted(id),
      );
    }
    state = result;
  }
}

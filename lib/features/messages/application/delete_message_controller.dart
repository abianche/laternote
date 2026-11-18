import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/messages_repository.dart';
import 'upcoming_messages.dart';

part 'delete_message_controller.g.dart';

/// Deletes a sealed message before it opens, then refreshes the upcoming
/// list. Holds the outcome of the last deletion.
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
    state = result;
  }
}

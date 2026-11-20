import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/app_error.dart';
import '../data/available_message.dart';
import '../data/messages_repository.dart';

part 'inbox.g.dart';

/// The signed-in user's released messages, newest first. New (unopened) and
/// read ones together; the inbox splits them.
@riverpod
Future<List<InboxItem>> availableMessages(Ref ref) =>
    ref.watch(messagesRepositoryProvider).listAvailable();

/// Released message [id] with its content, or null if it isn't available
/// (unknown, someone else's, or still sealed). The first open is recorded
/// before showing it, so the inbox moves it to Read; a failure to record
/// never blocks reading.
@riverpod
Future<AvailableMessage?> openedMessage(Ref ref, String id) async {
  final repository = ref.watch(messagesRepositoryProvider);
  final message = await repository.getAvailable(id);
  if (message == null || message.openedAt != null) return message;
  try {
    await repository.markOpened(id);
    if (ref.mounted) ref.invalidate(availableMessagesProvider);
  } on AppError {
    // Stays new in the inbox; the next open records it.
  }
  return message;
}

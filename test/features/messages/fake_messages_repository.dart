import 'package:laternote/features/messages/data/messages_repository.dart';

/// In-memory [MessagesRepository]: records each call and throws [error]
/// when set.
class FakeMessagesRepository implements MessagesRepository {
  Object? error;
  final calls = <({String body, DateTime scheduledFor, String timezone})>[];

  @override
  Future<void> createScheduledMessage({
    required String body,
    required DateTime scheduledFor,
    required String timezone,
  }) async {
    calls.add((body: body, scheduledFor: scheduledFor, timezone: timezone));
    if (error case final error?) throw error;
  }
}

import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';

/// In-memory [MessagesRepository]: records each call and throws [error]
/// when set. Sealed messages show up in [listUpcoming] alongside [upcoming].
class FakeMessagesRepository implements MessagesRepository {
  Object? error;
  final calls = <({String body, DateTime scheduledFor, String timezone})>[];
  final upcoming = <ScheduledMessage>[];
  int listCalls = 0;

  @override
  Future<void> createScheduledMessage({
    required String body,
    required DateTime scheduledFor,
    required String timezone,
  }) async {
    calls.add((body: body, scheduledFor: scheduledFor, timezone: timezone));
    if (error case final error?) throw error;
    upcoming.add(
      ScheduledMessage(
        id: 'sealed-${calls.length}',
        scheduledFor: scheduledFor,
        timezone: timezone,
        createdAt: DateTime(2030),
      ),
    );
  }

  @override
  Future<List<ScheduledMessage>> listUpcoming() async {
    listCalls++;
    if (error case final error?) throw error;
    return [...upcoming]
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  }
}

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/messages_repository.dart';
import '../data/scheduled_message.dart';

part 'upcoming_messages.g.dart';

/// Sealed letters not ready yet, soonest first. Invalidate after
/// creating or deleting a message.
@riverpod
Future<List<ScheduledMessage>> upcomingMessages(Ref ref) =>
    ref.watch(messagesRepositoryProvider).listUpcoming();

import 'dart:async';

import 'package:laternote/features/messages/data/available_message.dart';
import 'package:laternote/features/messages/data/messages_repository.dart';
import 'package:laternote/features/messages/data/scheduled_message.dart';

/// In-memory [MessagesRepository]: records each call and throws [error]
/// when set. Sealed messages show up in [listUpcoming] alongside [upcoming].
class FakeMessagesRepository implements MessagesRepository {
  Object? error;
  final calls = <({String body, DateTime scheduledFor, String timezone})>[];
  final upcoming = <ScheduledMessage>[];
  int listCalls = 0;
  final deleted = <String>[];

  /// Released messages; [listAvailable] returns their metadata.
  final available = <AvailableMessage>[];
  final opened = <String>[];
  int getCalls = 0;

  /// Thrown only by [markOpened] when set.
  Object? markOpenedError;

  /// Completes a pending [deleteScheduledMessage] when set.
  Completer<void>? deleteGate;

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
  Future<void> deleteScheduledMessage(String id) async {
    deleted.add(id);
    await deleteGate?.future;
    if (error case final error?) throw error;
    upcoming.removeWhere((m) => m.id == id);
  }

  @override
  Future<List<ScheduledMessage>> listUpcoming() async {
    listCalls++;
    if (error case final error?) throw error;
    return [...upcoming]
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
  }

  @override
  Future<List<InboxItem>> listAvailable() async {
    listCalls++;
    if (error case final error?) throw error;
    return [
      for (final m in available)
        InboxItem(
          id: m.id,
          createdAt: m.createdAt,
          releasedAt: m.releasedAt,
          openedAt: m.openedAt,
        ),
    ]..sort((a, b) => b.releasedAt.compareTo(a.releasedAt));
  }

  @override
  Future<AvailableMessage?> getAvailable(String id) async {
    getCalls++;
    if (error case final error?) throw error;
    return available.where((m) => m.id == id).firstOrNull;
  }

  @override
  Future<void> markOpened(String id) async {
    opened.add(id);
    if (markOpenedError case final error?) throw error;
    final i = available.indexWhere((m) => m.id == id);
    if (i < 0 || available[i].openedAt != null) return;
    final m = available[i];
    available[i] = AvailableMessage(
      id: m.id,
      body: m.body,
      scheduledFor: m.scheduledFor,
      timezone: m.timezone,
      createdAt: m.createdAt,
      releasedAt: m.releasedAt,
      openedAt: DateTime(2030, 2),
    );
  }
}

/// A released message [id] with fixed dates.
AvailableMessage released(String id, {DateTime? openedAt}) => AvailableMessage(
  id: id,
  body: 'Body of $id',
  scheduledFor: DateTime(2030, 1, 1, 9),
  timezone: 'Europe/Rome',
  createdAt: DateTime(2029, 6, 1),
  releasedAt: DateTime(2030, 1, 1, 9, 0, 20),
  openedAt: openedAt,
);

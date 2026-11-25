import 'dart:async';

import 'package:laternote/features/notifications/data/local_notifications_repository.dart';

/// In-memory [LocalNotificationsRepository]: [pending] maps letter IDs to
/// their scheduled time, [calls] records permission requests and cancels,
/// and [error] makes [pendingLetterIds] throw.
class FakeLocalNotificationsRepository implements LocalNotificationsRepository {
  FakeLocalNotificationsRepository({
    this.status = NotificationAccess.granted,
    this.afterRequest = NotificationAccess.granted,
  });

  NotificationAccess status;

  /// What the system prompt answers.
  NotificationAccess afterRequest;
  final pending = <String, DateTime>{};
  final texts = <String, ReadyNotificationText>{};
  final calls = <String>[];
  Object? error;
  String? launchId;
  final taps = StreamController<String>.broadcast();

  Future<void> close() => taps.close();

  @override
  Future<NotificationAccess> permission() async => status;

  @override
  Future<NotificationAccess> requestPermission() async {
    calls.add('requestPermission');
    return status = afterRequest;
  }

  @override
  Future<Set<String>> pendingLetterIds() async {
    if (error case final error?) throw error;
    return pending.keys.toSet();
  }

  @override
  Future<void> schedule(
    String letterId,
    DateTime at,
    ReadyNotificationText text,
  ) async {
    pending[letterId] = at;
    texts[letterId] = text;
  }

  @override
  Future<void> cancel(String letterId) async {
    calls.add('cancel:$letterId');
    pending.remove(letterId);
  }

  @override
  Future<String?> launchLetterId() async => launchId;

  @override
  Stream<String> get tappedLetterIds => taps.stream;
}

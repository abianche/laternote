import 'dart:async';

import 'package:laternote/features/notifications/data/device_token_repository.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';

/// In-memory [PushRepository]: [calls] records what was asked of FCM and
/// [error] makes [register] throw. Push events come from the controllers.
class FakePushRepository implements PushRepository {
  FakePushRepository({
    this.status = PushPermission.granted,
    this.afterRequest = PushPermission.granted,
  });

  PushPermission status;

  /// What the system prompt answers.
  PushPermission afterRequest;
  String fid = 'fid-1';
  Object? error;
  String? initialMessageId;
  final calls = <String>[];

  final registered = StreamController<String>.broadcast();
  final opened = StreamController<String>.broadcast();
  final received = StreamController<void>.broadcast();

  Future<void> close() async {
    await registered.close();
    await opened.close();
    await received.close();
  }

  @override
  String get platform => 'android';

  @override
  Future<PushPermission> permission() async => status;

  @override
  Future<PushPermission> requestPermission() async {
    calls.add('requestPermission');
    return status = afterRequest;
  }

  @override
  Future<String> register() async {
    calls.add('register');
    if (error case final error?) throw error;
    return fid;
  }

  @override
  Stream<String> get registrations => registered.stream;

  @override
  Future<void> unregister() async => calls.add('unregister');

  @override
  Future<String?> initialOpenedMessageId() async => initialMessageId;

  @override
  Stream<String> get openedMessageIds => opened.stream;

  @override
  Stream<void> get foregroundMessages => received.stream;
}

/// In-memory [DeviceTokenRepository] recording each call into [log], which
/// can be shared to check ordering against other fakes.
class FakeDeviceTokenRepository implements DeviceTokenRepository {
  FakeDeviceTokenRepository([List<String>? log]) : calls = log ?? [];

  final List<String> calls;
  Object? error;

  @override
  Future<void> register(String token, String platform) async {
    calls.add('register:$token:$platform');
    if (error case final error?) throw error;
  }

  @override
  Future<void> remove(String token) async {
    calls.add('remove:$token');
    if (error case final error?) throw error;
  }
}

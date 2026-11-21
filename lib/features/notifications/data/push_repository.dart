import 'dart:io';

import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'push_repository.g.dart';

/// Whether the app may show notifications.
enum PushPermission { notDetermined, granted, denied }

PushPermission pushPermissionFrom(AuthorizationStatus status) =>
    switch (status) {
      AuthorizationStatus.authorized ||
      AuthorizationStatus.provisional => PushPermission.granted,
      AuthorizationStatus.denied ||
      AuthorizationStatus.deniedPermanently => PushPermission.denied,
      AuthorizationStatus.notDetermined => PushPermission.notDetermined,
    };

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// The message a notification is about, from its data payload, or null if
/// it isn't a well-formed message notification. Only the ID is trusted; the
/// app builds the route itself.
String? messageIdFrom(Map<String, dynamic> data) =>
    switch (data['message_id']) {
      final String id when _uuid.hasMatch(id) => id,
      _ => null,
    };

/// The only place that talks to Firebase Cloud Messaging. Failures are
/// left to the caller, which treats push as best effort.
class PushRepository {
  PushRepository(this._messaging, this._installations);

  final FirebaseMessaging _messaging;
  final FirebaseInstallations _installations;

  /// The platform as `register_device_token` expects it.
  String get platform => Platform.isIOS ? 'ios' : 'android';

  Future<PushPermission> permission() async => pushPermissionFrom(
    (await _messaging.getNotificationSettings()).authorizationStatus,
  );

  /// Shows the system prompt if the user hasn't decided yet.
  Future<PushPermission> requestPermission() async => pushPermissionFrom(
    (await _messaging.requestPermission()).authorizationStatus,
  );

  /// Registers this app install with FCM and returns its Firebase
  /// Installation ID (FID), the address the server sends to. Throws on iOS
  /// until APNs is set up.
  Future<String> register() async {
    await _messaging.register();
    return _installations.getId();
  }

  /// A new FID after FCM registered this install again.
  Stream<String> get registrations => _messaging.onRegistered;

  /// Stops FCM delivery to this install, so the server drops its FID on the
  /// next send.
  Future<void> unregister() => _messaging.unregister();

  /// The message whose notification launched the app, if any.
  Future<String?> initialOpenedMessageId() async {
    final message = await _messaging.getInitialMessage();
    return message == null ? null : messageIdFrom(message.data);
  }

  /// Messages whose notification is tapped while the app is running.
  Stream<String> get openedMessageIds =>
      FirebaseMessaging.onMessageOpenedApp.expand((message) sync* {
        if (messageIdFrom(message.data) case final id?) yield id;
      });

  /// A notification received while the app is in the foreground.
  Stream<void> get foregroundMessages =>
      FirebaseMessaging.onMessage.map((_) {});
}

@Riverpod(keepAlive: true)
PushRepository pushRepository(Ref ref) =>
    PushRepository(FirebaseMessaging.instance, FirebaseInstallations.instance);

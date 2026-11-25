import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timezone/timezone.dart' as tz;

part 'local_notifications_repository.g.dart';

/// Whether the app may show notifications.
enum NotificationAccess { notDetermined, granted, denied }

/// The OS only says whether notifications are on, so "never asked" is told
/// apart from "denied" by whether this install has asked.
NotificationAccess notificationAccessFrom({
  required bool enabled,
  required bool asked,
}) => enabled
    ? NotificationAccess.granted
    : asked
    ? NotificationAccess.denied
    : NotificationAccess.notDetermined;

/// The generic, localized text of a ready notification. Never letter content.
typedef ReadyNotificationText = ({
  String title,
  String body,
  String channelName,
});

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

/// The letter a notification is about, from its payload, or null if it
/// isn't a letter ID. The app builds the route itself.
String? letterIdFrom(String? payload) =>
    payload != null && _uuid.hasMatch(payload) ? payload : null;

/// The OS notification ID for letter [letterId] (a UUID): its first 32 bits,
/// kept positive. With at most [maxPendingNotifications] pending, two
/// letters sharing an ID is about one in a million.
int notificationIdFor(String letterId) =>
    int.parse(letterId.substring(0, 8), radix: 16) & 0x7fffffff;

/// iOS keeps only 64 pending notifications per app; Android uses the same cap.
const maxPendingNotifications = 64;

/// The only place that talks to the notification plugin. Failures are left
/// to the caller, which treats notifications as best effort.
class LocalNotificationsRepository {
  LocalNotificationsRepository(this._plugin, this._storage);

  static const _askedKey = 'notifications_asked';
  static const _channelId = 'ready_letters';

  final FlutterLocalNotificationsPlugin _plugin;
  final FlutterSecureStorage _storage;
  final _taps = StreamController<String>.broadcast();
  Future<void>? _initialized;

  /// Sets the plugin up once, without asking for permission.
  Future<void> _ready() => _initialized ??= _plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('ic_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestSoundPermission: false,
        requestBadgePermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: (response) {
      if (letterIdFrom(response.payload) case final id?) _taps.add(id);
    },
  );

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get _ios => _plugin
      .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<NotificationAccess> permission() async {
    await _ready();
    return notificationAccessFrom(
      enabled: await _enabled(),
      asked: await _storage.read(key: _askedKey) != null,
    );
  }

  /// Shows the system prompt; once the OS has an answer it just returns it.
  Future<NotificationAccess> requestPermission() async {
    await _ready();
    await _storage.write(key: _askedKey, value: 'true');
    final granted = switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        await _android?.requestNotificationsPermission(),
      TargetPlatform.iOS => await _ios?.requestPermissions(
        alert: true,
        sound: true,
      ),
      _ => false,
    };
    return granted ?? false
        ? NotificationAccess.granted
        : NotificationAccess.denied;
  }

  Future<bool> _enabled() async =>
      switch (defaultTargetPlatform) {
        TargetPlatform.android => await _android?.areNotificationsEnabled(),
        TargetPlatform.iOS => (await _ios?.checkPermissions())?.isEnabled,
        _ => false,
      } ??
      false;

  /// Letters with a notification still to come.
  Future<Set<String>> pendingLetterIds() async {
    await _ready();
    return {
      for (final request in await _plugin.pendingNotificationRequests())
        ?letterIdFrom(request.payload),
    };
  }

  /// Schedules (or replaces) letter [letterId]'s notification at [at].
  /// Inexact on Android, so no exact-alarm permission is needed.
  Future<void> schedule(
    String letterId,
    DateTime at,
    ReadyNotificationText text,
  ) async {
    await _ready();
    await _plugin.zonedSchedule(
      id: notificationIdFor(letterId),
      scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
      title: text.title,
      body: text.body,
      payload: letterId,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          text.channelName,
          visibility: NotificationVisibility.private,
        ),
      ),
    );
  }

  Future<void> cancel(String letterId) async {
    await _ready();
    await _plugin.cancel(id: notificationIdFor(letterId));
  }

  /// The letter whose notification launched the app, if any.
  Future<String?> launchLetterId() async {
    await _ready();
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return letterIdFrom(details.notificationResponse?.payload);
  }

  /// Letters whose notification is tapped while the app runs.
  Stream<String> get tappedLetterIds => _taps.stream;
}

@Riverpod(keepAlive: true)
LocalNotificationsRepository localNotificationsRepository(Ref ref) =>
    LocalNotificationsRepository(
      FlutterLocalNotificationsPlugin(),
      const FlutterSecureStorage(
        iOptions: IOSOptions(
          accessibility: KeychainAccessibility.first_unlock_this_device,
        ),
      ),
    );

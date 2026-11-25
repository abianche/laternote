import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/local_notifications_repository.dart';

part 'notification_permission.g.dart';

/// Whether the app may show notifications. Re-read whenever the app
/// resumes, since the user can change it in the device settings.
@Riverpod(keepAlive: true)
class NotificationPermission extends _$NotificationPermission {
  @override
  Future<NotificationAccess> build() {
    final listener = AppLifecycleListener(onResume: ref.invalidateSelf);
    ref.onDispose(listener.dispose);
    return ref.watch(localNotificationsRepositoryProvider).permission();
  }

  /// Shows the system prompt; does nothing once the user has decided.
  Future<void> request() async {
    final result = await AsyncValue.guard(
      ref.read(localNotificationsRepositoryProvider).requestPermission,
    );
    if (ref.mounted) state = result;
  }
}

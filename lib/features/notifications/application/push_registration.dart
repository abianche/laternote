import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_status_provider.dart';
import '../../auth/data/auth_status.dart';
import '../data/device_token_repository.dart';
import '../data/push_repository.dart';
import 'notification_permission.dart';

part 'push_registration.g.dart';

/// How long sign-out waits to remove this device's push address.
const unregisterTimeout = Duration(seconds: 5);

/// Keeps this device's push address (its Firebase Installation ID, stored
/// in `device_tokens`) assigned to the signed-in user: after sign-in, once
/// permission is granted and whenever FCM registers the install again.
/// Push is best effort: every failure is swallowed so it never gets in the
/// way of signing in, sealing or reading the inbox.
@Riverpod(keepAlive: true)
class PushRegistration extends _$PushRegistration {
  /// The FID registered for the current user, if any.
  String? _token;

  @override
  void build() {
    final push = ref.watch(pushRepositoryProvider);
    final refreshes = push.registrations.listen(
      _register,
      onError: _report,
    );
    ref.onDispose(refreshes.cancel);

    ref.listen(authStatusProvider, (_, next) {
      switch (next) {
        case AsyncData(value: SignedIn()):
          _sync();
        case AsyncData(value: SignedOut()):
          _forget();
        default:
      }
    }, fireImmediately: true);

    // Only a change to granted, e.g. from the prompt: sign-in already
    // syncs with the permission it finds.
    ref.listen(notificationPermissionProvider, (previous, next) {
      if (previous?.value case final before?
          when before != PushPermission.granted &&
              next.value == PushPermission.granted) {
        _sync();
      }
    });
  }

  /// Removes this device's FID from the account. Called before signing
  /// out, while the session can still delete it; never throws.
  Future<void> unregister() async {
    final token = _token;
    if (token == null) return;
    _token = null;
    try {
      await ref
          .read(deviceTokenRepositoryProvider)
          .remove(token)
          .timeout(unregisterTimeout);
    } on Object catch (error) {
      // The install is also unregistered from FCM on sign-out, so the server
      // drops it on its next send.
      _report(error);
    }
  }

  bool get _signedIn => ref.read(authStatusProvider).value is SignedIn;

  Future<void> _sync() async {
    if (!_signedIn) return;
    try {
      final push = ref.read(pushRepositoryProvider);
      if (await push.permission() != PushPermission.granted) return;
      await _register(await push.register());
    } on Object catch (error) {
      _report(error);
    }
  }

  Future<void> _register(String token) async {
    if (!ref.mounted || !_signedIn) return;
    try {
      await ref
          .read(deviceTokenRepositoryProvider)
          .register(token, ref.read(pushRepositoryProvider).platform);
      _token = token;
    } on Object catch (error) {
      _report(error);
    }
  }

  /// However the session ended, this device stops receiving the previous
  /// user's notifications.
  void _forget() {
    _token = null;
    unawaited(
      ref.read(pushRepositoryProvider).unregister().catchError(_report),
    );
  }

  // The error type only: never FIDs in logs.
  void _report(Object error) =>
      debugPrint('Push registration skipped: ${error.runtimeType}');
}

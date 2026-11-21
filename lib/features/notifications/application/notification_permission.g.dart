// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_permission.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the app may show notifications. Re-read whenever the app
/// resumes, since the user can change it in the device settings.

@ProviderFor(NotificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

/// Whether the app may show notifications. Re-read whenever the app
/// resumes, since the user can change it in the device settings.
final class NotificationPermissionProvider
    extends $AsyncNotifierProvider<NotificationPermission, PushPermission> {
  /// Whether the app may show notifications. Re-read whenever the app
  /// resumes, since the user can change it in the device settings.
  NotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionHash();

  @$internal
  @override
  NotificationPermission create() => NotificationPermission();
}

String _$notificationPermissionHash() =>
    r'032c2367e6603d1cd675c3f3b12c9173858b67c9';

/// Whether the app may show notifications. Re-read whenever the app
/// resumes, since the user can change it in the device settings.

abstract class _$NotificationPermission extends $AsyncNotifier<PushPermission> {
  FutureOr<PushPermission> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PushPermission>, PushPermission>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PushPermission>, PushPermission>,
              AsyncValue<PushPermission>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

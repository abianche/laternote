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
    extends $AsyncNotifierProvider<NotificationPermission, NotificationAccess> {
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
    r'ade93956c576310846900986a378a0feb170cae6';

/// Whether the app may show notifications. Re-read whenever the app
/// resumes, since the user can change it in the device settings.

abstract class _$NotificationPermission
    extends $AsyncNotifier<NotificationAccess> {
  FutureOr<NotificationAccess> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<NotificationAccess>, NotificationAccess>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<NotificationAccess>, NotificationAccess>,
              AsyncValue<NotificationAccess>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

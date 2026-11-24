// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_notifications.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps one notification pending for each of the nearest letters. Synced
/// when the app starts (OS updates, reinstalls and restores can drop them)
/// and after every seal and delete. Notifications are best effort: every
/// failure is swallowed so they never get in the way of sealing or deleting.

@ProviderFor(ReadyNotifications)
final readyNotificationsProvider = ReadyNotificationsProvider._();

/// Keeps one notification pending for each of the nearest letters. Synced
/// when the app starts (OS updates, reinstalls and restores can drop them)
/// and after every seal and delete. Notifications are best effort: every
/// failure is swallowed so they never get in the way of sealing or deleting.
final class ReadyNotificationsProvider
    extends $NotifierProvider<ReadyNotifications, void> {
  /// Keeps one notification pending for each of the nearest letters. Synced
  /// when the app starts (OS updates, reinstalls and restores can drop them)
  /// and after every seal and delete. Notifications are best effort: every
  /// failure is swallowed so they never get in the way of sealing or deleting.
  ReadyNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readyNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readyNotificationsHash();

  @$internal
  @override
  ReadyNotifications create() => ReadyNotifications();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$readyNotificationsHash() =>
    r'44edd093d5f885d10401d795fb8d3b4ee94cf049';

/// Keeps one notification pending for each of the nearest letters. Synced
/// when the app starts (OS updates, reinstalls and restores can drop them)
/// and after every seal and delete. Notifications are best effort: every
/// failure is swallowed so they never get in the way of sealing or deleting.

abstract class _$ReadyNotifications extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

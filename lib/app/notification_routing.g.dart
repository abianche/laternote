// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_routing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opens the message whose notification the user tapped, both the one that
/// launched the app and any tapped while it runs. Signed out, the router
/// sends them to sign-in first and on to the message after. A notification
/// arriving while the app is open refreshes the lists instead.

@ProviderFor(notificationRouting)
final notificationRoutingProvider = NotificationRoutingProvider._();

/// Opens the message whose notification the user tapped, both the one that
/// launched the app and any tapped while it runs. Signed out, the router
/// sends them to sign-in first and on to the message after. A notification
/// arriving while the app is open refreshes the lists instead.

final class NotificationRoutingProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Opens the message whose notification the user tapped, both the one that
  /// launched the app and any tapped while it runs. Signed out, the router
  /// sends them to sign-in first and on to the message after. A notification
  /// arriving while the app is open refreshes the lists instead.
  NotificationRoutingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRoutingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRoutingHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return notificationRouting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$notificationRoutingHash() =>
    r'a1f53ea4dac1e23967f8f43451404bc3d59b37a8';

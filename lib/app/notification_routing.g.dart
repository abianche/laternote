// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_routing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Opens the letter whose notification the user tapped, both the one that
/// launched the app and any tapped while it runs, or the inbox if the
/// letter is gone. Signed out, the router sends them to sign-in first and
/// on to the letter after.

@ProviderFor(notificationRouting)
final notificationRoutingProvider = NotificationRoutingProvider._();

/// Opens the letter whose notification the user tapped, both the one that
/// launched the app and any tapped while it runs, or the inbox if the
/// letter is gone. Signed out, the router sends them to sign-in first and
/// on to the letter after.

final class NotificationRoutingProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Opens the letter whose notification the user tapped, both the one that
  /// launched the app and any tapped while it runs, or the inbox if the
  /// letter is gone. Signed out, the router sends them to sign-in first and
  /// on to the letter after.
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
    r'e973c9a8f7046ec5b816a5662b5cadb22f460971';

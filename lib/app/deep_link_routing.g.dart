// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_link_routing.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Follows every link the OS hands to the app, whether it launched the app
/// or arrived while it was in the background or foreground. Auth links are
/// exchanged for a session, then the user lands on the screen for that
/// kind of link; anything that fails lands on an explanation.

@ProviderFor(deepLinkRouting)
final deepLinkRoutingProvider = DeepLinkRoutingProvider._();

/// Follows every link the OS hands to the app, whether it launched the app
/// or arrived while it was in the background or foreground. Auth links are
/// exchanged for a session, then the user lands on the screen for that
/// kind of link; anything that fails lands on an explanation.

final class DeepLinkRoutingProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Follows every link the OS hands to the app, whether it launched the app
  /// or arrived while it was in the background or foreground. Auth links are
  /// exchanged for a session, then the user lands on the screen for that
  /// kind of link; anything that fails lands on an explanation.
  DeepLinkRoutingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepLinkRoutingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepLinkRoutingHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return deepLinkRouting(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$deepLinkRoutingHash() => r'65a3a66c6d2d79e32223d8f6a73f3a9f05cecd05';

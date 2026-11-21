// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_registration.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps this device's push address (its Firebase Installation ID, stored
/// in `device_tokens`) assigned to the signed-in user: after sign-in, once
/// permission is granted and whenever FCM registers the install again.
/// Push is best effort: every failure is swallowed so it never gets in the
/// way of signing in, sealing or reading the inbox.

@ProviderFor(PushRegistration)
final pushRegistrationProvider = PushRegistrationProvider._();

/// Keeps this device's push address (its Firebase Installation ID, stored
/// in `device_tokens`) assigned to the signed-in user: after sign-in, once
/// permission is granted and whenever FCM registers the install again.
/// Push is best effort: every failure is swallowed so it never gets in the
/// way of signing in, sealing or reading the inbox.
final class PushRegistrationProvider
    extends $NotifierProvider<PushRegistration, void> {
  /// Keeps this device's push address (its Firebase Installation ID, stored
  /// in `device_tokens`) assigned to the signed-in user: after sign-in, once
  /// permission is granted and whenever FCM registers the install again.
  /// Push is best effort: every failure is swallowed so it never gets in the
  /// way of signing in, sealing or reading the inbox.
  PushRegistrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushRegistrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushRegistrationHash();

  @$internal
  @override
  PushRegistration create() => PushRegistration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pushRegistrationHash() => r'933c364252d07c6aa46637a19c77c4ebddcbfe3e';

/// Keeps this device's push address (its Firebase Installation ID, stored
/// in `device_tokens`) assigned to the signed-in user: after sign-in, once
/// permission is granted and whenever FCM registers the install again.
/// Push is best effort: every failure is swallowed so it never gets in the
/// way of signing in, sealing or reading the inbox.

abstract class _$PushRegistration extends $Notifier<void> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The device's IANA time zone (e.g. `Europe/Rome`). Local [DateTime]s are
/// in this zone, so `toUtc()` gives the matching instant.

@ProviderFor(deviceTimezone)
final deviceTimezoneProvider = DeviceTimezoneProvider._();

/// The device's IANA time zone (e.g. `Europe/Rome`). Local [DateTime]s are
/// in this zone, so `toUtc()` gives the matching instant.

final class DeviceTimezoneProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The device's IANA time zone (e.g. `Europe/Rome`). Local [DateTime]s are
  /// in this zone, so `toUtc()` gives the matching instant.
  DeviceTimezoneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceTimezoneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceTimezoneHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return deviceTimezone(ref);
  }
}

String _$deviceTimezoneHash() => r'039acde58df262d7ab50de8b598ed4288bc2f6eb';

/// The message being composed, shared by the compose and review screens.

@ProviderFor(ComposeDraft)
final composeDraftProvider = ComposeDraftProvider._();

/// The message being composed, shared by the compose and review screens.
final class ComposeDraftProvider
    extends $NotifierProvider<ComposeDraft, MessageDraft> {
  /// The message being composed, shared by the compose and review screens.
  ComposeDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'composeDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$composeDraftHash();

  @$internal
  @override
  ComposeDraft create() => ComposeDraft();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MessageDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MessageDraft>(value),
    );
  }
}

String _$composeDraftHash() => r'ae5de75a23f0f1319a17a5fd1ab74162121ea8c7';

/// The message being composed, shared by the compose and review screens.

abstract class _$ComposeDraft extends $Notifier<MessageDraft> {
  MessageDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<MessageDraft, MessageDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MessageDraft, MessageDraft>,
              MessageDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Saves the draft. Holds true once sealed.

@ProviderFor(SealMessageController)
final sealMessageControllerProvider = SealMessageControllerProvider._();

/// Saves the draft. Holds true once sealed.
final class SealMessageControllerProvider
    extends $AsyncNotifierProvider<SealMessageController, bool> {
  /// Saves the draft. Holds true once sealed.
  SealMessageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sealMessageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sealMessageControllerHash();

  @$internal
  @override
  SealMessageController create() => SealMessageController();
}

String _$sealMessageControllerHash() =>
    r'48cae5fd02ce3537a76f9c03bc325247b7aee256';

/// Saves the draft. Holds true once sealed.

abstract class _$SealMessageController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

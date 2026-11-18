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

/// Whether the last attempt to save the draft on the device failed. Cleared
/// by the next successful save.

@ProviderFor(DraftSaveFailed)
final draftSaveFailedProvider = DraftSaveFailedProvider._();

/// Whether the last attempt to save the draft on the device failed. Cleared
/// by the next successful save.
final class DraftSaveFailedProvider
    extends $NotifierProvider<DraftSaveFailed, bool> {
  /// Whether the last attempt to save the draft on the device failed. Cleared
  /// by the next successful save.
  DraftSaveFailedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftSaveFailedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftSaveFailedHash();

  @$internal
  @override
  DraftSaveFailed create() => DraftSaveFailed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$draftSaveFailedHash() => r'fa1f262927af220631c2a44639025fb68fd1804c';

/// Whether the last attempt to save the draft on the device failed. Cleared
/// by the next successful save.

abstract class _$DraftSaveFailed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The unsealed message being composed, shared by the compose and review
/// screens. Restored from and autosaved to the device; never synced.

@ProviderFor(ComposeDraft)
final composeDraftProvider = ComposeDraftProvider._();

/// The unsealed message being composed, shared by the compose and review
/// screens. Restored from and autosaved to the device; never synced.
final class ComposeDraftProvider
    extends $AsyncNotifierProvider<ComposeDraft, MessageDraft> {
  /// The unsealed message being composed, shared by the compose and review
  /// screens. Restored from and autosaved to the device; never synced.
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
}

String _$composeDraftHash() => r'50eefbd99dc2facf9a2bc3ce7a7c15c786a97a3b';

/// The unsealed message being composed, shared by the compose and review
/// screens. Restored from and autosaved to the device; never synced.

abstract class _$ComposeDraft extends $AsyncNotifier<MessageDraft> {
  FutureOr<MessageDraft> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<MessageDraft>, MessageDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<MessageDraft>, MessageDraft>,
              AsyncValue<MessageDraft>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Seals the draft: syncs it to Supabase as `scheduled`, then deletes the
/// local draft. Holds the delivery time once sealed.

@ProviderFor(SealMessageController)
final sealMessageControllerProvider = SealMessageControllerProvider._();

/// Seals the draft: syncs it to Supabase as `scheduled`, then deletes the
/// local draft. Holds the delivery time once sealed.
final class SealMessageControllerProvider
    extends $AsyncNotifierProvider<SealMessageController, DateTime?> {
  /// Seals the draft: syncs it to Supabase as `scheduled`, then deletes the
  /// local draft. Holds the delivery time once sealed.
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
    r'5c091e83fc2014abaa059fbcd29a0bbdb0413ad7';

/// Seals the draft: syncs it to Supabase as `scheduled`, then deletes the
/// local draft. Holds the delivery time once sealed.

abstract class _$SealMessageController extends $AsyncNotifier<DateTime?> {
  FutureOr<DateTime?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DateTime?>, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DateTime?>, DateTime?>,
              AsyncValue<DateTime?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

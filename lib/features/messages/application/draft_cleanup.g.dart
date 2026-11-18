// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'draft_cleanup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes the local draft whenever there is no session, however it ended
/// (sign-out, expiry, revoked refresh token), so a draft never outlives it.

@ProviderFor(draftCleanup)
final draftCleanupProvider = DraftCleanupProvider._();

/// Deletes the local draft whenever there is no session, however it ended
/// (sign-out, expiry, revoked refresh token), so a draft never outlives it.

final class DraftCleanupProvider extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Deletes the local draft whenever there is no session, however it ended
  /// (sign-out, expiry, revoked refresh token), so a draft never outlives it.
  DraftCleanupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftCleanupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftCleanupHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return draftCleanup(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$draftCleanupHash() => r'e9969202f6e07c354c16210c1a2fbe84e454f372';

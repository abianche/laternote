// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deep_link_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deepLinkRepository)
final deepLinkRepositoryProvider = DeepLinkRepositoryProvider._();

final class DeepLinkRepositoryProvider
    extends
        $FunctionalProvider<
          DeepLinkRepository,
          DeepLinkRepository,
          DeepLinkRepository
        >
    with $Provider<DeepLinkRepository> {
  DeepLinkRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deepLinkRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deepLinkRepositoryHash();

  @$internal
  @override
  $ProviderElement<DeepLinkRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeepLinkRepository create(Ref ref) {
    return deepLinkRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeepLinkRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeepLinkRepository>(value),
    );
  }
}

String _$deepLinkRepositoryHash() =>
    r'51e9e8a17cce6fd9349a4f420c6be3c6dc1b2988';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_notifications_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localNotificationsRepository)
final localNotificationsRepositoryProvider =
    LocalNotificationsRepositoryProvider._();

final class LocalNotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          LocalNotificationsRepository,
          LocalNotificationsRepository,
          LocalNotificationsRepository
        >
    with $Provider<LocalNotificationsRepository> {
  LocalNotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localNotificationsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localNotificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalNotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalNotificationsRepository create(Ref ref) {
    return localNotificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalNotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalNotificationsRepository>(value),
    );
  }
}

String _$localNotificationsRepositoryHash() =>
    r'7b3b8ae2e1540eea403d057670c97905b316635a';

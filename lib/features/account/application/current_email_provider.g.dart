// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_email_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Email of the signed-in user, or null.

@ProviderFor(currentEmail)
final currentEmailProvider = CurrentEmailProvider._();

/// Email of the signed-in user, or null.

final class CurrentEmailProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Email of the signed-in user, or null.
  CurrentEmailProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentEmailProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentEmailHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return currentEmail(ref);
  }
}

String _$currentEmailHash() => r'0edc25296b7db9c5ce2dad2af0d04b46f2c02d7d';

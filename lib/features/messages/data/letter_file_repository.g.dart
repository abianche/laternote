// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_file_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(letterFileRepository)
final letterFileRepositoryProvider = LetterFileRepositoryProvider._();

final class LetterFileRepositoryProvider
    extends
        $FunctionalProvider<
          LetterFileRepository,
          LetterFileRepository,
          LetterFileRepository
        >
    with $Provider<LetterFileRepository> {
  LetterFileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'letterFileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$letterFileRepositoryHash();

  @$internal
  @override
  $ProviderElement<LetterFileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LetterFileRepository create(Ref ref) {
    return letterFileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LetterFileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LetterFileRepository>(value),
    );
  }
}

String _$letterFileRepositoryHash() =>
    r'491ec8c3c047dc5422eb10ae9aa08f7fcd8312bc';

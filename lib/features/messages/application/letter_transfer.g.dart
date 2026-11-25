// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_transfer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run: the number of letters an import added, or null after an export
/// or a cancelled pick.

@ProviderFor(LetterTransfer)
final letterTransferProvider = LetterTransferProvider._();

/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run: the number of letters an import added, or null after an export
/// or a cancelled pick.
final class LetterTransferProvider
    extends $AsyncNotifierProvider<LetterTransfer, int?> {
  /// Exports letters to a file and imports them back. Holds the outcome of the
  /// last run: the number of letters an import added, or null after an export
  /// or a cancelled pick.
  LetterTransferProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'letterTransferProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$letterTransferHash();

  @$internal
  @override
  LetterTransfer create() => LetterTransfer();
}

String _$letterTransferHash() => r'536b1b1fecee9ab63be4b43f464b3b1637a6a07c';

/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run: the number of letters an import added, or null after an export
/// or a cancelled pick.

abstract class _$LetterTransfer extends $AsyncNotifier<int?> {
  FutureOr<int?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<int?>, int?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<int?>, int?>,
              AsyncValue<int?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

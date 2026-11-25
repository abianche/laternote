// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_transfer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run, or null when there is nothing to report (shared, or cancelled).

@ProviderFor(LetterTransfer)
final letterTransferProvider = LetterTransferProvider._();

/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run, or null when there is nothing to report (shared, or cancelled).
final class LetterTransferProvider
    extends $AsyncNotifierProvider<LetterTransfer, TransferOutcome?> {
  /// Exports letters to a file and imports them back. Holds the outcome of the
  /// last run, or null when there is nothing to report (shared, or cancelled).
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

String _$letterTransferHash() => r'9ddf6d298619c6561d97118c1a9180319a669147';

/// Exports letters to a file and imports them back. Holds the outcome of the
/// last run, or null when there is nothing to report (shared, or cancelled).

abstract class _$LetterTransfer extends $AsyncNotifier<TransferOutcome?> {
  FutureOr<TransferOutcome?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransferOutcome?>, TransferOutcome?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransferOutcome?>, TransferOutcome?>,
              AsyncValue<TransferOutcome?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_message_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes a sealed message before it opens, cancels its notification and
/// refreshes the upcoming list. Holds the outcome of the last deletion.

@ProviderFor(DeleteMessageController)
final deleteMessageControllerProvider = DeleteMessageControllerProvider._();

/// Deletes a sealed message before it opens, cancels its notification and
/// refreshes the upcoming list. Holds the outcome of the last deletion.
final class DeleteMessageControllerProvider
    extends $AsyncNotifierProvider<DeleteMessageController, void> {
  /// Deletes a sealed message before it opens, cancels its notification and
  /// refreshes the upcoming list. Holds the outcome of the last deletion.
  DeleteMessageControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteMessageControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteMessageControllerHash();

  @$internal
  @override
  DeleteMessageController create() => DeleteMessageController();
}

String _$deleteMessageControllerHash() =>
    r'6d7ee3d14962cd45fc304a12c2141e83ce68a644';

/// Deletes a sealed message before it opens, cancels its notification and
/// refreshes the upcoming list. Holds the outcome of the last deletion.

abstract class _$DeleteMessageController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

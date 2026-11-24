// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inbox.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ready letters, newest first. New (unopened) and
/// read ones together; the inbox splits them.

@ProviderFor(availableMessages)
final availableMessagesProvider = AvailableMessagesProvider._();

/// Ready letters, newest first. New (unopened) and
/// read ones together; the inbox splits them.

final class AvailableMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<InboxItem>>,
          List<InboxItem>,
          FutureOr<List<InboxItem>>
        >
    with $FutureModifier<List<InboxItem>>, $FutureProvider<List<InboxItem>> {
  /// Ready letters, newest first. New (unopened) and
  /// read ones together; the inbox splits them.
  AvailableMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'availableMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$availableMessagesHash();

  @$internal
  @override
  $FutureProviderElement<List<InboxItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<InboxItem>> create(Ref ref) {
    return availableMessages(ref);
  }
}

String _$availableMessagesHash() => r'6f0d51faee6b17d5ef6fd3d7676e3b2a4aec58a2';

/// Ready letter [id] with its content, or null if it isn't available
/// (unknown or still sealed). The first open is recorded
/// before showing it, so the inbox moves it to Read; a failure to record
/// never blocks reading.

@ProviderFor(openedMessage)
final openedMessageProvider = OpenedMessageFamily._();

/// Ready letter [id] with its content, or null if it isn't available
/// (unknown or still sealed). The first open is recorded
/// before showing it, so the inbox moves it to Read; a failure to record
/// never blocks reading.

final class OpenedMessageProvider
    extends
        $FunctionalProvider<
          AsyncValue<AvailableMessage?>,
          AvailableMessage?,
          FutureOr<AvailableMessage?>
        >
    with
        $FutureModifier<AvailableMessage?>,
        $FutureProvider<AvailableMessage?> {
  /// Ready letter [id] with its content, or null if it isn't available
  /// (unknown or still sealed). The first open is recorded
  /// before showing it, so the inbox moves it to Read; a failure to record
  /// never blocks reading.
  OpenedMessageProvider._({
    required OpenedMessageFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'openedMessageProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$openedMessageHash();

  @override
  String toString() {
    return r'openedMessageProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AvailableMessage?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AvailableMessage?> create(Ref ref) {
    final argument = this.argument as String;
    return openedMessage(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OpenedMessageProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$openedMessageHash() => r'7d0d92a080a316f62ccc8e1cb379db0b4e79ffe8';

/// Ready letter [id] with its content, or null if it isn't available
/// (unknown or still sealed). The first open is recorded
/// before showing it, so the inbox moves it to Read; a failure to record
/// never blocks reading.

final class OpenedMessageFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AvailableMessage?>, String> {
  OpenedMessageFamily._()
    : super(
        retry: null,
        name: r'openedMessageProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Ready letter [id] with its content, or null if it isn't available
  /// (unknown or still sealed). The first open is recorded
  /// before showing it, so the inbox moves it to Read; a failure to record
  /// never blocks reading.

  OpenedMessageProvider call(String id) =>
      OpenedMessageProvider._(argument: id, from: this);

  @override
  String toString() => r'openedMessageProvider';
}

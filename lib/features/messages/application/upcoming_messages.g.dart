// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upcoming_messages.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The signed-in user's sealed messages, soonest first. Invalidate after
/// creating, editing or deleting a message.

@ProviderFor(upcomingMessages)
final upcomingMessagesProvider = UpcomingMessagesProvider._();

/// The signed-in user's sealed messages, soonest first. Invalidate after
/// creating, editing or deleting a message.

final class UpcomingMessagesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ScheduledMessage>>,
          List<ScheduledMessage>,
          FutureOr<List<ScheduledMessage>>
        >
    with
        $FutureModifier<List<ScheduledMessage>>,
        $FutureProvider<List<ScheduledMessage>> {
  /// The signed-in user's sealed messages, soonest first. Invalidate after
  /// creating, editing or deleting a message.
  UpcomingMessagesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingMessagesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingMessagesHash();

  @$internal
  @override
  $FutureProviderElement<List<ScheduledMessage>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ScheduledMessage>> create(Ref ref) {
    return upcomingMessages(ref);
  }
}

String _$upcomingMessagesHash() => r'de0669275c639d3de17bcee761e1b27e432f440f';

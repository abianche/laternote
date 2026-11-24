// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ready_notification_text.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The ready notification's text in the app's language, resolved from the
/// device locales the same way `MaterialApp` does. Read again on every sync,
/// so it follows a change of device language.

@ProviderFor(readyNotificationText)
final readyNotificationTextProvider = ReadyNotificationTextProvider._();

/// The ready notification's text in the app's language, resolved from the
/// device locales the same way `MaterialApp` does. Read again on every sync,
/// so it follows a change of device language.

final class ReadyNotificationTextProvider
    extends
        $FunctionalProvider<
          ReadyNotificationText,
          ReadyNotificationText,
          ReadyNotificationText
        >
    with $Provider<ReadyNotificationText> {
  /// The ready notification's text in the app's language, resolved from the
  /// device locales the same way `MaterialApp` does. Read again on every sync,
  /// so it follows a change of device language.
  ReadyNotificationTextProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'readyNotificationTextProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$readyNotificationTextHash();

  @$internal
  @override
  $ProviderElement<ReadyNotificationText> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReadyNotificationText create(Ref ref) {
    return readyNotificationText(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReadyNotificationText value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReadyNotificationText>(value),
    );
  }
}

String _$readyNotificationTextHash() =>
    r'2aa56bd4e814de743e8aa3284e65dc35d8a30cc1';

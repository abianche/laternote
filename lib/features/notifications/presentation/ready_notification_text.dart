import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../l10n/app_localizations.dart';
import '../data/local_notifications_repository.dart';

part 'ready_notification_text.g.dart';

/// The ready notification's text in the app's language, resolved from the
/// device locales the same way `MaterialApp` does. Read again on every sync,
/// so it follows a change of device language.
@riverpod
ReadyNotificationText readyNotificationText(Ref ref) {
  final l10n = lookupAppLocalizations(
    basicLocaleListResolution(
      WidgetsBinding.instance.platformDispatcher.locales,
      AppLocalizations.supportedLocales,
    ),
  );
  return (
    title: l10n.notificationReadyTitle,
    body: l10n.notificationReadyBody,
    channelName: l10n.notificationChannelName,
  );
}

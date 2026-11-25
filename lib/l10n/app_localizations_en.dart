// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get errorNetwork => 'No connection. Check your network and try again.';

  @override
  String get errorUnexpected => 'Something went wrong. Please try again.';

  @override
  String get errorInvalidFile =>
      'This file isn\'t a Laternote export or is damaged. Nothing was imported.';

  @override
  String get validationBodyEmpty => 'Write something to your future self.';

  @override
  String validationBodyTooLong(int max) {
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);

    return 'Keep it under $maxString characters.';
  }

  @override
  String get validationDeliveryMissing => 'Pick a delivery date and time.';

  @override
  String get validationDeliveryInPast => 'Pick a time in the future.';

  @override
  String get validationAlreadyOpening =>
      'This message is already opening, so it can\'t be deleted.';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get homeSettingsTooltip => 'Settings';

  @override
  String get homeInboxTab => 'Inbox';

  @override
  String get homeSealedTab => 'Sealed';

  @override
  String get homeNewMessage => 'New message';

  @override
  String get inboxLoading => 'Loading your inbox…';

  @override
  String get inboxEmpty =>
      'Nothing has opened yet. Your messages arrive here when their time comes.';

  @override
  String get inboxNewHeader => 'New';

  @override
  String get inboxReadHeader => 'Read';

  @override
  String inboxArrived(String date) {
    return 'Arrived $date';
  }

  @override
  String inboxWrittenOn(String date) {
    return 'Written on $date';
  }

  @override
  String get sealedLoading =>
      'Loading your sealed messages… You can start a new one meanwhile.';

  @override
  String get sealedEmpty =>
      'Nothing sealed yet. Tap New message to write to your future self.';

  @override
  String get sealedOpeningSoon => 'Opening soon';

  @override
  String sealedOpens(String delivery) {
    return 'Opens $delivery';
  }

  @override
  String sealedOn(String date) {
    return 'Sealed on $date';
  }

  @override
  String sealedCountdown(String duration) {
    return 'in $duration';
  }

  @override
  String countdownYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String countdownMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String countdownDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String countdownHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String countdownMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get countdownUnderMinute => 'less than a minute';

  @override
  String get sealedDeleted => 'Message deleted.';

  @override
  String get sealedDeleteTitle => 'Delete this sealed message?';

  @override
  String get sealedDeleteContent =>
      'It will never open. This can\'t be undone.';

  @override
  String get messageTitle => 'Message';

  @override
  String get messageOpeningEnvelope => 'Opening the envelope. Tap to skip.';

  @override
  String get messageUnavailable =>
      'This message isn\'t available. It may not have opened yet, or it was deleted.';

  @override
  String get messageOpening => 'Opening your message…';

  @override
  String messageWrittenOn(String date) {
    return 'Written on $date';
  }

  @override
  String messageSetToOpen(String delivery) {
    return 'Set to open $delivery';
  }

  @override
  String deliveryDateTime(String date, String time) {
    return '$date at $time';
  }

  @override
  String get composeTitle => 'New message';

  @override
  String get composeDiscardTooltip => 'Discard draft';

  @override
  String get composeDiscardTitle => 'Discard draft?';

  @override
  String get composeDiscardContent => 'It will be deleted from this device.';

  @override
  String get composeKeep => 'Keep';

  @override
  String get composeDiscard => 'Discard';

  @override
  String get composeBodyHint => 'Dear future me,';

  @override
  String get composeDeliverOn => 'Deliver on';

  @override
  String get composePickDateTime => 'Pick a date and time';

  @override
  String get composeSeal => 'Seal…';

  @override
  String get composeSaveFailed =>
      'Not saved on this device. Keep the app open or try again.';

  @override
  String get composeSavedLocally =>
      'Your draft is saved on this device only. Nothing is sent until you seal it.';

  @override
  String get reviewTitle => 'Review';

  @override
  String get reviewSealing => 'Sealing your message';

  @override
  String get reviewNoDeliveryTime => 'No delivery time';

  @override
  String get reviewSealedHint => 'Once sealed, you can\'t read it until then.';

  @override
  String get reviewSealButton => 'Seal message';

  @override
  String get reviewEdit => 'Edit';

  @override
  String reviewSealedUntil(String delivery) {
    return 'Sealed until $delivery.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsPrivacy => 'Privacy & data';

  @override
  String get settingsExport => 'Export letters';

  @override
  String get settingsExportSubtitle =>
      'Save a copy of all your letters as a file';

  @override
  String get settingsImport => 'Import letters';

  @override
  String get settingsImportSubtitle => 'Add letters from an exported file';

  @override
  String get exportWarningTitle => 'Export your letters?';

  @override
  String get exportWarningBody =>
      'The file isn\'t encrypted. It holds the text of all your letters, including sealed ones, and anyone with the file can read them.';

  @override
  String get exportWarningConfirm => 'Export';

  @override
  String importAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letters added',
      one: '1 letter added',
      zero: 'No new letters in this file',
    );
    return '$_temp0';
  }

  @override
  String get privacyTitle => 'Privacy & data';

  @override
  String get privacyDraftsTitle => 'Drafts stay on this device';

  @override
  String get privacyDraftsBody =>
      'While you write, your draft is saved encrypted on this device only. It is deleted when you seal it or discard it, and it is never included in backups.';

  @override
  String get privacySealedTitle => 'Sealed messages stay on this device';

  @override
  String get privacySealedBody =>
      'Laternote has no accounts and no servers. Sealed messages are stored on this device with their opening time and time zone, and never leave it except in backups of your device or exports you make.';

  @override
  String get privacyNotificationsTitle => 'Notifications';

  @override
  String get privacyNotificationsBody =>
      'A notification only says \"A message is ready\". It never contains what you wrote, so nothing private shows on your lock screen. Your phone schedules it itself when you seal a message, so nothing is sent anywhere.';

  @override
  String get privacyTrackingTitle => 'No tracking';

  @override
  String get privacyTrackingBody =>
      'Laternote has no analytics, ads or crash reporting.';

  @override
  String get privacyDeletionTitle => 'Deleting your messages';

  @override
  String get privacyDeletionBody =>
      'Uninstalling Laternote deletes your messages and draft from this device. Copies in your device backups or in files you exported stay until you delete them.';

  @override
  String get privacyBackupsTitle => 'Backups';

  @override
  String get privacyBackupsBody =>
      'Your sealed messages are included in your device\'s backup, so restoring it brings them back. The seal follows this device\'s clock: anyone who changes the clock or reads the app\'s files can open a message early.';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsOn => 'On. You\'ll hear when a message opens.';

  @override
  String get notificationsDenied =>
      'Off. Turn them on in your device settings.';

  @override
  String get notificationsUndecided => 'Off. Tap to turn on.';

  @override
  String get notificationsUnavailable => 'Not available on this device.';

  @override
  String get notificationsPromptTitle => 'Know when it opens';

  @override
  String get notificationsPromptContent =>
      'We\'ll send a notification when a message is ready to read. It never shows what you wrote.';

  @override
  String get notificationsNotNow => 'Not now';

  @override
  String get notificationsTurnOn => 'Turn on';

  @override
  String get notificationReadyTitle => 'A message is ready';

  @override
  String get notificationReadyBody => 'Tap to open it.';

  @override
  String get notificationChannelName => 'Ready messages';
}

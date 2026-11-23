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
  String get errorSignedOut => 'You are signed out. Sign in and try again.';

  @override
  String get errorInvalidCredentials => 'Wrong email or password.';

  @override
  String get errorEmailNotConfirmed =>
      'Confirm your email address before signing in.';

  @override
  String get errorWeakPassword => 'Choose a stronger password.';

  @override
  String get errorSamePassword =>
      'Choose a password different from your current one.';

  @override
  String get errorRateLimited =>
      'Too many attempts. Wait a moment and try again.';

  @override
  String get errorLinkExpired => 'This link has expired. Request a new one.';

  @override
  String get errorAuthFailed =>
      'That didn\'t work. Check your details and try again.';

  @override
  String get errorAccountExists => 'An account already exists.';

  @override
  String get validationEmailEmpty => 'Enter your email address.';

  @override
  String get validationEmailInvalid => 'Enter a valid email address.';

  @override
  String get validationPasswordEmpty => 'Enter a password.';

  @override
  String validationPasswordTooShort(int min) {
    return 'Password must be at least $min characters.';
  }

  @override
  String get validationConfirmationEmpty => 'Confirm your password.';

  @override
  String get validationPasswordsDiffer => 'Passwords do not match.';

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
  String validationBodyInvalid(int max) {
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);

    return 'A message needs some text, up to $maxString characters.';
  }

  @override
  String get validationDeliveryMissing => 'Pick a delivery date and time.';

  @override
  String get validationDeliveryInPast => 'Pick a time in the future.';

  @override
  String get validationDeliveryPassed =>
      'That delivery time has already passed. Pick a later time.';

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
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get authSignInTitle => 'Sign in';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authForgotPasswordLink => 'Forgot password?';

  @override
  String get authSignUpLink => 'Don\'t have an account? Sign up';

  @override
  String get authCreateAccountTitle => 'Create account';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authConfirmPassword => 'Confirm password';

  @override
  String get authConfirmEmailSent =>
      'Check your email to confirm your account before signing in.';

  @override
  String get authBackToSignIn => 'Back to sign in';

  @override
  String get authResetPasswordTitle => 'Reset password';

  @override
  String get authResetPasswordIntro =>
      'Enter your account\'s email and we\'ll send a link to reset your password.';

  @override
  String get authSendResetLink => 'Send reset link';

  @override
  String get authResetLinkSent =>
      'If an account exists for that email, a reset link has been sent.';

  @override
  String get authNewPasswordTitle => 'Set a new password';

  @override
  String get authNewPassword => 'New password';

  @override
  String get authConfirmNewPassword => 'Confirm new password';

  @override
  String get authUpdatePassword => 'Update password';

  @override
  String get homeAccountTooltip => 'Account';

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
  String get sealedDeleted => 'Message deleted.';

  @override
  String get sealedDeleteTitle => 'Delete this sealed message?';

  @override
  String get sealedDeleteContent =>
      'It will never open. This can\'t be undone.';

  @override
  String get messageTitle => 'Message';

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
  String messageArrived(String delivery) {
    return 'Arrived $delivery';
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
  String get composeBodyLabel => 'Your message';

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
  String get accountTitle => 'Account';

  @override
  String get accountSignedInAs => 'Signed in as';

  @override
  String get accountUnknownEmail => 'Unknown';

  @override
  String get accountPrivacy => 'Privacy & data';

  @override
  String get accountRequestDeletion => 'Request account deletion';

  @override
  String get accountSignOut => 'Sign out';

  @override
  String accountMailAppMissing(String email) {
    return 'Could not open a mail app. Email $email directly to request deletion.';
  }

  @override
  String get privacyTitle => 'Privacy & data';

  @override
  String get privacyDraftsTitle => 'Drafts stay on this device';

  @override
  String get privacyDraftsBody =>
      'While you write, your draft is saved encrypted on this device only. It is never sent to our servers, and it is deleted when you seal it, discard it, or sign out.';

  @override
  String get privacySealedTitle => 'Sealed messages';

  @override
  String get privacySealedBody =>
      'When you seal a message we store it with its opening time, time zone and status. Access is enforced by the database itself, not just the app: only your account can see your messages, and nobody, not even you, can read one before it opens.';

  @override
  String get privacyNotificationsTitle => 'Notifications';

  @override
  String get privacyNotificationsBody =>
      'A notification only says \"A message is ready\". It never contains what you wrote, so nothing private shows on your lock screen. To send it we keep a notification address for this device from Firebase Cloud Messaging, removed when you sign out.';

  @override
  String get privacyTrackingTitle => 'No tracking';

  @override
  String get privacyTrackingBody =>
      'Laternote has no analytics, ads or crash reporting. Our logs record counts only, never message content.';

  @override
  String get privacyDeletionTitle => 'Deleting your account';

  @override
  String get privacyDeletionBody =>
      'During this early MVP, account deletion is handled manually: use \"Request account deletion\" on the Account screen to send a request. We delete your account, messages and device addresses by hand, normally within a few business days, and confirm by email.';

  @override
  String get privacyBackupsTitle => 'Backups';

  @override
  String get privacyBackupsBody =>
      'Encrypted backups age out after about 30 days. If one is ever restored, deletion requests made since then are applied again.';

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
  String get linkContinue => 'Continue';

  @override
  String get linkEmailConfirmedTitle => 'Email confirmed';

  @override
  String get linkEmailConfirmedBody =>
      'Your email is confirmed and you\'re signed in.';

  @override
  String get linkProblemTitle => 'Link not usable';

  @override
  String get linkProblemExpired =>
      'This link has expired or was already used. Request a new one.';

  @override
  String get linkProblemInvalid =>
      'This link can\'t be used. Open it on the device where you requested it, or request a new one.';

  @override
  String get linkProblemUnrecognized =>
      'Laternote doesn\'t recognize this link.';

  @override
  String get linkProblemNetwork =>
      'No connection. Check your network and open the link again.';
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorUnexpected;

  /// No description provided for @errorSignedOut.
  ///
  /// In en, this message translates to:
  /// **'You are signed out. Sign in and try again.'**
  String get errorSignedOut;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailNotConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirm your email address before signing in.'**
  String get errorEmailNotConfirmed;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get errorWeakPassword;

  /// No description provided for @errorSamePassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a password different from your current one.'**
  String get errorSamePassword;

  /// No description provided for @errorRateLimited.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Wait a moment and try again.'**
  String get errorRateLimited;

  /// No description provided for @errorLinkExpired.
  ///
  /// In en, this message translates to:
  /// **'This link has expired. Request a new one.'**
  String get errorLinkExpired;

  /// No description provided for @errorAuthFailed.
  ///
  /// In en, this message translates to:
  /// **'That didn\'t work. Check your details and try again.'**
  String get errorAuthFailed;

  /// No description provided for @errorAccountExists.
  ///
  /// In en, this message translates to:
  /// **'An account already exists.'**
  String get errorAccountExists;

  /// No description provided for @validationEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get validationEmailEmpty;

  /// No description provided for @validationEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get validationEmailInvalid;

  /// No description provided for @validationPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get validationPasswordEmpty;

  /// No description provided for @validationPasswordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least {min} characters.'**
  String validationPasswordTooShort(int min);

  /// No description provided for @validationConfirmationEmpty.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password.'**
  String get validationConfirmationEmpty;

  /// No description provided for @validationPasswordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get validationPasswordsDiffer;

  /// No description provided for @validationBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Write something to your future self.'**
  String get validationBodyEmpty;

  /// No description provided for @validationBodyTooLong.
  ///
  /// In en, this message translates to:
  /// **'Keep it under {max} characters.'**
  String validationBodyTooLong(int max);

  /// No description provided for @validationDeliveryMissing.
  ///
  /// In en, this message translates to:
  /// **'Pick a delivery date and time.'**
  String get validationDeliveryMissing;

  /// No description provided for @validationDeliveryInPast.
  ///
  /// In en, this message translates to:
  /// **'Pick a time in the future.'**
  String get validationDeliveryInPast;

  /// No description provided for @validationAlreadyOpening.
  ///
  /// In en, this message translates to:
  /// **'This message is already opening, so it can\'t be deleted.'**
  String get validationAlreadyOpening;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get commonEmail;

  /// No description provided for @commonPassword.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get commonPassword;

  /// No description provided for @authSignInTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInTitle;

  /// No description provided for @authTagline.
  ///
  /// In en, this message translates to:
  /// **'A message to the person you\'ll become.'**
  String get authTagline;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// No description provided for @authForgotPasswordLink.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get authForgotPasswordLink;

  /// No description provided for @authSignUpLink.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get authSignUpLink;

  /// No description provided for @authCreateAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountTitle;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get authConfirmPassword;

  /// No description provided for @authConfirmEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Check your email to confirm your account before signing in.'**
  String get authConfirmEmailSent;

  /// No description provided for @authBackToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to sign in'**
  String get authBackToSignIn;

  /// No description provided for @authResetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get authResetPasswordTitle;

  /// No description provided for @authResetPasswordIntro.
  ///
  /// In en, this message translates to:
  /// **'Enter your account\'s email and we\'ll send a link to reset your password.'**
  String get authResetPasswordIntro;

  /// No description provided for @authSendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get authSendResetLink;

  /// No description provided for @authResetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists for that email, a reset link has been sent.'**
  String get authResetLinkSent;

  /// No description provided for @authNewPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get authNewPasswordTitle;

  /// No description provided for @authNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get authNewPassword;

  /// No description provided for @authConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get authConfirmNewPassword;

  /// No description provided for @authUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get authUpdatePassword;

  /// No description provided for @homeAccountTooltip.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get homeAccountTooltip;

  /// No description provided for @homeInboxTab.
  ///
  /// In en, this message translates to:
  /// **'Inbox'**
  String get homeInboxTab;

  /// No description provided for @homeSealedTab.
  ///
  /// In en, this message translates to:
  /// **'Sealed'**
  String get homeSealedTab;

  /// No description provided for @homeNewMessage.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get homeNewMessage;

  /// No description provided for @inboxLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your inbox…'**
  String get inboxLoading;

  /// No description provided for @inboxEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing has opened yet. Your messages arrive here when their time comes.'**
  String get inboxEmpty;

  /// No description provided for @inboxNewHeader.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get inboxNewHeader;

  /// No description provided for @inboxReadHeader.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get inboxReadHeader;

  /// No description provided for @inboxArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived {date}'**
  String inboxArrived(String date);

  /// No description provided for @inboxWrittenOn.
  ///
  /// In en, this message translates to:
  /// **'Written on {date}'**
  String inboxWrittenOn(String date);

  /// No description provided for @sealedLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading your sealed messages… You can start a new one meanwhile.'**
  String get sealedLoading;

  /// No description provided for @sealedEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing sealed yet. Tap New message to write to your future self.'**
  String get sealedEmpty;

  /// No description provided for @sealedOpeningSoon.
  ///
  /// In en, this message translates to:
  /// **'Opening soon'**
  String get sealedOpeningSoon;

  /// No description provided for @sealedOpens.
  ///
  /// In en, this message translates to:
  /// **'Opens {delivery}'**
  String sealedOpens(String delivery);

  /// No description provided for @sealedOn.
  ///
  /// In en, this message translates to:
  /// **'Sealed on {date}'**
  String sealedOn(String date);

  /// No description provided for @sealedCountdown.
  ///
  /// In en, this message translates to:
  /// **'in {duration}'**
  String sealedCountdown(String duration);

  /// No description provided for @countdownYears.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 year} other{{count} years}}'**
  String countdownYears(int count);

  /// No description provided for @countdownMonths.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 month} other{{count} months}}'**
  String countdownMonths(int count);

  /// No description provided for @countdownDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String countdownDays(int count);

  /// No description provided for @countdownHours.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String countdownHours(int count);

  /// No description provided for @countdownMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String countdownMinutes(int count);

  /// No description provided for @countdownUnderMinute.
  ///
  /// In en, this message translates to:
  /// **'less than a minute'**
  String get countdownUnderMinute;

  /// No description provided for @sealedDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted.'**
  String get sealedDeleted;

  /// No description provided for @sealedDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete this sealed message?'**
  String get sealedDeleteTitle;

  /// No description provided for @sealedDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'It will never open. This can\'t be undone.'**
  String get sealedDeleteContent;

  /// No description provided for @messageTitle.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageTitle;

  /// No description provided for @messageOpeningEnvelope.
  ///
  /// In en, this message translates to:
  /// **'Opening the envelope. Tap to skip.'**
  String get messageOpeningEnvelope;

  /// No description provided for @messageUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This message isn\'t available. It may not have opened yet, or it was deleted.'**
  String get messageUnavailable;

  /// No description provided for @messageOpening.
  ///
  /// In en, this message translates to:
  /// **'Opening your message…'**
  String get messageOpening;

  /// No description provided for @messageWrittenOn.
  ///
  /// In en, this message translates to:
  /// **'Written on {date}'**
  String messageWrittenOn(String date);

  /// No description provided for @messageSetToOpen.
  ///
  /// In en, this message translates to:
  /// **'Set to open {delivery}'**
  String messageSetToOpen(String delivery);

  /// Full date and time a message opens, e.g. 'Saturday, December 20, 2027 at 9:00 AM'.
  ///
  /// In en, this message translates to:
  /// **'{date} at {time}'**
  String deliveryDateTime(String date, String time);

  /// No description provided for @composeTitle.
  ///
  /// In en, this message translates to:
  /// **'New message'**
  String get composeTitle;

  /// No description provided for @composeDiscardTooltip.
  ///
  /// In en, this message translates to:
  /// **'Discard draft'**
  String get composeDiscardTooltip;

  /// No description provided for @composeDiscardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard draft?'**
  String get composeDiscardTitle;

  /// No description provided for @composeDiscardContent.
  ///
  /// In en, this message translates to:
  /// **'It will be deleted from this device.'**
  String get composeDiscardContent;

  /// No description provided for @composeKeep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get composeKeep;

  /// No description provided for @composeDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get composeDiscard;

  /// No description provided for @composeBodyHint.
  ///
  /// In en, this message translates to:
  /// **'Dear future me,'**
  String get composeBodyHint;

  /// No description provided for @composeDeliverOn.
  ///
  /// In en, this message translates to:
  /// **'Deliver on'**
  String get composeDeliverOn;

  /// No description provided for @composePickDateTime.
  ///
  /// In en, this message translates to:
  /// **'Pick a date and time'**
  String get composePickDateTime;

  /// No description provided for @composeSeal.
  ///
  /// In en, this message translates to:
  /// **'Seal…'**
  String get composeSeal;

  /// No description provided for @composeSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Not saved on this device. Keep the app open or try again.'**
  String get composeSaveFailed;

  /// No description provided for @composeSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Your draft is saved on this device only. Nothing is sent until you seal it.'**
  String get composeSavedLocally;

  /// No description provided for @reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get reviewTitle;

  /// No description provided for @reviewSealing.
  ///
  /// In en, this message translates to:
  /// **'Sealing your message'**
  String get reviewSealing;

  /// No description provided for @reviewNoDeliveryTime.
  ///
  /// In en, this message translates to:
  /// **'No delivery time'**
  String get reviewNoDeliveryTime;

  /// No description provided for @reviewSealedHint.
  ///
  /// In en, this message translates to:
  /// **'Once sealed, you can\'t read it until then.'**
  String get reviewSealedHint;

  /// No description provided for @reviewSealButton.
  ///
  /// In en, this message translates to:
  /// **'Seal message'**
  String get reviewSealButton;

  /// No description provided for @reviewEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get reviewEdit;

  /// No description provided for @reviewSealedUntil.
  ///
  /// In en, this message translates to:
  /// **'Sealed until {delivery}.'**
  String reviewSealedUntil(String delivery);

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSignedInAs.
  ///
  /// In en, this message translates to:
  /// **'Signed in as'**
  String get accountSignedInAs;

  /// No description provided for @accountUnknownEmail.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get accountUnknownEmail;

  /// No description provided for @accountPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get accountPrivacy;

  /// No description provided for @accountRequestDeletion.
  ///
  /// In en, this message translates to:
  /// **'Request account deletion'**
  String get accountRequestDeletion;

  /// No description provided for @accountSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get accountSignOut;

  /// No description provided for @accountMailAppMissing.
  ///
  /// In en, this message translates to:
  /// **'Could not open a mail app. Email {email} directly to request deletion.'**
  String accountMailAppMissing(String email);

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & data'**
  String get privacyTitle;

  /// No description provided for @privacyDraftsTitle.
  ///
  /// In en, this message translates to:
  /// **'Drafts stay on this device'**
  String get privacyDraftsTitle;

  /// No description provided for @privacyDraftsBody.
  ///
  /// In en, this message translates to:
  /// **'While you write, your draft is saved encrypted on this device only. It is never sent to our servers, and it is deleted when you seal it, discard it, or sign out.'**
  String get privacyDraftsBody;

  /// No description provided for @privacySealedTitle.
  ///
  /// In en, this message translates to:
  /// **'Sealed messages'**
  String get privacySealedTitle;

  /// No description provided for @privacySealedBody.
  ///
  /// In en, this message translates to:
  /// **'When you seal a message we store it with its opening time, time zone and status. Access is enforced by the database itself, not just the app: only your account can see your messages, and nobody, not even you, can read one before it opens.'**
  String get privacySealedBody;

  /// No description provided for @privacyNotificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get privacyNotificationsTitle;

  /// No description provided for @privacyNotificationsBody.
  ///
  /// In en, this message translates to:
  /// **'A notification only says \"A message is ready\". It never contains what you wrote, so nothing private shows on your lock screen. To send it we keep a notification address for this device from Firebase Cloud Messaging, removed when you sign out.'**
  String get privacyNotificationsBody;

  /// No description provided for @privacyTrackingTitle.
  ///
  /// In en, this message translates to:
  /// **'No tracking'**
  String get privacyTrackingTitle;

  /// No description provided for @privacyTrackingBody.
  ///
  /// In en, this message translates to:
  /// **'Laternote has no analytics, ads or crash reporting. Our logs record counts only, never message content.'**
  String get privacyTrackingBody;

  /// No description provided for @privacyDeletionTitle.
  ///
  /// In en, this message translates to:
  /// **'Deleting your account'**
  String get privacyDeletionTitle;

  /// No description provided for @privacyDeletionBody.
  ///
  /// In en, this message translates to:
  /// **'During this early MVP, account deletion is handled manually: use \"Request account deletion\" on the Account screen to send a request. We delete your account, messages and device addresses by hand, normally within a few business days, and confirm by email.'**
  String get privacyDeletionBody;

  /// No description provided for @privacyBackupsTitle.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get privacyBackupsTitle;

  /// No description provided for @privacyBackupsBody.
  ///
  /// In en, this message translates to:
  /// **'Encrypted backups age out after about 30 days. If one is ever restored, deletion requests made since then are applied again.'**
  String get privacyBackupsBody;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsOn.
  ///
  /// In en, this message translates to:
  /// **'On. You\'ll hear when a message opens.'**
  String get notificationsOn;

  /// No description provided for @notificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Off. Turn them on in your device settings.'**
  String get notificationsDenied;

  /// No description provided for @notificationsUndecided.
  ///
  /// In en, this message translates to:
  /// **'Off. Tap to turn on.'**
  String get notificationsUndecided;

  /// No description provided for @notificationsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Not available on this device.'**
  String get notificationsUnavailable;

  /// No description provided for @notificationsPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Know when it opens'**
  String get notificationsPromptTitle;

  /// No description provided for @notificationsPromptContent.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a notification when a message is ready to read. It never shows what you wrote.'**
  String get notificationsPromptContent;

  /// No description provided for @notificationsNotNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notificationsNotNow;

  /// No description provided for @notificationsTurnOn.
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get notificationsTurnOn;

  /// No description provided for @linkContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get linkContinue;

  /// No description provided for @linkEmailConfirmedTitle.
  ///
  /// In en, this message translates to:
  /// **'Email confirmed'**
  String get linkEmailConfirmedTitle;

  /// No description provided for @linkEmailConfirmedBody.
  ///
  /// In en, this message translates to:
  /// **'Your email is confirmed and you\'re signed in.'**
  String get linkEmailConfirmedBody;

  /// No description provided for @linkProblemTitle.
  ///
  /// In en, this message translates to:
  /// **'Link not usable'**
  String get linkProblemTitle;

  /// No description provided for @linkProblemExpired.
  ///
  /// In en, this message translates to:
  /// **'This link has expired or was already used. Request a new one.'**
  String get linkProblemExpired;

  /// No description provided for @linkProblemInvalid.
  ///
  /// In en, this message translates to:
  /// **'This link can\'t be used. Open it on the device where you requested it, or request a new one.'**
  String get linkProblemInvalid;

  /// No description provided for @linkProblemUnrecognized.
  ///
  /// In en, this message translates to:
  /// **'Laternote doesn\'t recognize this link.'**
  String get linkProblemUnrecognized;

  /// No description provided for @linkProblemNetwork.
  ///
  /// In en, this message translates to:
  /// **'No connection. Check your network and open the link again.'**
  String get linkProblemNetwork;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

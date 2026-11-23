// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get errorNetwork =>
      'Nessuna connessione. Controlla la rete e riprova.';

  @override
  String get errorUnexpected => 'Qualcosa è andato storto. Riprova.';

  @override
  String get errorSignedOut =>
      'Non hai effettuato l\'accesso. Accedi e riprova.';

  @override
  String get errorInvalidCredentials => 'Email o password errate.';

  @override
  String get errorEmailNotConfirmed =>
      'Conferma il tuo indirizzo email prima di accedere.';

  @override
  String get errorWeakPassword => 'Scegli una password più sicura.';

  @override
  String get errorSamePassword =>
      'Scegli una password diversa da quella attuale.';

  @override
  String get errorRateLimited =>
      'Troppi tentativi. Attendi un momento e riprova.';

  @override
  String get errorLinkExpired => 'Questo link è scaduto. Richiedine uno nuovo.';

  @override
  String get errorAuthFailed =>
      'Non ha funzionato. Controlla i dati e riprova.';

  @override
  String get errorAccountExists => 'Esiste già un account.';

  @override
  String get validationEmailEmpty => 'Inserisci il tuo indirizzo email.';

  @override
  String get validationEmailInvalid => 'Inserisci un indirizzo email valido.';

  @override
  String get validationPasswordEmpty => 'Inserisci una password.';

  @override
  String validationPasswordTooShort(int min) {
    return 'La password deve avere almeno $min caratteri.';
  }

  @override
  String get validationConfirmationEmpty => 'Conferma la password.';

  @override
  String get validationPasswordsDiffer => 'Le password non coincidono.';

  @override
  String get validationBodyEmpty => 'Scrivi qualcosa al te del futuro.';

  @override
  String validationBodyTooLong(int max) {
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);

    return 'Resta sotto i $maxString caratteri.';
  }

  @override
  String validationBodyInvalid(int max) {
    final intl.NumberFormat maxNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String maxString = maxNumberFormat.format(max);

    return 'Un messaggio deve contenere del testo, fino a $maxString caratteri.';
  }

  @override
  String get validationDeliveryMissing =>
      'Scegli una data e un\'ora di consegna.';

  @override
  String get validationDeliveryInPast => 'Scegli un orario nel futuro.';

  @override
  String get validationDeliveryPassed =>
      'Quell\'orario di consegna è già passato. Scegline uno più avanti.';

  @override
  String get validationAlreadyOpening =>
      'Questo messaggio si sta già aprendo, quindi non può essere eliminato.';

  @override
  String get commonRetry => 'Riprova';

  @override
  String get commonCancel => 'Annulla';

  @override
  String get commonDelete => 'Elimina';

  @override
  String get commonEmail => 'Email';

  @override
  String get commonPassword => 'Password';

  @override
  String get authSignInTitle => 'Accedi';

  @override
  String get authSignInButton => 'Accedi';

  @override
  String get authForgotPasswordLink => 'Password dimenticata?';

  @override
  String get authSignUpLink => 'Non hai un account? Registrati';

  @override
  String get authCreateAccountTitle => 'Crea account';

  @override
  String get authCreateAccountButton => 'Crea account';

  @override
  String get authConfirmPassword => 'Conferma password';

  @override
  String get authConfirmEmailSent =>
      'Controlla la tua email per confermare l\'account prima di accedere.';

  @override
  String get authBackToSignIn => 'Torna all\'accesso';

  @override
  String get authResetPasswordTitle => 'Reimposta password';

  @override
  String get authResetPasswordIntro =>
      'Inserisci l\'email del tuo account e ti invieremo un link per reimpostare la password.';

  @override
  String get authSendResetLink => 'Invia link';

  @override
  String get authResetLinkSent =>
      'Se esiste un account con questa email, ti abbiamo inviato un link per reimpostare la password.';

  @override
  String get authNewPasswordTitle => 'Imposta una nuova password';

  @override
  String get authNewPassword => 'Nuova password';

  @override
  String get authConfirmNewPassword => 'Conferma nuova password';

  @override
  String get authUpdatePassword => 'Aggiorna password';

  @override
  String get homeAccountTooltip => 'Account';

  @override
  String get homeInboxTab => 'In arrivo';

  @override
  String get homeSealedTab => 'Sigillati';

  @override
  String get homeNewMessage => 'Nuovo messaggio';

  @override
  String get inboxLoading => 'Caricamento dei messaggi in arrivo…';

  @override
  String get inboxEmpty =>
      'Non si è ancora aperto nulla. I tuoi messaggi arrivano qui quando è il loro momento.';

  @override
  String get inboxNewHeader => 'Nuovi';

  @override
  String get inboxReadHeader => 'Letti';

  @override
  String inboxArrived(String date) {
    return 'Arrivato il $date';
  }

  @override
  String inboxWrittenOn(String date) {
    return 'Scritto il $date';
  }

  @override
  String get sealedLoading =>
      'Caricamento dei messaggi sigillati… Intanto puoi iniziarne uno nuovo.';

  @override
  String get sealedEmpty =>
      'Ancora nessun messaggio sigillato. Tocca Nuovo messaggio per scrivere al te del futuro.';

  @override
  String get sealedOpeningSoon => 'Si apre a breve';

  @override
  String sealedOpens(String delivery) {
    return 'Si apre $delivery';
  }

  @override
  String sealedOn(String date) {
    return 'Sigillato il $date';
  }

  @override
  String get sealedDeleted => 'Messaggio eliminato.';

  @override
  String get sealedDeleteTitle => 'Eliminare questo messaggio sigillato?';

  @override
  String get sealedDeleteContent =>
      'Non si aprirà mai. L\'operazione non può essere annullata.';

  @override
  String get messageTitle => 'Messaggio';

  @override
  String get messageUnavailable =>
      'Questo messaggio non è disponibile. Forse non si è ancora aperto, oppure è stato eliminato.';

  @override
  String get messageOpening => 'Apertura del messaggio…';

  @override
  String messageWrittenOn(String date) {
    return 'Scritto il $date';
  }

  @override
  String messageSetToOpen(String delivery) {
    return 'Da aprire $delivery';
  }

  @override
  String messageArrived(String delivery) {
    return 'Arrivato $delivery';
  }

  @override
  String deliveryDateTime(String date, String time) {
    return '$date alle $time';
  }

  @override
  String get composeTitle => 'Nuovo messaggio';

  @override
  String get composeDiscardTooltip => 'Elimina bozza';

  @override
  String get composeDiscardTitle => 'Eliminare la bozza?';

  @override
  String get composeDiscardContent => 'Verrà cancellata da questo dispositivo.';

  @override
  String get composeKeep => 'Tieni';

  @override
  String get composeDiscard => 'Elimina';

  @override
  String get composeBodyLabel => 'Il tuo messaggio';

  @override
  String get composeDeliverOn => 'Consegna il';

  @override
  String get composePickDateTime => 'Scegli data e ora';

  @override
  String get composeSeal => 'Sigilla…';

  @override
  String get composeSaveFailed =>
      'Non salvata su questo dispositivo. Tieni aperta l\'app o riprova.';

  @override
  String get composeSavedLocally =>
      'La bozza è salvata solo su questo dispositivo. Non viene inviato nulla finché non la sigilli.';

  @override
  String get reviewTitle => 'Rivedi';

  @override
  String get reviewNoDeliveryTime => 'Nessun orario di consegna';

  @override
  String get reviewSealedHint =>
      'Una volta sigillato, non potrai leggerlo fino ad allora.';

  @override
  String get reviewSealButton => 'Sigilla messaggio';

  @override
  String get reviewEdit => 'Modifica';

  @override
  String reviewSealedUntil(String delivery) {
    return 'Sigillato fino a $delivery.';
  }

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSignedInAs => 'Accesso effettuato come';

  @override
  String get accountUnknownEmail => 'Sconosciuto';

  @override
  String get accountPrivacy => 'Privacy e dati';

  @override
  String get accountRequestDeletion => 'Richiedi l\'eliminazione dell\'account';

  @override
  String get accountSignOut => 'Esci';

  @override
  String accountMailAppMissing(String email) {
    return 'Impossibile aprire un\'app di posta. Scrivi direttamente a $email per richiedere l\'eliminazione.';
  }

  @override
  String get privacyTitle => 'Privacy e dati';

  @override
  String get privacyDraftsTitle => 'Le bozze restano su questo dispositivo';

  @override
  String get privacyDraftsBody =>
      'Mentre scrivi, la bozza viene salvata cifrata solo su questo dispositivo. Non viene mai inviata ai nostri server e viene cancellata quando la sigilli, la elimini o esci.';

  @override
  String get privacySealedTitle => 'Messaggi sigillati';

  @override
  String get privacySealedBody =>
      'Quando sigilli un messaggio lo conserviamo insieme all\'orario di apertura, al fuso orario e allo stato. L\'accesso è controllato dal database stesso, non solo dall\'app: solo il tuo account può vedere i tuoi messaggi e nessuno, nemmeno tu, può leggerne uno prima che si apra.';

  @override
  String get privacyNotificationsTitle => 'Notifiche';

  @override
  String get privacyNotificationsBody =>
      'Una notifica dice solo che un messaggio è pronto. Non contiene mai ciò che hai scritto, quindi sulla schermata di blocco non compare nulla di privato. Per inviarla conserviamo un indirizzo di notifica di Firebase Cloud Messaging per questo dispositivo, che viene rimosso quando esci.';

  @override
  String get privacyTrackingTitle => 'Nessun tracciamento';

  @override
  String get privacyTrackingBody =>
      'Laternote non ha analisi, pubblicità né segnalazione degli arresti anomali. I nostri log registrano solo conteggi, mai il contenuto dei messaggi.';

  @override
  String get privacyDeletionTitle => 'Eliminare l\'account';

  @override
  String get privacyDeletionBody =>
      'In questa prima versione (MVP) l\'eliminazione dell\'account è gestita manualmente: usa \"Richiedi l\'eliminazione dell\'account\" nella schermata Account per inviare una richiesta. Eliminiamo a mano account, messaggi e indirizzi dei dispositivi, di solito entro pochi giorni lavorativi, e lo confermiamo via email.';

  @override
  String get privacyBackupsTitle => 'Backup';

  @override
  String get privacyBackupsBody =>
      'I backup cifrati scadono dopo circa 30 giorni. Se uno viene ripristinato, le richieste di eliminazione fatte da allora vengono applicate di nuovo.';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationsOn => 'Attive. Saprai quando un messaggio si apre.';

  @override
  String get notificationsDenied =>
      'Disattivate. Attivale nelle impostazioni del dispositivo.';

  @override
  String get notificationsUndecided => 'Disattivate. Tocca per attivarle.';

  @override
  String get notificationsUnavailable =>
      'Non disponibili su questo dispositivo.';

  @override
  String get notificationsPromptTitle => 'Sappi quando si apre';

  @override
  String get notificationsPromptContent =>
      'Ti invieremo una notifica quando un messaggio è pronto da leggere. Non mostra mai ciò che hai scritto.';

  @override
  String get notificationsNotNow => 'Non ora';

  @override
  String get notificationsTurnOn => 'Attiva';

  @override
  String get linkContinue => 'Continua';

  @override
  String get linkEmailConfirmedTitle => 'Email confermata';

  @override
  String get linkEmailConfirmedBody =>
      'La tua email è confermata e hai effettuato l\'accesso.';

  @override
  String get linkProblemTitle => 'Link non utilizzabile';

  @override
  String get linkProblemExpired =>
      'Questo link è scaduto o è già stato usato. Richiedine uno nuovo.';

  @override
  String get linkProblemInvalid =>
      'Questo link non può essere usato. Aprilo sul dispositivo da cui l\'hai richiesto, oppure richiedine uno nuovo.';

  @override
  String get linkProblemUnrecognized => 'Laternote non riconosce questo link.';

  @override
  String get linkProblemNetwork =>
      'Nessuna connessione. Controlla la rete e apri di nuovo il link.';
}

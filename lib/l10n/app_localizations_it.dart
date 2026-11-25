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
  String get errorInvalidFile =>
      'Questo file non è un\'esportazione di Laternote o è danneggiato. Non è stato importato nulla.';

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
  String get validationDeliveryMissing =>
      'Scegli una data e un\'ora di consegna.';

  @override
  String get validationDeliveryInPast => 'Scegli un orario nel futuro.';

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
  String get homeSettingsTooltip => 'Impostazioni';

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
  String sealedCountdown(String duration) {
    return 'tra $duration';
  }

  @override
  String countdownYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count anni',
      one: '1 anno',
    );
    return '$_temp0';
  }

  @override
  String countdownMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mesi',
      one: '1 mese',
    );
    return '$_temp0';
  }

  @override
  String countdownDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni',
      one: '1 giorno',
    );
    return '$_temp0';
  }

  @override
  String countdownHours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ore',
      one: '1 ora',
    );
    return '$_temp0';
  }

  @override
  String countdownMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minuti',
      one: '1 minuto',
    );
    return '$_temp0';
  }

  @override
  String get countdownUnderMinute => 'meno di un minuto';

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
  String get messageOpeningEnvelope =>
      'Apertura della busta. Tocca per saltare.';

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
  String get composeBodyHint => 'Ciao, futuro me,';

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
  String get reviewSealing => 'Sigillatura del messaggio';

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
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsPrivacy => 'Privacy e dati';

  @override
  String get settingsExport => 'Esporta lettere';

  @override
  String get settingsExportSubtitle =>
      'Salva una copia di tutte le lettere in un file';

  @override
  String get settingsImport => 'Importa lettere';

  @override
  String get settingsImportSubtitle => 'Aggiungi lettere da un file esportato';

  @override
  String get exportWarningTitle => 'Esportare le lettere?';

  @override
  String get exportWarningBody =>
      'Il file non è cifrato. Contiene il testo di tutte le lettere, anche di quelle sigillate, e chiunque abbia il file può leggerle.';

  @override
  String get exportWarningConfirm => 'Esporta';

  @override
  String importAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lettere aggiunte',
      one: '1 lettera aggiunta',
      zero: 'Nessuna lettera nuova in questo file',
    );
    return '$_temp0';
  }

  @override
  String get privacyTitle => 'Privacy e dati';

  @override
  String get privacyDraftsTitle => 'Le bozze restano su questo dispositivo';

  @override
  String get privacyDraftsBody =>
      'Mentre scrivi, la bozza viene salvata cifrata solo su questo dispositivo. Viene cancellata quando la sigilli o la elimini e non viene mai inclusa nei backup.';

  @override
  String get privacySealedTitle =>
      'I messaggi sigillati restano su questo dispositivo';

  @override
  String get privacySealedBody =>
      'Laternote non ha account né server. I messaggi sigillati sono conservati su questo dispositivo insieme all\'orario di apertura e al fuso orario, e non lo lasciano mai, se non nei backup del dispositivo o nelle esportazioni che fai tu.';

  @override
  String get privacyNotificationsTitle => 'Notifiche';

  @override
  String get privacyNotificationsBody =>
      'Una notifica dice solo che un messaggio è pronto. Non contiene mai ciò che hai scritto, quindi sulla schermata di blocco non compare nulla di privato. È il telefono stesso a programmarla quando sigilli un messaggio, quindi non viene inviato nulla.';

  @override
  String get privacyTrackingTitle => 'Nessun tracciamento';

  @override
  String get privacyTrackingBody =>
      'Laternote non ha analisi, pubblicità né segnalazione degli arresti anomali.';

  @override
  String get privacyDeletionTitle => 'Eliminare i messaggi';

  @override
  String get privacyDeletionBody =>
      'Disinstallare Laternote cancella i messaggi e la bozza da questo dispositivo. Le copie nei backup del dispositivo o nei file che hai esportato restano finché non le elimini.';

  @override
  String get privacyBackupsTitle => 'Backup';

  @override
  String get privacyBackupsBody =>
      'I messaggi sigillati sono inclusi nel backup del dispositivo, quindi ripristinarlo li riporta indietro. Il sigillo segue l\'orologio di questo dispositivo: chi cambia l\'orologio o legge i file dell\'app può aprire un messaggio in anticipo.';

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
  String get notificationReadyTitle => 'Un messaggio è pronto';

  @override
  String get notificationReadyBody => 'Tocca per aprirlo.';

  @override
  String get notificationChannelName => 'Messaggi pronti';
}

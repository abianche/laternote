# Store listing

Same text for both stores unless noted.

| Field | Value |
|-------|-------|
| Privacy policy URL | https://althenos.com/laternote/privacy/ |
| Support URL (Apple) | https://althenos.com/laternote/ |

## English

**Name** (max 30): Laternote

**Subtitle**, Apple (max 30): Letters to your future self

**Short description**, Play (max 80): Write to your future self. Seal the letter and open it on the date you choose.

**Promotional text**, Apple (max 170): Write today, open it later. Seal a letter to your future self and pick the day it opens. No account, and your words stay on your device.

**Keywords**, Apple (max 100 bytes): letter,future,self,time capsule,journal,diary,memory,reflection,private,offline

**Description** (max 4000):

```
Write now. Meet yourself later.

Laternote is a personal time capsule. Write a message to your future self, choose when it opens, and seal it. Until then it stays closed.

• Write a thought, a memory, a hope or a piece of advice
• Choose the date and time it opens, next week or years from now
• Seal it: once sealed, it can't be edited or read until it opens
• Get a notification when a message is ready, if you allow it
• Keep your opened messages to read again

PRIVATE BY DESIGN
No account, no ads, no analytics. Laternote has no servers and the app makes no network requests. Your messages are stored on your device and are included in your device's backups.

YOURS TO KEEP
Export your messages to a file and import them on another device. The exported file is not encrypted, so keep it somewhere safe.

GOOD TO KNOW
The seal follows your device's clock, so it keeps a promise to yourself rather than locking a safe. If you uninstall the app without a backup or an export, your messages are lost.

Available in English and Italian.
```

## Italiano

**Nome** (max 30): Laternote

**Sottotitolo**, Apple (max 30): Lettere al te del futuro

**Descrizione breve**, Play (max 80): Scrivi al te del futuro. Sigilla la lettera e aprila nel giorno che scegli.

**Testo promozionale**, Apple (max 170): Scrivi oggi, apri più avanti. Sigilla una lettera al te del futuro e scegli quando si aprirà. Senza account, le tue parole restano sul tuo dispositivo.

**Parole chiave**, Apple (max 100 byte): lettera,futuro,capsula del tempo,diario,ricordi,memoria,riflessione,privato,offline

**Descrizione** (max 4000):

```
Scrivi ora. Ritrovati più tardi.

Laternote è una capsula del tempo personale. Scrivi un messaggio al te del futuro, scegli quando si aprirà e sigillalo. Fino ad allora resta chiuso.

• Scrivi un pensiero, un ricordo, un desiderio o un consiglio
• Scegli data e ora di apertura, tra una settimana o tra anni
• Sigillalo: da quel momento non si può modificare né leggere fino all'apertura
• Ricevi una notifica quando un messaggio è pronto, se la consenti
• Conserva i messaggi aperti per rileggerli

PRIVATA PER SCELTA
Niente account, niente pubblicità, niente analisi. Laternote non ha server e l'app non effettua richieste di rete. I messaggi sono conservati sul tuo dispositivo e sono inclusi nei suoi backup.

RESTA TUA
Esporta i tuoi messaggi in un file e importali su un altro dispositivo. Il file esportato non è cifrato: conservalo in un posto sicuro.

DA SAPERE
Il sigillo segue l'orologio del dispositivo: custodisce una promessa fatta a te, non è una cassaforte. Se disinstalli l'app senza un backup o un'esportazione, i messaggi vanno persi.

Disponibile in italiano e inglese.
```

## Feature graphic

`feature-graphic.png`: Google Play, both languages (it has no tagline); the README shows it too. 1024×500, RGB PNG without alpha, painted by `tool/branding/`. Regenerate it with:

```sh
flutter test tool/branding/render_test.dart
```

## Screenshots

In `screenshots/<store>/<language>/<size>/`, RGB PNG without alpha, taken with sample letters.

| Folder | Size in pixels | Store slot |
|--------|----------------|------------|
| `ios/*/iphone-6.3` | 1206×2622 | iPhone (required) |
| `ios/*/iphone-6.9` | 1320×2868 | iPhone, larger display |
| `ios/*/ipad-13` | 2064×2752 | iPad 13-inch (required) |
| `android/*/phone` | 1080×1920 | Phone |
| `android/*/tablet-7` | 1440×2560 | 7-inch tablet |
| `android/*/tablet-10` | 1800×3200 | 10-inch tablet |

Retake them when these screens change, and check the sizes against [Apple's](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) and [Google's](https://support.google.com/googleplay/android-developer/answer/9866151) current requirements.

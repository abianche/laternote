# Laternote architecture (MVP)

Living document. Update it in the same PR as the change it describes.

Laternote is local-only: letters live on the device, with no accounts, server or push service.

## Stack

- **Flutter** (stable channel), Dart 3
- **State management:** Riverpod 3 with code generation (`riverpod_annotation` + `riverpod_generator` + `build_runner`)
- **Navigation:** go_router
- **Storage:** `drift` (SQLite) for sealed letters, `flutter_secure_storage` for the draft
- **Notifications:** `flutter_local_notifications` with `timezone`
- **Models:** plain Dart classes, `sealed` classes for states/results, records where handy

## Folder structure (feature-first)

```
lib/
  main.dart
  app/                 # app widget, router, theme
  core/                # shared utils, errors, database provider
    ui/                # drawn widgets and their theme extension
  features/
    <feature>/
      data/            # repositories: the ONLY place that touches storage and the OS
      application/     # Riverpod providers / notifiers (business logic)
      presentation/    # screens & widgets (UI only)
test/                  # mirrors lib/
```

## App rules

- Widgets never touch the database, files or notification plugin directly. Flow: widget → provider/notifier → repository.
- Repositories are exposed through providers so tests can override them with fakes; drift tests use an in-memory database.
- Use `@riverpod` code generation, not hand-written providers.
- Async UI uses `AsyncValue` (`.when` / pattern matching); always handle loading and error.
- Errors from storage and plugins are caught in the repository and mapped to app-level errors in `core/`.
- There are no accounts: the app opens straight to home.

## Localization

- Flutter `gen-l10n` with ARB files in `lib/l10n/` (`app_en.arb` is the template, `app_it.arb` the Italian translation); the generated `AppLocalizations` is committed. Every user-facing string is an ARB key, and both files have the same keys.
- Supported locales: English and Italian. The app follows the device locale; any other locale gets English.
- `MaterialApp` uses `appLocalizationsDelegates` (`lib/app/localization.dart`): `AppLocalizations` plus `material_ui`'s Material/Cupertino/Widgets delegates, not the generated list, which points at `flutter_localizations`' Material delegate.
- Only presentation code produces text. Repositories and notifiers throw typed `AppError`s and validators return enums; widgets turn them into text (`core/error_message.dart`). Dates and times are formatted with `MaterialLocalizations`.
- Notification text is built on the device in the app's language.

## Look and feel

- "Knitted": warm, soft and homemade. A message is a letter on stitched cream fabric, in a felt envelope kept shut by a sewn-on button that comes undone when it opens. Light mode only for now.
- `appTheme` (`app/theme.dart`) sets an oat/tomato/sage/mustard `ColorScheme`, Fredoka for all UI text, and the component themes (stitched cards, pill buttons and tabs). Presentation widgets take colors and text styles from the theme, never inline values. A test keeps key text colors at WCAG AA contrast.
- Fredoka and Caveat (SIL OFL, variable fonts) are bundled in `assets/fonts/` with their licences; fonts are never fetched at runtime.
- `Knit` (`core/ui/knit.dart`) is a `ThemeExtension` for what Material has no role for: button, felt, thread and stitch colors, the handwritten letter style (Caveat), the wordmark and labels.
- `core/ui/stitches.dart` has the stitched shapes the theme uses (`StitchedBorder`, `StitchedPill`) and `Woven`, the fabric texture behind the main screens.
- `core/ui/` holds the drawn pieces (`ButtonSeal`, `Envelope`, `DatePatch`, `LetterPaper`, `Wordmark`), all `CustomPainter`, decorative to screen readers unless given a label.
- Sealing (review) and the first opening of a message are animated. Animations are skipped when the OS turns them off, a tap skips the opening, and neither changes what is saved or where the app goes.

## Storage

- Sealed letters live in one drift (SQLite) database in the app's documents directory. A letter has an ID (UUID), `body` (capped at 20,000 characters), `scheduled_for` (UTC), `timezone` (IANA zone at composition), `created_at` and `opened_at`. The app shows opening times in the device's current zone, not the stored one.
- A letter is ready when `scheduled_for <= now` on the device clock; `opened_at` (null until first read) separates the inbox's new letters from the read archive and keeps the first time.
- Sealed letters are delete-only: the repository has no update for `body` or `scheduled_for`. The schema is defined only in drift tables.
- The database is included in the OS backup: iCloud/Finder device backup on iOS, Auto Backup on Android (`allowBackup` on, with backup rules that exclude secure storage, whose Keystore key does not survive a restore). Restoring a backup brings the letters back.

### Drafts (pre-seal)

A letter starts as a draft: `DraftRepository` stores one draft per device (body, device-local delivery time) with `flutter_secure_storage` (encrypted at rest; on iOS Keychain `first_unlock_this_device`, so never in backups or moved to another device), and the compose screen autosaves every edit to it, saves pending edits when the app is backgrounded, and says so when a save fails. Sealing is an explicit action; it validates a future time, inserts the letter, schedules its notification, then deletes the draft. Once the insert succeeds the letter counts as sealed even if deleting the draft fails, so it is never sealed twice. A draft that can't be read is deleted.

## Ready notifications

- Each letter gets one local notification at `scheduled_for` (`zonedSchedule`, ID derived from the letter ID). iOS keeps only 64 pending per app, so only the 64 nearest letters are scheduled (on both platforms); the list is topped up on every start, after sealing and after deleting, which cancels that letter's notification. Starting also restores notifications that OS updates, reinstalls and restores drop.
- Android uses inexact alarms (`inexactAllowWhileIdle`), so no exact-alarm permission is asked and a small delay is fine; notifications are rescheduled after a reboot or app update.
- The notification says only that a letter is ready, in the device's language (resolved like the app's); the payload is the letter ID. Android notifications are `PRIVATE`. A tap opens the letter, or the inbox if it is gone, both when it launches the app and while it runs.
- The app asks for notification permission after the first seal, with an explanation first. The OS only reports on or off, so the app remembers that it asked to tell "not asked yet" from "denied". Without permission, ready letters still show in the inbox.
- **A seal is a promise, not a guarantee.** Release follows the device clock and the files are readable by the device owner, so someone who changes the clock or reads the database can open a letter early. That is accepted.

## Export and import

- Export writes all sealed letters (including `opened_at`) to one versioned JSON file that the user saves or shares through the OS. It is how to move letters to another device or keep a copy outside the OS backup. The file is not encrypted, and the app says so before exporting.
- Import reads such a file and adds the letters it does not have yet, matched by letter ID, then schedules their notifications. A file of an unknown version or invalid content is rejected as a whole.
- Format: UTF-8 JSON `{"format": "laternote-letters", "version": 1, "exportedAt", "letters": [...]}`, each letter with all its columns and times in ISO 8601 UTC (`features/messages/data/letters_file.dart`). The import runs in one transaction, so a failure adds nothing.
- Export and Import are in Settings. `share_plus` opens the share sheet and `file_selector` picks the file to import; `LetterFileRepository` is the only code that uses them.

## Privacy

Nothing leaves the device unless the user exports it or the OS backs it up. The app has no analytics and no network calls. "Delete everything" removes the database, the draft and all scheduled notifications.

## Environments

Android has `development` and `production` product flavors with distinct application IDs; iOS has matching schemes with distinct bundle IDs, so a development build never touches real letters. There is no runtime configuration or keys. Do not commit signing material.

## Decisions log

| Date | Decision | Why |
|------|----------|-----|
| 2026-11-15 | Riverpod 3 + codegen, go_router | Low boilerplate, testable without BuildContext, community default |
| 2026-11-18 | Unsealed drafts live only on the device (`flutter_secure_storage`), deleted on seal and discard; sealing is a separate explicit step | Lets people take their time writing while sealed letters stay final |
| 2026-11-22 | Localize with `gen-l10n` ARB files (English, Italian), following the device locale | Flutter's standard approach; typed errors keep strings out of data and application code |
| 2026-11-24 | "Knitted" look: theme plus `Knit` extension, drawn widgets in `core/ui/`, bundled Fredoka and Caveat | Letters to your future self should feel cozy, not formal; drawing in code needs no packages or image assets, and bundled fonts keep the app offline-safe |
| 2026-11-24 | Local-only: letters in a drift database included in OS backups, release by the device clock with `flutter_local_notifications`, no accounts, export/import to a file; Supabase and Firebase removed (last backend at tag `supabase-backend`) | A hobby app with no revenue can't pay for a hosted backend, and the free plan pauses and has no backups. drift gives typed queries, tested migrations and in-memory tests (over `sqflite`'s untyped SQL and unmaintained Isar/Hive); `flutter_local_notifications` is the standard for scheduled local notifications. Early opening by changing the clock is accepted |

# Laternote architecture (MVP)

Living document. Update it in the same PR as the change it describes.

## Stack

- **Flutter** (stable channel), Dart 3
- **State management:** Riverpod 3 with code generation (`riverpod_annotation` + `riverpod_generator` + `build_runner`)
- **Navigation:** go_router
- **Backend:** Supabase via `supabase_flutter` (Auth, Postgres, Storage, Edge Functions)
- **Models:** plain Dart classes, `sealed` classes for states/results, records where handy

## Folder structure (feature-first)

```
lib/
  main.dart
  app/                 # app widget, router, theme
  core/                # shared utils, errors, Supabase client provider
    ui/                # drawn widgets and their theme extension
  features/
    <feature>/
      data/            # repositories: the ONLY place that talks to Supabase
      application/     # Riverpod providers / notifiers (business logic)
      presentation/    # screens & widgets (UI only)
test/                  # mirrors lib/
supabase/
  migrations/          # SQL migrations (source of truth for the schema)
  functions/           # Edge Functions
```

## App rules

- Widgets never call Supabase directly. Flow: widget → provider/notifier → repository → Supabase.
- Repositories are exposed through providers so tests can override them with fakes.
- Use `@riverpod` code generation, not hand-written providers.
- Async UI uses `AsyncValue` (`.when` / pattern matching); always handle loading and error.
- Errors from Supabase are caught in the repository and mapped to app-level errors in `core/`.
- Generated types/constants for table names live in `core/`.

## Localization

- Flutter `gen-l10n` with ARB files in `lib/l10n/` (`app_en.arb` is the template, `app_it.arb` the Italian translation); the generated `AppLocalizations` is committed. Every user-facing string is an ARB key, and both files have the same keys.
- Supported locales: English and Italian. The app follows the device locale; any other locale gets English.
- `MaterialApp` uses `appLocalizationsDelegates` (`lib/app/localization.dart`): `AppLocalizations` plus `material_ui`'s Material/Cupertino/Widgets delegates, not the generated list, which points at `flutter_localizations`' Material delegate.
- Only presentation code produces text. Repositories and notifiers throw typed `AppError`s and validators return enums; widgets turn them into text (`core/error_message.dart`). Dates and times are formatted with `MaterialLocalizations`.
- Push text is sent by the server in English for now (#44).

## Look and feel

- "Knitted": warm, soft and homemade. A message is a letter on stitched cream fabric, in a felt envelope kept shut by a sewn-on button that comes undone when it opens. Light mode only for now.
- `appTheme` (`app/theme.dart`) sets an oat/tomato/sage/mustard `ColorScheme`, Fredoka for all UI text, and the component themes (stitched cards, pill buttons and tabs). Presentation widgets take colors and text styles from the theme, never inline values. A test keeps key text colors at WCAG AA contrast.
- Fredoka and Caveat (SIL OFL, variable fonts) are bundled in `assets/fonts/` with their licences; fonts are never fetched at runtime.
- `Knit` (`core/ui/knit.dart`) is a `ThemeExtension` for what Material has no role for: button, felt, thread and stitch colors, the handwritten letter style (Caveat), the wordmark and labels.
- `core/ui/stitches.dart` has the stitched shapes the theme uses (`StitchedBorder`, `StitchedPill`) and `Woven`, the fabric texture behind the main screens.
- `core/ui/` holds the drawn pieces (`ButtonSeal`, `Envelope`, `DatePatch`, `LetterPaper`, `Wordmark`), all `CustomPainter`, decorative to screen readers unless given a label.
- Sealing (review) and the first opening of a message are animated. Animations are skipped when the OS turns them off, a tap skips the opening, and neither changes what is saved or where the app goes.

## Deep links

- The app's URL scheme is `io.laternote`, registered in `AndroidManifest.xml` and `Info.plist`. Flutter deep linking is off, so links never reach go_router directly.
- Supabase Auth emails redirect to `io.laternote://auth/reset-password`, `auth/confirm-email` and `auth/magic-link` (`authLinkUrl` in `core/deep_link.dart`). Each URL is in the Supabase redirect allow-list (`docs/environments.md`).
- `DeepLinkRepository` (`app_links`) streams every incoming link, including the one that launched the app. `parseDeepLink` is the only code that interprets links. `deepLinkRouting` (`app/deep_link_routing.dart`) follows each one: an auth link's PKCE code is exchanged through `AuthRepository.completeSignInFromLink`, then reset opens `/reset-password`, confirmation opens `/email-confirmed` and a magic link opens home. Expired, invalid, unrecognized or offline links open `/link-problem`. Both link screens are shown in any auth state.
- `supabase_flutter`'s own link handling is off (`detectSessionInUri: false`). The PKCE code verifier lives on the device that asked for the email, so links from another device are reported as invalid.
- No screen sends magic links yet. Magic links are only routed.

## Selected services

- **Backend:** Supabase: separate development and production projects, each with Auth, Postgres, Row Level Security (RLS), and Edge Functions. Do not point a development build at production.
- **Authentication:** Supabase Auth email and password with email confirmation and password reset. The Flutter client uses the Supabase publishable key (`sb_publishable_...`) and the signed-in user's JWT. Secret keys (`sb_secret_...`) are server-only.
- **Scheduling and delivery:** Supabase Cron runs the SQL function `release_due_messages()` every 30 seconds. The database clock, not an app timer or device clock, determines release. In one transaction the function marks due messages available and enqueues a notification outbox event; only server roles can execute it. Retries are idempotent: a row is released only while still `scheduled`, and the outbox is unique on message ID plus event type. A second cron job runs `dispatch_notifications()` every 30 seconds; when outbox rows are due it calls the `send-notifications` Edge Function through `pg_net`, authenticated with a cron secret held in Vault.
- **Push:** The function claims due outbox rows (`claim_notifications`), sends a generic “A message is ready” push through FCM HTTP v1 (APNs via FCM on iOS) to each of the owner's devices, addressed by Firebase Installation ID, and reports back (`complete_notification`). The payload carries only the message ID; the app validates it and builds the route itself. Android notifications are `PRIVATE`, so the lock screen shows nothing the user wrote. A row counts as sent once any device accepts it, so retries never notify a device twice. The app asks for permission after the first seal, with an explanation first. Users can still read available messages from the inbox if push is denied or fails.

## Data model

The schema is in `supabase/migrations/`. `messages` rows belong to one `auth.users` UUID. `body` is capped at 20,000 characters. `scheduled_for` is a UTC `timestamptz`; `timezone` records the IANA zone at composition and is validated against `pg_timezone_names`. The app shows opening times in the device's current zone, not the stored one. Owners can read metadata for all of their own rows, including scheduled rows past due but not yet released (shown as "Opening soon"); `body` is not in the client column grant and is reachable only through `get_available_message`. Status is `scheduled` or `available`; `released_at` and `updated_at` are set by trusted server code; `opened_at` (null until first read, which separates the inbox's new messages from the read archive) is set only through the `mark_message_opened` RPC, which keeps the first time (messages are hard-deleted, not soft-deleted). Device tokens live in a separate owner-scoped table, written only through the `register_device_token` RPC so a token can be reassigned when a shared device changes user, and are removed on sign-out/token rotation. The notification outbox records attempts, `completed_at` and `outcome` (`sent`, `no_device`, `failed`) without storing message body; dead device addresses reported by FCM are deleted.

### Drafts (pre-seal, local only)

A message starts as a draft that exists only on the device: `DraftRepository` stores one draft per device (body, device-local delivery time, owner's user ID) with `flutter_secure_storage` (encrypted at rest; on iOS Keychain `first_unlock_this_device`, so never in backups or moved to another device), and the compose screen autosaves every edit to it, saves pending edits when the app is backgrounded, and says so when a save fails. Drafts are never sent to Supabase and have no schedule. Sealing is an explicit action; it validates the signed-in owner and a future time, inserts the `messages` row (status `scheduled`), then deletes the local draft. After that the message is sealed and follows the delete-only rules. Discarding, the session ending for any reason (sign-out, expiry, revocation), or loading a draft that belongs to another account or can't be read deletes it from the device. Once the server insert succeeds the message counts as sealed even if deleting the local draft fails, so it is never sealed twice.

## Access control

RLS is enabled on every user-data table. Policies compare `auth.uid()` to the row's `user_id`. Client inserts must set their own `user_id`. Sealed messages are delete-only: clients have no update grant or policy on `messages`, and an owner may delete a row only while it is `scheduled` and `scheduled_for > now()`; release fields are changed only by trusted server code. A client may read message content only when `status = 'available'` and `scheduled_for <= now()`. Owners can list metadata for all of their own rows through the client's restricted column grant; do not grant clients direct `SELECT` of sealed content. Secret keys bypass RLS and are confined to Edge Functions, which validate the user or process due rows. Never ship a secret key.

Never trust a user ID sent from the client. Storage buckets are private by default and covered by policies. Edge Functions invoked by users verify the caller's JWT.

The migration establishes owner policies on every table. Client table grants exclude `body`; the `get_available_message` RPC returns it only after checking owner, release state, and server time. Clients have only `select`/`delete` on `device_tokens`; writes go through the `register_device_token` RPC rather than a direct grant, since reassigning a token from a shared device's previous owner needs to bypass that owner's RLS row. `supabase/tests/access_control_test.sql` checks RLS on every table, the exact grants for `anon`/`authenticated`, and access attempts by anonymous users, another account and the owner before release. Before opening beta, also verify sealed-content isolation and cross-account isolation with two test users and the production-equivalent policies.

## Environments and credentials

Use `--dart-define-from-file=config/dev.json` or `config/prod.json` (templates contain placeholders). `APP_ENV` must match `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`; configure separate Supabase projects. Android has `development` and `production` product flavors with distinct application IDs. iOS has matching `development` and `production` schemes with distinct bundle IDs; set the corresponding Xcode signing and provisioning profiles. The app refuses to start unless `APP_ENV` matches the build flavor. Do not commit real keys or signing material.

Required hosted configuration: Supabase URL and publishable key in the app; Supabase secret key only as an Edge Function secret; FCM service account and APNs authentication key as function secrets; APNs capability and provisioning profile for each iOS app ID; Android Firebase app registrations / `google-services.json` for both application IDs. The repository cannot create provider projects or signing credentials; follow `docs/environments.md` after those accounts exist.

## Failure, retries, and retention

Each release run claims due rows with `for update skip locked`, so overlapping runs never take the same row, and releases up to 1,000 rows in one transaction; any backlog is taken by the following runs. Cron records every run and its error in `cron.job_run_details` (purged after 7 days); `message_release_backlog` (server roles only) shows the overdue count and the oldest lag. The push function retries transient failures with exponential backoff (30 s doubling, 5 attempts), using a 2-minute claim lease so a crashed run is picked up again. A unique outbox key prevents duplicate logical notifications. Permanent provider errors are recorded for operations review; notification failure never rolls back message release. Every release run takes all overdue rows, so outages are caught up automatically. Monitor the release backlog, function errors, and notification failures; alert on sustained backlog. Do not include content or tokens in routine logs.

Account deletion is an authenticated request that first disables sign-in, then deletes the Auth user; `ON DELETE CASCADE` removes messages, device tokens, and outbox rows. Define a short operational backup expiry (target 30 days) and disclose that encrypted backups age out on that schedule; restore procedures must reapply deletion requests recorded since the backup. Keep only non-identifying aggregate operational metrics. Product/legal owners must confirm the retention window and privacy policy before public launch.

## Decisions log

| Date | Decision | Why |
|------|----------|-----|
| 2026-11-15 | Riverpod 3 + codegen, go_router | Low boilerplate, testable without BuildContext, community default |
| 2026-11-15 | Supabase as backend | — |
| 2026-11-15 | Flutter deep linking off; `supabase_flutter` alone handles the auth deep link | Keeps auth callback URLs out of go_router; routing follows auth state instead |
| 2026-11-18 | Unsealed drafts live only on the device (`flutter_secure_storage`), deleted on seal, discard and session end; sealing is a separate explicit step | Lets people take their time writing while sealed messages stay final; nothing private reaches the server or outlives the session before sealing |
| 2026-11-20 | Release due messages with a SQL function run by Supabase Cron every 30 seconds, not an Edge Function | One transaction in one place, no HTTP hop or secret key, nothing metered; a missed run is caught up by the next |
| 2026-11-21 | Push through FCM HTTP v1 to the Firebase Installation ID (`fid`), from an Edge Function called by cron via `pg_net` | `token`/`getToken` are deprecated; one path for Android and iOS; the function holds the FCM credentials and the database keeps scheduling |
| 2026-11-22 | Localize with `gen-l10n` ARB files (English, Italian), following the device locale | Flutter's standard approach; typed errors keep strings out of data and application code |
| 2026-11-24 | "Knitted" look: theme plus `Knit` extension, drawn widgets in `core/ui/`, bundled Fredoka and Caveat | Letters to your future self should feel cozy, not formal; drawing in code needs no packages or image assets, and bundled fonts keep the app offline-safe |
| 2026-11-22 | The app handles incoming links itself (`app_links` + one parser), one URL path per link type; `supabase_flutter`'s link detection off | Every link type, including failed and unknown ones, gets its own screen; one place parses and routes links |

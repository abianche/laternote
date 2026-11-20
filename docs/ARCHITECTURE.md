# Laternote architecture (MVP)

Living document. Change it only through a PR linked to an issue labelled `decision`.

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

## Selected services

- **Backend:** Supabase: separate development and production projects, each with Auth, Postgres, Row Level Security (RLS), and Edge Functions. Do not point a development build at production.
- **Authentication:** Supabase Auth email and password with email confirmation and password reset. The Flutter client uses the Supabase publishable key (`sb_publishable_...`) and the signed-in user's JWT. Secret keys (`sb_secret_...`) are server-only.
- **Scheduling and delivery:** Supabase Cron runs the SQL function `release_due_messages()` every 30 seconds. The database clock, not an app timer or device clock, determines release. In one transaction the function marks due messages available and enqueues a notification outbox event; only server roles can execute it. Retries are idempotent: a row is released only while still `scheduled`, and the outbox is unique on message ID plus event type. A scheduled Edge Function (MVP-7) sends pushes from the outbox.
- **Push:** The function sends a generic “A message is ready” push through FCM/APNs using the user's current device token. Notification payloads contain only an opaque message ID and a deep-link route, never message text. Supabase secrets hold provider credentials. Users can still read available messages from the inbox if push is denied or fails.

## Data model

The schema is in `supabase/migrations/`. `messages` rows belong to one `auth.users` UUID. `body` is capped at 20,000 characters. `scheduled_for` is a UTC `timestamptz`; `timezone` records the IANA zone at composition and is validated against `pg_timezone_names`. The app shows opening times in the device's current zone, not the stored one. Owners can read metadata for all of their own rows, including scheduled rows past due but not yet released (shown as "Opening soon"); `body` is not in the client column grant and is reachable only through `get_available_message`. Status is `scheduled` or `available`; `released_at` and `updated_at` are set by trusted server code; `opened_at` (null until first read, which separates the inbox's new messages from the read archive) is set only through the `mark_message_opened` RPC, which keeps the first time (messages are hard-deleted, not soft-deleted). Device tokens live in a separate owner-scoped table, written only through the `register_device_token` RPC so a token can be reassigned when a shared device changes user, and are removed on sign-out/token rotation. The notification outbox records attempts and provider outcome without storing message body.

### Drafts (pre-seal, local only)

A message starts as a draft that exists only on the device: `DraftRepository` stores one draft per device (body, device-local delivery time, owner's user ID) with `flutter_secure_storage` (encrypted at rest; on iOS Keychain `first_unlock_this_device`, so never in backups or moved to another device), and the compose screen autosaves every edit to it, saves pending edits when the app is backgrounded, and says so when a save fails. Drafts are never sent to Supabase and have no schedule. Sealing is an explicit action; it validates the signed-in owner and a future time, inserts the `messages` row (status `scheduled`), then deletes the local draft. After that the message is sealed and follows the delete-only rules. Discarding, the session ending for any reason (sign-out, expiry, revocation), or loading a draft that belongs to another account or can't be read deletes it from the device. Once the server insert succeeds the message counts as sealed even if deleting the local draft fails, so it is never sealed twice.

## Access control

RLS is enabled on every user-data table. Policies compare `auth.uid()` to the row's `user_id`. Client inserts must set their own `user_id`. Sealed messages are delete-only: clients have no update grant or policy on `messages`, and an owner may delete a row only while it is `scheduled` and `scheduled_for > now()`; release fields are changed only by trusted server code. A client may read message content only when `status = 'available'` and `scheduled_for <= now()`. Owners can list metadata for all of their own rows through the client's restricted column grant; do not grant clients direct `SELECT` of sealed content. Secret keys bypass RLS and are confined to Edge Functions, which validate the user or process due rows. Never ship a secret key.

Never trust a user ID sent from the client. Storage buckets are private by default and covered by policies. Edge Functions invoked by users verify the caller's JWT.

The migration establishes owner policies on every table. Client table grants exclude `body`; the `get_available_message` RPC returns it only after checking owner, release state, and server time. Device token writes go through the `register_device_token` RPC rather than a direct grant, since reassigning a token from a shared device's previous owner needs to bypass that owner's RLS row. Before opening beta, verify sealed-content isolation and cross-account isolation with two test users and the production-equivalent policies.

## Environments and credentials

Use `--dart-define-from-file=config/dev.json` or `config/prod.json` (templates contain placeholders). `APP_ENV` must match `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`; configure separate Supabase projects. Android has `development` and `production` product flavors with distinct application IDs. iOS has matching `development` and `production` schemes with distinct bundle IDs; set the corresponding Xcode signing and provisioning profiles. The app refuses to start unless `APP_ENV` matches the build flavor. Do not commit real keys or signing material.

Required hosted configuration: Supabase URL and publishable key in the app; Supabase secret key only as an Edge Function secret; FCM service account and APNs authentication key as function secrets; APNs capability and provisioning profile for each iOS app ID; Android Firebase app registrations / `google-services.json` for both application IDs. The repository cannot create provider projects or signing credentials; follow `docs/environments.md` after those accounts exist.

## Failure, retries, and retention

Each release run claims due rows with `for update skip locked`, so overlapping runs never take the same row, and releases up to 1,000 rows in one transaction; any backlog is taken by the following runs. Cron records every run and its error in `cron.job_run_details` (purged after 7 days); `message_release_backlog` (server roles only) shows the overdue count and the oldest lag. The push function retries transient failures with backoff. A unique outbox key prevents duplicate logical notifications. Permanent provider errors are recorded for operations review; notification failure never rolls back message release. Every release run takes all overdue rows, so outages are caught up automatically. Monitor the release backlog, function errors, and notification failures; alert on sustained backlog. Do not include content or tokens in routine logs.

Account deletion is an authenticated request that first disables sign-in, then deletes the Auth user; `ON DELETE CASCADE` removes messages, device tokens, and outbox rows. Define a short operational backup expiry (target 30 days) and disclose that encrypted backups age out on that schedule; restore procedures must reapply deletion requests recorded since the backup. Keep only non-identifying aggregate operational metrics. Product/legal owners must confirm the retention window and privacy policy before public launch.

## Decisions log

| Date | Decision | Why |
|------|----------|-----|
| 2026-11-15 | Riverpod 3 + codegen, go_router | Low boilerplate, testable without BuildContext, community default |
| 2026-11-15 | Supabase as backend | — |
| 2026-11-15 | Flutter deep linking off; `supabase_flutter` alone handles the auth deep link | Keeps auth callback URLs out of go_router; routing follows auth state instead |
| 2026-11-18 | Unsealed drafts live only on the device (`flutter_secure_storage`), deleted on seal, discard and session end; sealing is a separate explicit step | Lets people take their time writing while sealed messages stay final; nothing private reaches the server or outlives the session before sealing |
| 2026-11-20 | Release due messages with a SQL function run by Supabase Cron every 30 seconds, not an Edge Function | One transaction in one place, no HTTP hop or secret key, nothing metered; a missed run is caught up by the next |

# Laternote architecture (MVP)

## Selected services

- **Backend:** Supabase: separate development and production projects, each with Auth, Postgres, Row Level Security (RLS), and Edge Functions. Do not point a development build at production.
- **Authentication:** Supabase Auth email and password with email confirmation and password reset. The Flutter client uses the Supabase publishable key (`sb_publishable_...`) and the signed-in user's JWT. Secret keys (`sb_secret_...`) are server-only.
- **Scheduling and delivery:** A database-backed due-message queue is processed by a scheduled Supabase Edge Function (or Supabase Cron invoking that function). The database, not an app timer or local clock, determines release. The function marks due messages available transactionally and enqueues a notification outbox event. Retries are idempotent using message ID plus event type.
- **Push:** The function sends a generic “A message is ready” push through FCM/APNs using the user's current device token. Notification payloads contain only an opaque message ID and a deep-link route, never message text. Supabase secrets hold provider credentials. Users can still read available messages from the inbox if push is denied or fails.

## Data model

The initial schema is in `supabase/migrations/`. `messages` rows belong to one `auth.users` UUID. `body` is capped at 20,000 characters. `scheduled_for` is a UTC `timestamptz`; `timezone` records the IANA zone selected at composition for display and is validated against `pg_timezone_names`. Status is `scheduled` or `available`; `released_at` and `updated_at` are set by trusted server code (messages are hard-deleted, not soft-deleted). Device tokens live in a separate owner-scoped table, written only through the `register_device_token` RPC so a token can be reassigned when a shared device changes user, and are removed on sign-out/token rotation. The notification outbox records attempts and provider outcome without storing message body.

## Access control

RLS is enabled on every user-data table. Policies compare `auth.uid()` to the row's `user_id` for select/insert/update/delete. Client inserts must set their own `user_id`; updates cannot change ownership or server-controlled delivery fields. A client may read message content only when `status = 'available'` and `scheduled_for <= now()`. Scheduled rows can be listed without content through the client's restricted column grant; do not grant clients direct `SELECT` of sealed content. Secret keys bypass RLS and are confined to Edge Functions, which validate the user or process due rows. Never ship a secret key.

The migration establishes owner policies on every table. Client table grants exclude `body`; the `get_available_message` RPC returns it only after checking owner, release state, and server time. Device token writes go through the `register_device_token` RPC rather than a direct grant, since reassigning a token from a shared device's previous owner needs to bypass that owner's RLS row. Before opening beta, verify sealed-content isolation and cross-account isolation with two test users and the production-equivalent policies.

## Environments and credentials

Use `--dart-define-from-file=config/dev.json` or `config/prod.json` (templates contain placeholders). `APP_ENV` must match `SUPABASE_URL` and `SUPABASE_PUBLISHABLE_KEY`; configure separate Supabase projects. Android has `development` and `production` product flavors with distinct application IDs. iOS has matching `development` and `production` schemes with distinct bundle IDs; set the corresponding Xcode signing and provisioning profiles. The app refuses to start unless `APP_ENV` matches the build flavor. Do not commit real keys or signing material.

Required hosted configuration: Supabase URL and publishable key in the app; Supabase secret key only as an Edge Function secret; FCM service account and APNs authentication key as function secrets; APNs capability and provisioning profile for each iOS app ID; Android Firebase app registrations / `google-services.json` for both application IDs. The repository cannot create provider projects or signing credentials; follow `docs/environments.md` after those accounts exist.

## Failure, retries, and retention

The scheduled function claims due rows safely, releases them in a transaction, and retries transient failures with backoff. A unique outbox key prevents duplicate logical notifications. Permanent provider errors are recorded for operations review; notification failure never rolls back message release. A periodic catch-up run processes overdue rows after outages. Monitor oldest due-but-unreleased row, function errors, and notification failures; alert on sustained backlog. Do not include content or tokens in routine logs.

Account deletion is an authenticated request that first disables sign-in, then deletes the Auth user; `ON DELETE CASCADE` removes messages, device tokens, and outbox rows. Define a short operational backup expiry (target 30 days) and disclose that encrypted backups age out on that schedule; restore procedures must reapply deletion requests recorded since the backup. Keep only non-identifying aggregate operational metrics. Product/legal owners must confirm the retention window and privacy policy before public launch.

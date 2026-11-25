# Development and production setup

## Flutter configuration

Copy `config/dev.example.json` to `config/dev.json` and `config/prod.example.json` to `config/prod.json`, then fill each with its own Supabase project URL and publishable key (`sb_publishable_...`). These local files are ignored by Git. Publishable keys are not authorization secrets; RLS is mandatory. Never put a secret key (`sb_secret_...`) here; the app refuses any key that is not publishable.

Run development:

```sh
flutter run --flavor development --dart-define-from-file=config/dev.json
```

Build production:

```sh
flutter build appbundle --flavor production --dart-define-from-file=config/prod.json
flutter build ipa --flavor production --dart-define-from-file=config/prod.json
```

The app checks at startup that `APP_ENV` matches the build flavor and refuses to start otherwise; every run and build needs `--flavor` and the matching config file. Configure signing through local/CI secrets, not committed files.

## Android

Gradle flavors are `development` (`com.althenos.laternote.dev`) and `production` (`com.althenos.laternote`). Create a Firebase Android app for each ID and download each `google-services.json` into its matching `android/app/src/<flavor>/` directory (gitignored). The Google Services Gradle plugin reads it; a flavor without its file doesn't build. Configure release signing in CI.

On the Android emulator `127.0.0.1` is the emulator itself, so forward local Supabase to your machine with `adb reverse tcp:54321 tcp:54321` after each emulator start. The VS Code "Laternote (development)" launch does this automatically.

## iOS

Xcode schemes are `development` (`com.althenos.laternote.dev`, 'Laternote Dev') and `production` (`com.althenos.laternote`, 'Laternote'), each with Debug, Release, and Profile configurations (`Debug-development`, `Release-production`, ...). Bundle ID and display name are set per configuration in the Runner target. Select the matching signing team in Xcode/CI and register both IDs in Apple Developer. Enable Push Notifications and configure APNs for each app. Register matching iOS Firebase apps and put each `GoogleService-Info.plist` in `ios/config/<flavor>/` (gitignored); a build phase copies the one for the current configuration into the app and fails the build if it's missing. Upload the APNs key to Firebase for iOS pushes. Apple signing certificates, provisioning profiles, APNs keys, and Firebase service-account credentials are managed secrets and are intentionally not committed.

## Supabase projects

Create isolated development and production Supabase projects. Apply migrations with the Supabase CLI. Deploy the delivery Edge Function and configure its scheduled invocation in both projects. Set function secrets for the Supabase secret key, FCM, and APNs separately per project. Test RLS and due-message retry behavior in development before promoting migrations/functions to production.

Push delivery needs, per project:

- Function secrets for `send-notifications`: `PUSH_CRON_SECRET` (a random string), `SERVER_SECRET_KEY` (the project's `sb_secret_...` key) and `FCM_SERVICE_ACCOUNT` (the Firebase service-account JSON, with the Firebase Cloud Messaging API enabled).
- Vault secrets read by `dispatch_notifications()`: `send_notifications_url` (`https://<ref>.supabase.co/functions/v1/send-notifications`) and `push_cron_secret` (same value as `PUSH_CRON_SECRET`).

Locally, copy `supabase/functions/.env.example` to `supabase/functions/.env` (gitignored) and fill it in, run `supabase functions serve`, and set `send_notifications_url` to `http://supabase_kong_<project_id>:8000/functions/v1/send-notifications`, since `pg_net` runs inside the database container. Without these Vault secrets every `dispatch-notifications` cron run fails (see `cron.job_run_details`) and notifications wait in the outbox. Create them once per database (again after `supabase db reset`) in the SQL editor:

```sql
select vault.create_secret('<send-notifications URL>', 'send_notifications_url');
select vault.create_secret('<PUSH_CRON_SECRET value>', 'push_cron_secret');
```

To change a value later, use `vault.update_secret(id, '<new value>')` with the `id` from `vault.secrets`.

## Current setup status

Repository configuration includes environment IDs, flavor definitions, startup validation, placeholder config, and the initial database migration. Provider-side projects, actual credential files, Apple signing, push capabilities, and scheduled function deployment still require access to Laternote's Supabase, Firebase, and Apple Developer accounts.

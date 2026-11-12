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

Gradle flavors are `development` (`com.althenos.laternote.dev`) and `production` (`com.althenos.laternote`). Create a Firebase Android app for each ID, download each `google-services.json` into its matching `android/app/src/<flavor>/` directory, and install/configure the Google Services Gradle plugin and FCM only when push implementation is added. Keep Firebase files out of source control if they contain project-specific identifiers. Configure release signing in CI.

## iOS

Xcode schemes are `development` (`com.althenos.laternote.dev`, 'Laternote Dev') and `production` (`com.althenos.laternote`, 'Laternote'), each with Debug, Release, and Profile configurations (`Debug-development`, `Release-production`, ...). Bundle ID and display name are set per configuration in the Runner target. Select the matching signing team in Xcode/CI and register both IDs in Apple Developer. Enable Push Notifications and configure APNs for each app. Register matching iOS Firebase apps and add their `GoogleService-Info.plist` files locally when FCM integration is implemented. Apple signing certificates, provisioning profiles, APNs keys, and Firebase service-account credentials are managed secrets and are intentionally not committed.

## Supabase projects

Create isolated development and production Supabase projects. Apply migrations with the Supabase CLI. Deploy the delivery Edge Function and configure its scheduled invocation in both projects. Set function secrets for the Supabase secret key, FCM, and APNs separately per project. Test RLS and due-message retry behavior in development before promoting migrations/functions to production.

## Current setup status

Repository configuration includes environment IDs, flavor definitions, startup validation, placeholder config, and the initial database migration. Provider-side projects, actual credential files, Apple signing, push capabilities, and scheduled function deployment still require access to Laternote's Supabase, Firebase, and Apple Developer accounts.

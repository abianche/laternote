# Development and production setup

Laternote has no backend and no runtime configuration. The two flavors only give development and production builds distinct app IDs, so a development build never touches real letters.

Run development:

```sh
flutter run --flavor development
```

Build production:

```sh
flutter build appbundle --flavor production
flutter build ipa --flavor production
```

## Android

Gradle flavors are `development` (`com.althenos.laternote.dev`) and `production` (`com.althenos.laternote`). Configure release signing in CI.

## iOS

Xcode schemes are `development` (`com.althenos.laternote.dev`, 'Laternote Dev') and `production` (`com.althenos.laternote`, 'Laternote'), each with Debug, Release, and Profile configurations (`Debug-development`, `Release-production`, ...). Bundle ID and display name are set per configuration in the Runner target. Select the matching signing team in Xcode/CI and register both IDs in Apple Developer.

Signing certificates and provisioning profiles are managed secrets and are never committed.

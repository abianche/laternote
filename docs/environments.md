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

Gradle flavors are `development` (`com.althenos.laternote.dev`) and `production` (`com.althenos.laternote`).

### Release signing

Signing is local only. Development builds use the debug key. A production release is signed with the upload key (Google Play App Signing holds the app signing key):

- The upload keystore lives outside the repo, on the maintainer's machine; its passwords and a backup of the `.jks` are in the maintainer's password manager.
- `android/key.properties` (gitignored, never committed) points Gradle at it:

  ```properties
  storeFile=/absolute/path/to/upload-keystore.jks
  storePassword=...
  keyAlias=upload
  keyPassword=...
  ```

- Building a production release without `android/key.properties` fails; there is no debug-key fallback.

Verify a signed bundle: the SHA-256 printed by

```sh
keytool -printcert -jarfile build/app/outputs/bundle/productionRelease/app-production-release.aab
```

must match the one from `keytool -list -v -keystore <keystore> -alias upload`, and the owner must not be `CN=Android Debug`.

## Versioning

`version:` in `pubspec.yaml` is the only source, as `<versionName>+<build number>`. The version name is semver (`MAJOR.MINOR.PATCH`). The build number (Android `versionCode`, iOS `CFBundleVersion`) is one integer shared by both platforms, raised by one for every store upload and never reused. The first release is `1.0.0+2`.

## iOS

Xcode schemes are `development` (`com.althenos.laternote.dev`, 'Laternote Dev') and `production` (`com.althenos.laternote`, 'Laternote'), each with Debug, Release, and Profile configurations (`Debug-development`, `Release-production`, ...). Bundle ID and display name are set per configuration in the Runner target. Select the matching signing team in Xcode/CI and register both IDs in Apple Developer.

Signing certificates and provisioning profiles are managed secrets and are never committed.

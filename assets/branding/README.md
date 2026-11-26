# Branding

Source art for the launcher icons and launch screen, painted by `tool/branding/`. Not bundled in the app.

To regenerate after changing the art:

```sh
flutter test tool/branding/render_test.dart   # writes the PNGs here
dart run flutter_launcher_icons               # per-flavor icons
dart run flutter_native_splash:create         # launch screen
git checkout ios/Runner/Info.plist            # the splash tool reformats it and adds a default key
```

iOS build configurations pick their icon set via `ASSETCATALOG_COMPILER_APPICON_NAME` (`AppIcon-development` / `AppIcon-production`).

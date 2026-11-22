import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

/// App strings plus material_ui's Material, Cupertino and Widgets
/// localizations. Not `AppLocalizations.localizationsDelegates`: that list
/// uses flutter_localizations' Material delegate, which material_ui widgets
/// don't look up.
const appLocalizationsDelegates = <LocalizationsDelegate<Object?>>[
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// English first: Flutter falls back to the first entry for any other
/// device locale.
const appSupportedLocales = AppLocalizations.supportedLocales;

import 'package:flutter/services.dart' show appFlavor;

/// Compile-time backend configuration. Values are supplied with
/// --dart-define-from-file and must only contain a Supabase publishable key.
class AppEnvironment {
  static const name = String.fromEnvironment('APP_ENV');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured =>
      (name == 'development' || name == 'production') &&
      Uri.tryParse(supabaseUrl)?.host.endsWith('.supabase.co') == true &&
      supabasePublishableKey.startsWith('sb_publishable_');

  /// Throws unless the config file's APP_ENV matches the build flavor.
  static void validate() {
    if (appFlavor == null || name != appFlavor || !isConfigured) {
      throw StateError(
        'Invalid Laternote configuration: flavor "$appFlavor" got '
        'APP_ENV "$name". Build with --flavor development and '
        'config/dev.json, or --flavor production and config/prod.json.',
      );
    }
  }
}

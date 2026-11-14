import 'package:flutter/services.dart' show appFlavor;

/// Pure, testable check of a Supabase Flutter configuration: the build
/// flavor must match the declared environment, the URL must be https
/// (http allowed only to loopback, and only in development, for a local
/// Supabase stack), and the key must be a publishable key.
bool isValidSupabaseConfig({
  required String? flavor,
  required String env,
  required String url,
  required String publishableKey,
}) {
  if (flavor == null || env != flavor) return false;
  if (env != 'development' && env != 'production') return false;
  if (!publishableKey.startsWith('sb_publishable_')) return false;

  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) return false;

  if (uri.scheme == 'https') return true;
  final isLoopbackHost = uri.host == 'localhost' || uri.host == '127.0.0.1';
  return uri.scheme == 'http' && env == 'development' && isLoopbackHost;
}

/// Compile-time backend configuration. Values are supplied with
/// --dart-define-from-file and must only contain a Supabase publishable key.
class AppEnvironment {
  static const name = String.fromEnvironment('APP_ENV');
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static bool get isConfigured => isValidSupabaseConfig(
    flavor: appFlavor,
    env: name,
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  /// Throws unless the config file's APP_ENV matches the build flavor.
  static void validate() {
    if (!isConfigured) {
      throw StateError(
        'Invalid Laternote configuration: flavor "$appFlavor" got '
        'APP_ENV "$name". Build with --flavor development and '
        'config/dev.json, or --flavor production and config/prod.json.',
      );
    }
  }
}

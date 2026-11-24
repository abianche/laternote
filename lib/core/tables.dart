/// Supabase table names.
abstract final class Tables {
  static const deviceTokens = 'device_tokens';
}

/// Supabase RPC (database function) names.
abstract final class Rpcs {
  static const registerDeviceToken = 'register_device_token';
}

/// Longest letter body, in characters; the `letters.body` check enforces it.
const maxMessageLength = 20000;

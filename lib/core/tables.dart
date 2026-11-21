/// Supabase table names.
abstract final class Tables {
  static const messages = 'messages';
  static const deviceTokens = 'device_tokens';
}

/// Supabase RPC (database function) names.
abstract final class Rpcs {
  static const getAvailableMessage = 'get_available_message';
  static const markMessageOpened = 'mark_message_opened';
  static const registerDeviceToken = 'register_device_token';
}

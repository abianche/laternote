/// Supabase table names.
abstract final class Tables {
  static const messages = 'messages';
}

/// Supabase RPC (database function) names.
abstract final class Rpcs {
  static const getAvailableMessage = 'get_available_message';
  static const markMessageOpened = 'mark_message_opened';
}

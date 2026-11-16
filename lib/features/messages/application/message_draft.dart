/// Must match the `messages.body` check constraint.
const maxMessageLength = 20000;

/// A message being composed. [deliverAt] is a device-local time, null until
/// picked.
class MessageDraft {
  const MessageDraft({this.body = '', this.deliverAt});

  final String body;
  final DateTime? deliverAt;

  MessageDraft copyWith({String? body, DateTime? deliverAt}) => MessageDraft(
    body: body ?? this.body,
    deliverAt: deliverAt ?? this.deliverAt,
  );
}

String? validateBody(String? body) {
  final text = body ?? '';
  if (text.trim().isEmpty) return 'Write something to your future self.';
  if (text.characters > maxMessageLength) {
    return 'Keep it under $maxMessageLength characters.';
  }
  return null;
}

String? validateDeliverAt(DateTime? deliverAt, DateTime now) {
  if (deliverAt == null) return 'Pick a delivery date and time.';
  if (!deliverAt.isAfter(now)) return 'Pick a time in the future.';
  return null;
}

extension on String {
  /// Length in Unicode code points, matching Postgres `char_length`.
  int get characters => runes.length;
}

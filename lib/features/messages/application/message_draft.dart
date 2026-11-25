import '../../../core/app_error.dart';
import '../../../core/limits.dart';

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

ValidationProblem? validateBody(String? body) {
  final text = body ?? '';
  if (text.trim().isEmpty) return ValidationProblem.bodyEmpty;
  if (text.characters > maxMessageLength) return ValidationProblem.bodyTooLong;
  return null;
}

ValidationProblem? validateDeliverAt(DateTime? deliverAt, DateTime now) {
  if (deliverAt == null) return ValidationProblem.deliveryMissing;
  if (!deliverAt.isAfter(now)) return ValidationProblem.deliveryInPast;
  return null;
}

extension on String {
  /// Length in Unicode code points, matching Postgres `char_length`.
  int get characters => runes.length;
}

/// A sealed message as the upcoming list sees it. Deliberately has no body:
/// content is never read before it is ready.
class ScheduledMessage {
  const ScheduledMessage({
    required this.id,
    required this.scheduledFor,
    required this.timezone,
    required this.createdAt,
  });

  final String id;

  /// Delivery instant, in device-local time.
  final DateTime scheduledFor;

  /// IANA zone chosen when composing, for display.
  final String timezone;

  /// When it was sealed, in device-local time.
  final DateTime createdAt;

  /// Past its time while the list still shows it; it moves to the inbox on
  /// the next refresh.
  bool isOpeningSoon(DateTime now) => !scheduledFor.isAfter(now);

  @override
  bool operator ==(Object other) =>
      other is ScheduledMessage &&
      other.id == id &&
      other.scheduledFor == scheduledFor &&
      other.timezone == timezone &&
      other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(id, scheduledFor, timezone, createdAt);
}

/// A sealed message as the upcoming list sees it. Deliberately has no body:
/// content is never fetched before release.
class ScheduledMessage {
  const ScheduledMessage({
    required this.id,
    required this.scheduledFor,
    required this.timezone,
    required this.createdAt,
  });

  factory ScheduledMessage.fromRow(Map<String, dynamic> row) =>
      ScheduledMessage(
        id: row['id'] as String,
        scheduledFor: DateTime.parse(row['scheduled_for'] as String).toLocal(),
        timezone: row['timezone'] as String,
        createdAt: DateTime.parse(row['created_at'] as String).toLocal(),
      );

  final String id;

  /// Delivery instant, in device-local time.
  final DateTime scheduledFor;

  /// IANA zone chosen when composing, for display.
  final String timezone;

  /// When it was sealed, in device-local time.
  final DateTime createdAt;

  /// Past its time but not yet released by the server.
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

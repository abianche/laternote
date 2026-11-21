/// A released message as the inbox lists it. Like `ScheduledMessage` it has
/// no body: content is fetched only when the message is opened.
class InboxItem {
  const InboxItem({
    required this.id,
    required this.createdAt,
    required this.releasedAt,
    required this.openedAt,
  });

  factory InboxItem.fromRow(Map<String, dynamic> row) => InboxItem(
    id: row['id'] as String,
    createdAt: _local(row['created_at'])!,
    releasedAt: _local(row['released_at'])!,
    openedAt: _local(row['opened_at']),
  );

  final String id;

  /// When it was sealed, in device-local time.
  final DateTime createdAt;

  /// When the server released it, in device-local time.
  final DateTime releasedAt;

  /// First time the owner opened it; null while it's new.
  final DateTime? openedAt;

  bool get isNew => openedAt == null;

  @override
  bool operator ==(Object other) =>
      other is InboxItem &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.releasedAt == releasedAt &&
      other.openedAt == openedAt;

  @override
  int get hashCode => Object.hash(id, createdAt, releasedAt, openedAt);
}

/// A released message with its content, from `get_available_message`.
class AvailableMessage {
  const AvailableMessage({
    required this.id,
    required this.body,
    required this.scheduledFor,
    required this.timezone,
    required this.createdAt,
    required this.releasedAt,
    required this.openedAt,
  });

  factory AvailableMessage.fromRow(Map<String, dynamic> row) =>
      AvailableMessage(
        id: row['id'] as String,
        body: row['body'] as String,
        scheduledFor: _local(row['scheduled_for'])!,
        timezone: row['timezone'] as String,
        createdAt: _local(row['created_at'])!,
        releasedAt: _local(row['released_at'])!,
        openedAt: _local(row['opened_at']),
      );

  final String id;
  final String body;

  /// The time it was set to open, in device-local time.
  final DateTime scheduledFor;

  /// IANA zone chosen when composing.
  final String timezone;

  /// When it was sealed, in device-local time.
  final DateTime createdAt;

  /// When the server released it, in device-local time.
  final DateTime releasedAt;

  /// First time the owner opened it; null on the first open.
  final DateTime? openedAt;

  @override
  bool operator ==(Object other) =>
      other is AvailableMessage &&
      other.id == id &&
      other.body == body &&
      other.scheduledFor == scheduledFor &&
      other.timezone == timezone &&
      other.createdAt == createdAt &&
      other.releasedAt == releasedAt &&
      other.openedAt == openedAt;

  @override
  int get hashCode => Object.hash(
    id,
    body,
    scheduledFor,
    timezone,
    createdAt,
    releasedAt,
    openedAt,
  );
}

DateTime? _local(Object? value) =>
    value == null ? null : DateTime.parse(value as String).toLocal();

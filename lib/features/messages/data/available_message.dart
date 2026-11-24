/// A ready letter as the inbox lists it. Like `ScheduledMessage` it has no
/// body: content is read only when the letter is opened.
class InboxItem {
  const InboxItem({
    required this.id,
    required this.createdAt,
    required this.scheduledFor,
    required this.openedAt,
  });

  final String id;

  /// When it was sealed, in device-local time.
  final DateTime createdAt;

  /// When it became ready to open, in device-local time.
  final DateTime scheduledFor;

  /// First time the owner opened it; null while it's new.
  final DateTime? openedAt;

  bool get isNew => openedAt == null;

  @override
  bool operator ==(Object other) =>
      other is InboxItem &&
      other.id == id &&
      other.createdAt == createdAt &&
      other.scheduledFor == scheduledFor &&
      other.openedAt == openedAt;

  @override
  int get hashCode => Object.hash(id, createdAt, scheduledFor, openedAt);
}

/// A ready letter with its content.
class AvailableMessage {
  const AvailableMessage({
    required this.id,
    required this.body,
    required this.scheduledFor,
    required this.timezone,
    required this.createdAt,
    required this.openedAt,
  });

  final String id;
  final String body;

  /// When it became ready to open, in device-local time.
  final DateTime scheduledFor;

  /// IANA zone chosen when composing.
  final String timezone;

  /// When it was sealed, in device-local time.
  final DateTime createdAt;

  /// First time it was opened; null on the first open.
  final DateTime? openedAt;

  @override
  bool operator ==(Object other) =>
      other is AvailableMessage &&
      other.id == id &&
      other.body == body &&
      other.scheduledFor == scheduledFor &&
      other.timezone == timezone &&
      other.createdAt == createdAt &&
      other.openedAt == openedAt;

  @override
  int get hashCode => Object.hash(
    id,
    body,
    scheduledFor,
    timezone,
    createdAt,
    openedAt,
  );
}

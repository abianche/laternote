import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/notifications/data/local_notifications_repository.dart';

void main() {
  test('permission is undecided until this install asks', () {
    expect(
      notificationAccessFrom(enabled: false, asked: false),
      NotificationAccess.notDetermined,
    );
    expect(
      notificationAccessFrom(enabled: false, asked: true),
      NotificationAccess.denied,
    );
    expect(
      notificationAccessFrom(enabled: true, asked: false),
      NotificationAccess.granted,
    );
  });

  test('only a letter ID is taken from a payload', () {
    const id = '0b7e2c1a-4f3d-4c2b-9a8e-1d2c3b4a5f6e';
    expect(letterIdFrom(id), id);
    expect(letterIdFrom('/messages/$id'), isNull);
    expect(letterIdFrom(''), isNull);
    expect(letterIdFrom(null), isNull);
  });

  test('notification IDs are stable, positive 31-bit ints', () {
    expect(
      notificationIdFor('0b7e2c1a-4f3d-4c2b-9a8e-1d2c3b4a5f6e'),
      0x0b7e2c1a,
    );
    expect(
      notificationIdFor('ffffffff-4f3d-4c2b-9a8e-1d2c3b4a5f6e'),
      0x7fffffff,
    );
  });
}

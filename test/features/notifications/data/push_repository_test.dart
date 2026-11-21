import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/notifications/data/push_repository.dart';

void main() {
  const id = '0b7e2c1a-4f3d-4c2b-9a8e-1d2c3b4a5f6e';

  test('reads a message ID from the payload', () {
    expect(messageIdFrom({'message_id': id}), id);
    expect(messageIdFrom({'message_id': id.toUpperCase()}), id.toUpperCase());
  });

  test('ignores a missing or malformed message ID', () {
    expect(messageIdFrom({}), isNull);
    expect(messageIdFrom({'message_id': 42}), isNull);
    expect(messageIdFrom({'message_id': '../account'}), isNull);
    expect(messageIdFrom({'message_id': '$id/x'}), isNull);
  });

  test('maps every authorization status', () {
    expect(
      pushPermissionFrom(AuthorizationStatus.authorized),
      PushPermission.granted,
    );
    expect(
      pushPermissionFrom(AuthorizationStatus.provisional),
      PushPermission.granted,
    );
    expect(
      pushPermissionFrom(AuthorizationStatus.denied),
      PushPermission.denied,
    );
    expect(
      pushPermissionFrom(AuthorizationStatus.deniedPermanently),
      PushPermission.denied,
    );
    expect(
      pushPermissionFrom(AuthorizationStatus.notDetermined),
      PushPermission.notDetermined,
    );
  });
}

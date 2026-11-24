import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'draft_repository.g.dart';

/// An unsealed message as stored on the device. [deliverAt] is device-local.
typedef StoredDraft = ({String body, DateTime? deliverAt});

/// Keeps the one unsealed draft in the platform's encrypted storage
/// (Keychain on iOS, never backed up or moved to another device). Sealing
/// goes through `MessagesRepository`.
class DraftRepository {
  DraftRepository(this._storage);

  static const _key = 'compose_draft';

  final FlutterSecureStorage _storage;

  /// The draft, or null. A draft that can't be read is deleted rather than
  /// shown.
  Future<StoredDraft?> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, Object?>;
      final deliverAt = json['deliver_at'] as String?;
      return (
        body: json['body'] as String,
        deliverAt: deliverAt == null ? null : DateTime.parse(deliverAt),
      );
    } on Object {
      // Includes storage that can no longer be decrypted (e.g. the Android
      // screen lock was reset). Best effort: the next save overwrites it.
      await clear().catchError((Object _) {});
      return null;
    }
  }

  Future<void> save(StoredDraft draft) => _storage.write(
    key: _key,
    value: jsonEncode({
      'body': draft.body,
      'deliver_at': draft.deliverAt?.toIso8601String(),
    }),
  );

  Future<void> clear() => _storage.delete(key: _key);
}

@Riverpod(keepAlive: true)
DraftRepository draftRepository(Ref ref) => DraftRepository(
  const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  ),
);

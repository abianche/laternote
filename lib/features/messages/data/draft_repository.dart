import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/app_error.dart';
import '../../../core/supabase_client.dart';

part 'draft_repository.g.dart';

/// An unsealed message as stored on the device. [deliverAt] is device-local.
typedef StoredDraft = ({String body, DateTime? deliverAt});

/// Keeps the signed-in user's one unsealed draft on this device only, in the
/// platform's encrypted storage (Keychain on iOS, never backed up or moved to
/// another device). Drafts are never sent to Supabase; sealing goes through
/// `MessagesRepository`.
class DraftRepository {
  DraftRepository(this._storage, this._currentUserId);

  static const _key = 'compose_draft';

  final FlutterSecureStorage _storage;
  final String? Function() _currentUserId;

  /// The current user's draft, or null. A draft left by another account, or
  /// one that can't be read, is deleted rather than shown.
  Future<StoredDraft?> load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, Object?>;
      if (json['user_id'] != _currentUserId()) throw const FormatException();
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

  Future<void> save(StoredDraft draft) async {
    final userId = _currentUserId();
    if (userId == null) {
      throw const AuthError('You are signed out. Sign in and try again.');
    }
    await _storage.write(
      key: _key,
      value: jsonEncode({
        'user_id': userId,
        'body': draft.body,
        'deliver_at': draft.deliverAt?.toIso8601String(),
      }),
    );
  }

  Future<void> clear() => _storage.delete(key: _key);
}

@Riverpod(keepAlive: true)
DraftRepository draftRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return DraftRepository(
    const FlutterSecureStorage(
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
    () => client.auth.currentUser?.id,
  );
}

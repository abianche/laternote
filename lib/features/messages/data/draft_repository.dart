import 'dart:convert';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/app_error.dart';
import '../../../core/supabase_client.dart';

part 'draft_repository.g.dart';

/// An unsealed message as stored on the device. [deliverAt] is device-local.
typedef StoredDraft = ({String body, DateTime? deliverAt});

/// Keeps the signed-in user's one unsealed draft on this device only. Drafts
/// are never sent to Supabase; sealing goes through `MessagesRepository`.
class DraftRepository {
  DraftRepository(this._prefs, this._currentUserId);

  static const _key = 'compose_draft';

  final SharedPreferencesAsync _prefs;
  final String? Function() _currentUserId;

  /// The current user's draft, or null. A draft left by another account is
  /// deleted rather than shown.
  Future<StoredDraft?> load() async {
    final raw = await _prefs.getString(_key);
    if (raw == null) return null;
    final json = jsonDecode(raw) as Map<String, Object?>;
    if (json['user_id'] != _currentUserId()) {
      await clear();
      return null;
    }
    final deliverAt = json['deliver_at'] as String?;
    return (
      body: json['body'] as String,
      deliverAt: deliverAt == null ? null : DateTime.parse(deliverAt),
    );
  }

  Future<void> save(StoredDraft draft) async {
    final userId = _currentUserId();
    if (userId == null) {
      throw const AuthError('You are signed out. Sign in and try again.');
    }
    await _prefs.setString(
      _key,
      jsonEncode({
        'user_id': userId,
        'body': draft.body,
        'deliver_at': draft.deliverAt?.toIso8601String(),
      }),
    );
  }

  Future<void> clear() => _prefs.remove(_key);
}

@Riverpod(keepAlive: true)
DraftRepository draftRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return DraftRepository(
    SharedPreferencesAsync(),
    () => client.auth.currentUser?.id,
  );
}

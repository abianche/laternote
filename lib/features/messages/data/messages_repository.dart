import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_error.dart';
import '../../../core/supabase_client.dart';
import '../../../core/tables.dart';

part 'messages_repository.g.dart';

/// The only place that talks to the `messages` table. Every failure is
/// rethrown as an [AppError].
class MessagesRepository {
  MessagesRepository(this._db, this._currentUserId);

  final PostgrestClient _db;
  final String? Function() _currentUserId;

  /// Inserts a sealed message. The database sets `status = 'scheduled'` and
  /// RLS rejects a past [scheduledFor] or a foreign owner.
  Future<void> createScheduledMessage({
    required String body,
    required DateTime scheduledFor,
    required String timezone,
  }) async {
    final userId = _currentUserId();
    if (userId == null) {
      throw const AuthError('You are signed out. Sign in and try again.');
    }
    try {
      await _db.from(Tables.messages).insert({
        'user_id': userId,
        'body': body,
        'scheduled_for': scheduledFor.toUtc().toIso8601String(),
        'timezone': timezone,
      });
    } on PostgrestException catch (error) {
      throw switch (error.code) {
        // RLS: the only client-controllable reason is a time already past.
        '42501' => const ValidationError(
          'That delivery time has already passed. Pick a later time.',
        ),
        // Check constraint on body.
        '23514' => const ValidationError(
          'A message needs some text, up to 20,000 characters.',
        ),
        _ => mapSupabaseError(error),
      };
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }
}

@Riverpod(keepAlive: true)
MessagesRepository messagesRepository(Ref ref) {
  final client = ref.watch(supabaseClientProvider);
  return MessagesRepository(client.rest, () => client.auth.currentUser?.id);
}

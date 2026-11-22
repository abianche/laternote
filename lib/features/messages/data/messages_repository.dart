import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_error.dart';
import '../../../core/supabase_client.dart';
import '../../../core/tables.dart';
import 'available_message.dart';
import 'scheduled_message.dart';

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
      throw const SignedOutError();
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
        '42501' => const ValidationError(ValidationProblem.deliveryPassed),
        // Check constraint on body.
        '23514' => const ValidationError(ValidationProblem.bodyInvalid),
        _ => mapSupabaseError(error),
      };
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }

  /// Deletes the user's sealed message [id]. RLS only allows it while the
  /// message is still scheduled for the future; otherwise no row is deleted
  /// and this throws a [ValidationError].
  Future<void> deleteScheduledMessage(String id) async {
    try {
      final deleted = await _db
          .from(Tables.messages)
          .delete()
          .eq('id', id)
          .select('id');
      if (deleted.isEmpty) {
        throw const ValidationError(ValidationProblem.alreadyOpening);
      }
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }

  /// The user's sealed, not-yet-released messages, soonest first. Selects
  /// metadata only; `body` is not granted to clients anyway.
  Future<List<ScheduledMessage>> listUpcoming() async {
    try {
      final rows = await _db
          .from(Tables.messages)
          .select('id, scheduled_for, timezone, created_at')
          .eq('status', 'scheduled')
          .order('scheduled_for', ascending: true);
      return rows.map(ScheduledMessage.fromRow).toList();
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }

  /// The user's released messages, newest first. Metadata only.
  Future<List<InboxItem>> listAvailable() async {
    try {
      final rows = await _db
          .from(Tables.messages)
          .select('id, created_at, released_at, opened_at')
          .eq('status', 'available')
          .order('released_at', ascending: false);
      return rows.map(InboxItem.fromRow).toList();
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }

  /// The released message [id] with its content, or null if it doesn't
  /// exist, isn't the user's, hasn't been released yet, or [id] isn't a
  /// valid message ID (e.g. from a bad link).
  Future<AvailableMessage?> getAvailable(String id) async {
    try {
      final rows = await _db.rpc<List<dynamic>>(
        Rpcs.getAvailableMessage,
        params: {'p_message_id': id},
      );
      return rows.isEmpty
          ? null
          : AvailableMessage.fromRow(rows.first as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      // invalid_text_representation: [id] is not a UUID.
      if (error.code == '22P02') return null;
      throw mapSupabaseError(error);
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }

  /// Records the first time the user opened released message [id]. The
  /// server ignores repeats and messages that aren't released.
  Future<void> markOpened(String id) async {
    try {
      await _db.rpc<void>(
        Rpcs.markMessageOpened,
        params: {'p_message_id': id},
      );
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

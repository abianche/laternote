import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_error.dart';
import '../../../core/supabase_client.dart';
import '../../../core/tables.dart';

part 'device_token_repository.g.dart';

/// The only place that talks to `device_tokens`. Every failure is rethrown
/// as an [AppError].
class DeviceTokenRepository {
  DeviceTokenRepository(this._db);

  final PostgrestClient _db;

  /// Assigns [token] to the signed-in user (the server takes the user from
  /// the session), taking it over from whoever had this device before.
  Future<void> register(String token, String platform) => _guard(
    () => _db.rpc<void>(
      Rpcs.registerDeviceToken,
      params: {'p_token': token, 'p_platform': platform},
    ),
  );

  /// Removes [token] from the signed-in user. RLS limits it to their own.
  Future<void> remove(String token) =>
      _guard(() => _db.from(Tables.deviceTokens).delete().eq('token', token));

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }
}

@Riverpod(keepAlive: true)
DeviceTokenRepository deviceTokenRepository(Ref ref) =>
    DeviceTokenRepository(ref.watch(supabaseClientProvider).rest);

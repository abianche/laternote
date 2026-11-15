import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/app_error.dart';
import '../../../core/supabase_client.dart';
import 'auth_status.dart';

part 'auth_repository.g.dart';

/// Must match the scheme registered in the Android manifest and iOS
/// Info.plist, and listed in supabase/config.toml's additional_redirect_urls.
const passwordRecoveryRedirect = 'io.laternote.auth://login-callback';

/// Maps a Supabase auth event and session to an [AuthStatus].
AuthStatus authStatusFrom(AuthChangeEvent event, Session? session) {
  if (event == AuthChangeEvent.passwordRecovery) {
    return const PasswordRecovery();
  }
  if (session != null) return SignedIn(email: session.user.email);
  return const SignedOut();
}

/// The only place that talks to Supabase Auth. Every failure is rethrown as
/// an [AppError].
class AuthRepository {
  AuthRepository(this._auth);

  final GoTrueClient _auth;

  AuthStatus get currentStatus =>
      authStatusFrom(AuthChangeEvent.initialSession, _auth.currentSession);

  Stream<AuthStatus> get statusChanges => _auth.onAuthStateChange.map(
    (state) => authStatusFrom(state.event, state.session),
  );

  Future<void> signIn({required String email, required String password}) =>
      _guard(() => _auth.signInWithPassword(email: email, password: password));

  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) => _guard(() async {
    final response = await _auth.signUp(email: email, password: password);
    return response.session == null
        ? SignUpOutcome.confirmationRequired
        : SignUpOutcome.signedIn;
  });

  Future<void> sendPasswordReset(String email) => _guard(
    () => _auth.resetPasswordForEmail(
      email,
      redirectTo: passwordRecoveryRedirect,
    ),
  );

  Future<void> updatePassword(String password) =>
      _guard(() => _auth.updateUser(UserAttributes(password: password)));

  Future<void> signOut() => _guard(_auth.signOut);

  Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error) {
      throw mapSupabaseError(error);
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    AuthRepository(ref.watch(supabaseClientProvider).auth);

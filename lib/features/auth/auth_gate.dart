import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../home/home_shell.dart';
import 'reset_password_screen.dart';
import 'sign_in_screen.dart';

/// Root widget: routes between the signed-out auth flow, the signed-in
/// app, and the password-reset screen, based on Supabase Auth state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      initialData: AuthState(
        AuthChangeEvent.initialSession,
        auth.currentSession,
      ),
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state?.event == AuthChangeEvent.passwordRecovery) {
          return const ResetPasswordScreen();
        }
        if (state?.session != null) {
          return const HomeShell();
        }
        return const SignInScreen();
      },
    );
  }
}

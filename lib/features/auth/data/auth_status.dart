/// Who is using the app right now, as far as routing cares.
sealed class AuthStatus {
  const AuthStatus();
}

final class SignedOut extends AuthStatus {
  const SignedOut();
}

final class SignedIn extends AuthStatus {
  const SignedIn({required this.email});

  final String? email;
}

/// Opened from a password-recovery link: a temporary session that may only
/// set a new password.
final class PasswordRecovery extends AuthStatus {
  const PasswordRecovery();
}

/// Result of a sign-up attempt.
enum SignUpOutcome {
  /// Signed in immediately (email confirmation disabled, e.g. local dev).
  signedIn,

  /// The user must confirm their email before signing in.
  confirmationRequired,
}

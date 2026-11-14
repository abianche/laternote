/// Pure, testable validation for the auth forms.
library;

/// Returns an error message for an invalid email, or null when it is valid.
String? validateEmail(String? value) {
  final trimmed = (value ?? '').trim();
  if (trimmed.isEmpty) return 'Enter your email address.';
  final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailPattern.hasMatch(trimmed)) return 'Enter a valid email address.';
  return null;
}

/// Returns an error message for an invalid password, or null when it is valid.
///
/// Matches the minimum_password_length configured for Supabase Auth.
String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter a password.';
  if (password.length < 8) return 'Password must be at least 8 characters.';
  return null;
}

/// Returns an error message when [confirmation] does not match [password].
String? validatePasswordConfirmation(String password, String confirmation) {
  if (confirmation.isEmpty) return 'Confirm your password.';
  if (confirmation != password) return 'Passwords do not match.';
  return null;
}

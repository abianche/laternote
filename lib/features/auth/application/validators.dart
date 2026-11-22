/// Pure, testable validation for the auth forms.
library;

/// Matches the minimum_password_length configured for Supabase Auth.
const minPasswordLength = 8;

/// Why an auth form field is invalid.
enum AuthFieldProblem {
  emailEmpty,
  emailInvalid,
  passwordEmpty,
  passwordTooShort,
  confirmationEmpty,
  passwordsDiffer,
}

/// Returns the problem with an invalid email, or null when it is valid.
AuthFieldProblem? validateEmail(String? value) {
  final trimmed = (value ?? '').trim();
  if (trimmed.isEmpty) return AuthFieldProblem.emailEmpty;
  final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
  if (!emailPattern.hasMatch(trimmed)) return AuthFieldProblem.emailInvalid;
  return null;
}

/// Returns the problem with an invalid password, or null when it is valid.
AuthFieldProblem? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return AuthFieldProblem.passwordEmpty;
  if (password.length < minPasswordLength) {
    return AuthFieldProblem.passwordTooShort;
  }
  return null;
}

/// Returns the problem when [confirmation] does not match [password].
AuthFieldProblem? validatePasswordConfirmation(
  String password,
  String confirmation,
) {
  if (confirmation.isEmpty) return AuthFieldProblem.confirmationEmpty;
  if (confirmation != password) return AuthFieldProblem.passwordsDiffer;
  return null;
}

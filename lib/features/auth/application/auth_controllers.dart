import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/app_error.dart';
import '../data/auth_repository.dart';
import '../data/auth_status.dart';

part 'auth_controllers.g.dart';

/// Runs [action] and returns its result as an [AsyncValue], or null when
/// the notifier was disposed meanwhile (e.g. the router navigated away).
Future<AsyncValue<T>?> _run<T>(Ref ref, Future<T> Function() action) async {
  final result = await AsyncValue.guard(action);
  return ref.mounted ? result : null;
}

/// Sign-in form. Success needs no state: the router reacts to the new
/// session.
@riverpod
class SignInController extends _$SignInController {
  @override
  FutureOr<void> build() {}

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await _run(
      ref,
      () => ref
          .read(authRepositoryProvider)
          .signIn(email: email.trim(), password: password),
    );
    if (result != null) state = result;
  }
}

/// Sign-up form. Holds the outcome once submitted, null before.
@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<SignUpOutcome?> build() => null;

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    final result = await _run(ref, () async {
      try {
        return await ref
            .read(authRepositoryProvider)
            .signUp(email: email.trim(), password: password);
      } on AccountAlreadyExistsError {
        // Same "check your email" state as for a new account, so the form
        // doesn't reveal whether an email is already registered.
        return SignUpOutcome.confirmationRequired;
      }
    });
    if (result != null) state = result;
  }
}

/// Forgot-password form. True once the reset link was requested.
@riverpod
class ForgotPasswordController extends _$ForgotPasswordController {
  @override
  FutureOr<bool> build() => false;

  Future<void> sendResetLink(String email) async {
    state = const AsyncLoading();
    final result = await _run(ref, () async {
      await ref.read(authRepositoryProvider).sendPasswordReset(email.trim());
      return true;
    });
    if (result != null) state = result;
  }
}

/// Set-new-password form. Success needs no state: the auth event that
/// follows takes the user out of password recovery.
@riverpod
class ResetPasswordController extends _$ResetPasswordController {
  @override
  FutureOr<void> build() {}

  Future<void> updatePassword(String password) async {
    state = const AsyncLoading();
    final result = await _run(
      ref,
      () => ref.read(authRepositoryProvider).updatePassword(password),
    );
    if (result != null) state = result;
  }
}

/// Sign-out action. Success needs no state: the router reacts.
@riverpod
class SignOutController extends _$SignOutController {
  @override
  FutureOr<void> build() {}

  Future<void> signOut() async {
    state = const AsyncLoading();
    final result = await _run(
      ref,
      () => ref.read(authRepositoryProvider).signOut(),
    );
    if (result != null) state = result;
  }
}

/// Message to show for a failed [AsyncValue], or null.
String? errorMessage(AsyncValue<Object?> value) => switch (value) {
  AsyncError(:final error) => switch (error) {
    AppError(:final message) => message,
    _ => const UnexpectedError().message,
  },
  _ => null,
};

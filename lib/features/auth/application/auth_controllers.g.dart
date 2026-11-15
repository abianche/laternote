// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controllers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sign-in form. Success needs no state: the router reacts to the new
/// session.

@ProviderFor(SignInController)
final signInControllerProvider = SignInControllerProvider._();

/// Sign-in form. Success needs no state: the router reacts to the new
/// session.
final class SignInControllerProvider
    extends $AsyncNotifierProvider<SignInController, void> {
  /// Sign-in form. Success needs no state: the router reacts to the new
  /// session.
  SignInControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signInControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signInControllerHash();

  @$internal
  @override
  SignInController create() => SignInController();
}

String _$signInControllerHash() => r'6046f5fb039d7830402d3e4283d10dfdb21094fa';

/// Sign-in form. Success needs no state: the router reacts to the new
/// session.

abstract class _$SignInController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sign-up form. Holds the outcome once submitted, null before.

@ProviderFor(SignUpController)
final signUpControllerProvider = SignUpControllerProvider._();

/// Sign-up form. Holds the outcome once submitted, null before.
final class SignUpControllerProvider
    extends $AsyncNotifierProvider<SignUpController, SignUpOutcome?> {
  /// Sign-up form. Holds the outcome once submitted, null before.
  SignUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpControllerHash();

  @$internal
  @override
  SignUpController create() => SignUpController();
}

String _$signUpControllerHash() => r'63949a51653fbece3befd4adf4a377b42c2da384';

/// Sign-up form. Holds the outcome once submitted, null before.

abstract class _$SignUpController extends $AsyncNotifier<SignUpOutcome?> {
  FutureOr<SignUpOutcome?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SignUpOutcome?>, SignUpOutcome?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SignUpOutcome?>, SignUpOutcome?>,
              AsyncValue<SignUpOutcome?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Forgot-password form. True once the reset link was requested.

@ProviderFor(ForgotPasswordController)
final forgotPasswordControllerProvider = ForgotPasswordControllerProvider._();

/// Forgot-password form. True once the reset link was requested.
final class ForgotPasswordControllerProvider
    extends $AsyncNotifierProvider<ForgotPasswordController, bool> {
  /// Forgot-password form. True once the reset link was requested.
  ForgotPasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forgotPasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forgotPasswordControllerHash();

  @$internal
  @override
  ForgotPasswordController create() => ForgotPasswordController();
}

String _$forgotPasswordControllerHash() =>
    r'ea049eb8ad923df1438b389a988d486cd43bb043';

/// Forgot-password form. True once the reset link was requested.

abstract class _$ForgotPasswordController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Set-new-password form. Success needs no state: the auth event that
/// follows takes the user out of password recovery.

@ProviderFor(ResetPasswordController)
final resetPasswordControllerProvider = ResetPasswordControllerProvider._();

/// Set-new-password form. Success needs no state: the auth event that
/// follows takes the user out of password recovery.
final class ResetPasswordControllerProvider
    extends $AsyncNotifierProvider<ResetPasswordController, void> {
  /// Set-new-password form. Success needs no state: the auth event that
  /// follows takes the user out of password recovery.
  ResetPasswordControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetPasswordControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetPasswordControllerHash();

  @$internal
  @override
  ResetPasswordController create() => ResetPasswordController();
}

String _$resetPasswordControllerHash() =>
    r'417d041284ce61744c620d93fa7e1301d5f31037';

/// Set-new-password form. Success needs no state: the auth event that
/// follows takes the user out of password recovery.

abstract class _$ResetPasswordController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sign-out action. Success needs no state: the router reacts.

@ProviderFor(SignOutController)
final signOutControllerProvider = SignOutControllerProvider._();

/// Sign-out action. Success needs no state: the router reacts.
final class SignOutControllerProvider
    extends $AsyncNotifierProvider<SignOutController, void> {
  /// Sign-out action. Success needs no state: the router reacts.
  SignOutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutControllerHash();

  @$internal
  @override
  SignOutController create() => SignOutController();
}

String _$signOutControllerHash() => r'd134bff4faf3c597c7fb1bed663b108b6726d0ff';

/// Sign-out action. Success needs no state: the router reacts.

abstract class _$SignOutController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

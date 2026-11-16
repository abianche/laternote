import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/core/error_message.dart';
import 'package:laternote/features/auth/application/auth_controllers.dart';
import 'package:laternote/features/auth/data/auth_repository.dart';
import 'package:laternote/features/auth/data/auth_status.dart';

import '../fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('sign-in trims the email and succeeds', () async {
    container.listen(signInControllerProvider, (_, _) {});
    await container
        .read(signInControllerProvider.notifier)
        .signIn(email: ' a@b.co ', password: 'secret123');

    expect(repository.calls, ['signIn:a@b.co:secret123']);
    expect(container.read(signInControllerProvider), isA<AsyncData<void>>());
  });

  test('sign-in failure surfaces the app error message', () async {
    repository.error = const AuthError('Invalid login credentials');
    container.listen(signInControllerProvider, (_, _) {});
    await container
        .read(signInControllerProvider.notifier)
        .signIn(email: 'a@b.co', password: 'wrong-pass');

    expect(
      errorMessage(container.read(signInControllerProvider)),
      'Invalid login credentials',
    );
  });

  test('sign-up reports confirmation for an existing account', () async {
    repository.error = const AccountAlreadyExistsError();
    container.listen(signUpControllerProvider, (_, _) {});
    await container
        .read(signUpControllerProvider.notifier)
        .signUp(email: 'a@b.co', password: 'secret123');

    expect(
      container.read(signUpControllerProvider).value,
      SignUpOutcome.confirmationRequired,
    );
  });

  test('sign-up passes through a signed-in outcome', () async {
    repository.signUpOutcome = SignUpOutcome.signedIn;
    container.listen(signUpControllerProvider, (_, _) {});
    await container
        .read(signUpControllerProvider.notifier)
        .signUp(email: 'a@b.co', password: 'secret123');

    expect(
      container.read(signUpControllerProvider).value,
      SignUpOutcome.signedIn,
    );
  });

  test('forgot-password marks the link as sent', () async {
    container.listen(forgotPasswordControllerProvider, (_, _) {});
    await container
        .read(forgotPasswordControllerProvider.notifier)
        .sendResetLink(' a@b.co ');

    expect(repository.calls, ['sendPasswordReset:a@b.co']);
    expect(container.read(forgotPasswordControllerProvider).value, isTrue);
  });
}

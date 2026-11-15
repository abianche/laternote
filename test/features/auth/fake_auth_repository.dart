import 'package:laternote/features/auth/data/auth_repository.dart';
import 'package:laternote/features/auth/data/auth_status.dart';

/// In-memory [AuthRepository]: each call records its arguments and throws
/// [error] when set.
class FakeAuthRepository implements AuthRepository {
  Object? error;
  SignUpOutcome signUpOutcome = SignUpOutcome.confirmationRequired;
  final calls = <String>[];

  @override
  AuthStatus get currentStatus => const SignedOut();

  @override
  Stream<AuthStatus> get statusChanges => const Stream.empty();

  Future<void> _record(String call) async {
    calls.add(call);
    if (error case final error?) throw error;
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _record('signIn:$email:$password');

  @override
  Future<SignUpOutcome> signUp({
    required String email,
    required String password,
  }) async {
    await _record('signUp:$email:$password');
    return signUpOutcome;
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _record('sendPasswordReset:$email');

  @override
  Future<void> updatePassword(String password) =>
      _record('updatePassword:$password');

  @override
  Future<void> signOut() => _record('signOut');
}

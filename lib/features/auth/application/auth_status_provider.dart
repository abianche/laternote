import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/auth_repository.dart';
import '../data/auth_status.dart';

part 'auth_status_provider.g.dart';

/// The current [AuthStatus], starting from the stored session.
@Riverpod(keepAlive: true)
Stream<AuthStatus> authStatus(Ref ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield repository.currentStatus;
  yield* repository.statusChanges;
}

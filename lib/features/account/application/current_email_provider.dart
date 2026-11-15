import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_status_provider.dart';
import '../../auth/data/auth_status.dart';

part 'current_email_provider.g.dart';

/// Email of the signed-in user, or null.
@riverpod
Future<String?> currentEmail(Ref ref) async => switch (await ref.watch(
  authStatusProvider.future,
)) {
  SignedIn(:final email) => email,
  _ => null,
};

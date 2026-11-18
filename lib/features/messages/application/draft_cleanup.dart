import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../auth/application/auth_status_provider.dart';
import '../../auth/data/auth_status.dart';
import '../data/draft_repository.dart';

part 'draft_cleanup.g.dart';

/// Deletes the local draft whenever there is no session, however it ended
/// (sign-out, expiry, revoked refresh token), so a draft never outlives it.
@Riverpod(keepAlive: true)
void draftCleanup(Ref ref) {
  ref.listen(authStatusProvider, (_, next) {
    if (next case AsyncData(value: SignedOut())) {
      // Best effort: a draft that survives is still deleted when another
      // account opens Compose.
      ref.read(draftRepositoryProvider).clear().ignore();
    }
  }, fireImmediately: true);
}

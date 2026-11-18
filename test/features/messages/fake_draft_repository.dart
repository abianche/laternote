import 'package:laternote/features/messages/data/draft_repository.dart';

/// In-memory [DraftRepository] holding a single [stored] draft.
class FakeDraftRepository implements DraftRepository {
  StoredDraft? stored;
  int saves = 0;

  @override
  Future<StoredDraft?> load() async => stored;

  @override
  Future<void> save(StoredDraft draft) async {
    saves++;
    stored = draft;
  }

  @override
  Future<void> clear() async => stored = null;
}

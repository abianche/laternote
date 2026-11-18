import 'package:laternote/features/messages/data/draft_repository.dart';

/// In-memory [DraftRepository] holding a single [stored] draft. Saving or
/// clearing throws [saveError] / [clearError] when set.
class FakeDraftRepository implements DraftRepository {
  StoredDraft? stored;
  int saves = 0;
  int clears = 0;
  Object? saveError;
  Object? clearError;

  @override
  Future<StoredDraft?> load() async => stored;

  @override
  Future<void> save(StoredDraft draft) async {
    saves++;
    if (saveError case final error?) throw error;
    stored = draft;
  }

  @override
  Future<void> clear() async {
    clears++;
    if (clearError case final error?) throw error;
    stored = null;
  }
}

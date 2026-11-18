import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/features/auth/application/auth_status_provider.dart';
import 'package:laternote/features/auth/data/auth_status.dart';
import 'package:laternote/features/messages/application/draft_cleanup.dart';
import 'package:laternote/features/messages/data/draft_repository.dart';

import '../fake_draft_repository.dart';

void main() {
  late StreamController<AuthStatus> statuses;
  late FakeDraftRepository drafts;

  setUp(() {
    statuses = StreamController<AuthStatus>();
    drafts = FakeDraftRepository()..stored = (body: 'Secret', deliverAt: null);
    final container = ProviderContainer.test(
      overrides: [
        authStatusProvider.overrideWith((_) => statuses.stream),
        draftRepositoryProvider.overrideWithValue(drafts),
      ],
    );
    container.listen(draftCleanupProvider, (_, _) {});
  });

  tearDown(() => statuses.close());

  Future<void> emit(AuthStatus status) async {
    statuses.add(status);
    await Future<void>.delayed(Duration.zero);
  }

  test('keeps the draft while signed in', () async {
    await emit(const SignedIn(email: 'a@b.co'));

    expect(drafts.stored, isNotNull);
  });

  test('deletes the draft when the session ends for any reason', () async {
    await emit(const SignedIn(email: 'a@b.co'));
    await emit(const SignedOut());

    expect(drafts.stored, isNull);
  });

  test('deletes the draft when the app starts signed out', () async {
    await emit(const SignedOut());

    expect(drafts.stored, isNull);
  });
}

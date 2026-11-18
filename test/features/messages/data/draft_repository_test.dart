import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/data/draft_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late String? userId;

  DraftRepository repository() =>
      DraftRepository(SharedPreferencesAsync(), () => userId);

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    userId = 'user-a';
  });

  test('loads nothing before a save', () async {
    expect(await repository().load(), isNull);
  });

  test('round-trips body and local delivery time', () async {
    final at = DateTime(2030, 6, 1, 9, 30);
    await repository().save((body: 'Dear me', deliverAt: at));

    final draft = await repository().load();
    expect(draft, (body: 'Dear me', deliverAt: at));
    expect(draft!.deliverAt!.isUtc, isFalse);
  });

  test('round-trips a draft without a delivery time', () async {
    await repository().save((body: 'Hi', deliverAt: null));

    expect(await repository().load(), (body: 'Hi', deliverAt: null));
  });

  test('clear deletes the draft', () async {
    await repository().save((body: 'Hi', deliverAt: null));
    await repository().clear();

    expect(await repository().load(), isNull);
  });

  test("another account's draft is deleted, not shown", () async {
    await repository().save((body: 'Private', deliverAt: null));

    userId = 'user-b';
    expect(await repository().load(), isNull);

    userId = 'user-a';
    expect(await repository().load(), isNull);
  });

  test('saving while signed out fails', () async {
    userId = null;

    expect(
      () => repository().save((body: 'Hi', deliverAt: null)),
      throwsA(isA<AuthError>()),
    );
  });
}

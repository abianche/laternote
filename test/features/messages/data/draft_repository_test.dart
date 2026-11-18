import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laternote/core/app_error.dart';
import 'package:laternote/features/messages/data/draft_repository.dart';

void main() {
  late String? userId;

  DraftRepository repository() =>
      DraftRepository(const FlutterSecureStorage(), () => userId);

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
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

  for (final (name, raw) in [
    ('invalid JSON', '{not json'),
    ('a missing body', '{"user_id":"user-a"}'),
    (
      'a bad delivery time',
      '{"user_id":"user-a","body":"Hi","deliver_at":"x"}',
    ),
  ]) {
    test('a draft with $name is deleted, not thrown', () async {
      FlutterSecureStorage.setMockInitialValues({'compose_draft': raw});

      expect(await repository().load(), isNull);
      expect(
        await const FlutterSecureStorage().read(key: 'compose_draft'),
        isNull,
      );
    });
  }

  test('saving while signed out fails', () async {
    userId = null;

    expect(
      () => repository().save((body: 'Hi', deliverAt: null)),
      throwsA(isA<AuthError>()),
    );
  });

  test('a draft that storage fails to read is deleted, not thrown', () async {
    final storage = _UnreadableStorage();
    final repository = DraftRepository(storage, () => userId);

    expect(await repository.load(), isNull);
    expect(storage.deleted, isTrue);
  });
}

/// Storage whose reads fail, as when the platform can't decrypt them.
class _UnreadableStorage implements FlutterSecureStorage {
  bool deleted = false;

  @override
  Future<String?> read({
    required String key,
    Object? iOptions,
    Object? aOptions,
    Object? lOptions,
    Object? webOptions,
    Object? mOptions,
    Object? wOptions,
  }) => Future.error(Exception('decryption failed'));

  @override
  Future<void> delete({
    required String key,
    Object? iOptions,
    Object? aOptions,
    Object? lOptions,
    Object? webOptions,
    Object? mOptions,
    Object? wOptions,
  }) async => deleted = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/app_error.dart';
import '../../../core/clock.dart';
import '../../../core/database.dart';
import 'available_message.dart';
import 'scheduled_message.dart';

part 'messages_repository.g.dart';

/// The only place that touches sealed letters. A letter is ready once its
/// time has passed on the device clock; before that only its metadata is
/// read. Every failure is rethrown as an [AppError].
class MessagesRepository {
  MessagesRepository(this._db, this._now, this._newId);

  final AppDatabase _db;
  final DateTime Function() _now;
  final String Function() _newId;

  $LettersTable get _letters => _db.letters;

  /// Seals a letter. Its body and time can't be changed afterwards.
  Future<void> createScheduledMessage({
    required String body,
    required DateTime scheduledFor,
    required String timezone,
  }) => _guard(() async {
    final now = _now();
    if (!scheduledFor.isAfter(now)) {
      throw const ValidationError(ValidationProblem.deliveryInPast);
    }
    await _db
        .into(_letters)
        .insert(
          LettersCompanion.insert(
            id: _newId(),
            body: body,
            scheduledFor: scheduledFor,
            timezone: timezone,
            createdAt: now,
          ),
        );
  });

  /// Deletes letter [id] while it is not ready yet; otherwise nothing is
  /// deleted and this throws a [ValidationError].
  Future<void> deleteScheduledMessage(String id) => _guard(() async {
    final deleted = await (_db.delete(
      _letters,
    )..where((l) => l.id.equals(id) & _notReady(l))).go();
    if (deleted == 0) {
      throw const ValidationError(ValidationProblem.alreadyOpening);
    }
  });

  /// Letters not ready yet, soonest first. Metadata only.
  Future<List<ScheduledMessage>> listUpcoming() => _guard(() async {
    final l = _letters;
    final query = _db.selectOnly(l)
      ..addColumns([l.id, l.scheduledFor, l.timezone, l.createdAt])
      ..where(_notReady(l))
      ..orderBy([OrderingTerm.asc(l.scheduledFor)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        ScheduledMessage(
          id: row.read(l.id)!,
          scheduledFor: row.read(l.scheduledFor)!.toLocal(),
          timezone: row.read(l.timezone)!,
          createdAt: row.read(l.createdAt)!.toLocal(),
        ),
    ];
  });

  /// Ready letters, newest first. Metadata only.
  Future<List<InboxItem>> listAvailable() => _guard(() async {
    final l = _letters;
    final query = _db.selectOnly(l)
      ..addColumns([l.id, l.createdAt, l.scheduledFor, l.openedAt])
      ..where(_ready(l))
      ..orderBy([OrderingTerm.desc(l.scheduledFor)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        InboxItem(
          id: row.read(l.id)!,
          createdAt: row.read(l.createdAt)!.toLocal(),
          scheduledFor: row.read(l.scheduledFor)!.toLocal(),
          openedAt: row.read(l.openedAt)?.toLocal(),
        ),
    ];
  });

  /// Ready letter [id] with its content, or null if it doesn't exist or
  /// isn't ready yet.
  Future<AvailableMessage?> getAvailable(String id) => _guard(() async {
    final row = await (_db.select(
      _letters,
    )..where((l) => l.id.equals(id) & _ready(l))).getSingleOrNull();
    if (row == null) return null;
    return AvailableMessage(
      id: row.id,
      body: row.body,
      scheduledFor: row.scheduledFor.toLocal(),
      timezone: row.timezone,
      createdAt: row.createdAt.toLocal(),
      openedAt: row.openedAt?.toLocal(),
    );
  });

  /// Records the first time ready letter [id] was opened. Repeats and
  /// letters that aren't ready are ignored.
  Future<void> markOpened(String id) => _guard(() async {
    await (_db.update(_letters)..where(
          (l) => l.id.equals(id) & l.openedAt.isNull() & _ready(l),
        ))
        .write(LettersCompanion(openedAt: Value(_now())));
  });

  /// Every letter with its content, oldest first, for export.
  Future<List<LetterRow>> exportAll() => _guard(
    () => (_db.select(
      _letters,
    )..orderBy([(l) => OrderingTerm.asc(l.createdAt)])).get(),
  );

  /// Adds [letters] whose ID isn't stored yet and returns how many were
  /// added. All or nothing: a failure adds none.
  Future<int> importLetters(List<LetterRow> letters) => _guard(
    () => _db.transaction(() async {
      final before = await _count();
      await _db.batch(
        (b) => b.insertAll(_letters, letters, mode: InsertMode.insertOrIgnore),
      );
      return await _count() - before;
    }),
  );

  Future<int> _count() =>
      (_db.selectOnly(_letters)..addColumns([_letters.id.count()]))
          .map((row) => row.read(_letters.id.count())!)
          .getSingle();

  Expression<bool> _ready($LettersTable l) =>
      l.scheduledFor.isSmallerOrEqualValue(_now());

  Expression<bool> _notReady($LettersTable l) =>
      l.scheduledFor.isBiggerThanValue(_now());

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppError {
      rethrow;
    } on Exception {
      // drift and sqlite3 failures; the app has no other storage errors.
      throw const UnexpectedError();
    }
  }
}

@Riverpod(keepAlive: true)
MessagesRepository messagesRepository(Ref ref) => MessagesRepository(
  ref.watch(appDatabaseProvider),
  ref.watch(clockProvider),
  const Uuid().v4,
);

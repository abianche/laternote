import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'tables.dart';

part 'database.g.dart';

/// Sealed letters. A letter is ready once [scheduledFor] has passed on the
/// device clock; there is no stored status.
@DataClassName('LetterRow')
class Letters extends Table {
  TextColumn get id => text()();
  TextColumn get body => text().check(
    body.length.isBetweenValues(1, maxMessageLength),
  )();

  /// Opening instant. drift stores it as a Unix timestamp, so it is UTC.
  DateTimeColumn get scheduledFor => dateTime()();

  /// IANA zone on the device when the letter was written.
  TextColumn get timezone => text()();
  DateTimeColumn get createdAt => dateTime()();

  /// First time the letter was read; null while it's new.
  DateTimeColumn get openedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Letters])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}

/// The letters database in the app's documents directory, which the OS
/// includes in device backups.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase(driftDatabase(name: 'laternote'));
  ref.onDispose(db.close);
  return db;
}

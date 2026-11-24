// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $LettersTable extends Letters with TableInfo<$LettersTable, LetterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LettersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    check: () =>
        ComparableExpr(body.length).isBetweenValues(1, maxMessageLength),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    body,
    scheduledFor,
    timezone,
    createdAt,
    openedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'letters';
  @override
  VerificationContext validateIntegrity(
    Insertable<LetterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    } else if (isInserting) {
      context.missing(_timezoneMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LetterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LetterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
    );
  }

  @override
  $LettersTable createAlias(String alias) {
    return $LettersTable(attachedDatabase, alias);
  }
}

class LetterRow extends DataClass implements Insertable<LetterRow> {
  final String id;
  final String body;

  /// Opening instant. drift stores it as a Unix timestamp, so it is UTC.
  final DateTime scheduledFor;

  /// IANA zone on the device when the letter was written.
  final String timezone;
  final DateTime createdAt;

  /// First time the letter was read; null while it's new.
  final DateTime? openedAt;
  const LetterRow({
    required this.id,
    required this.body,
    required this.scheduledFor,
    required this.timezone,
    required this.createdAt,
    this.openedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['body'] = Variable<String>(body);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    map['timezone'] = Variable<String>(timezone);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    return map;
  }

  LettersCompanion toCompanion(bool nullToAbsent) {
    return LettersCompanion(
      id: Value(id),
      body: Value(body),
      scheduledFor: Value(scheduledFor),
      timezone: Value(timezone),
      createdAt: Value(createdAt),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
    );
  }

  factory LetterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LetterRow(
      id: serializer.fromJson<String>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      timezone: serializer.fromJson<String>(json['timezone']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'body': serializer.toJson<String>(body),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'timezone': serializer.toJson<String>(timezone),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
    };
  }

  LetterRow copyWith({
    String? id,
    String? body,
    DateTime? scheduledFor,
    String? timezone,
    DateTime? createdAt,
    Value<DateTime?> openedAt = const Value.absent(),
  }) => LetterRow(
    id: id ?? this.id,
    body: body ?? this.body,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    timezone: timezone ?? this.timezone,
    createdAt: createdAt ?? this.createdAt,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
  );
  LetterRow copyWithCompanion(LettersCompanion data) {
    return LetterRow(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LetterRow(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('openedAt: $openedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, body, scheduledFor, timezone, createdAt, openedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LetterRow &&
          other.id == this.id &&
          other.body == this.body &&
          other.scheduledFor == this.scheduledFor &&
          other.timezone == this.timezone &&
          other.createdAt == this.createdAt &&
          other.openedAt == this.openedAt);
}

class LettersCompanion extends UpdateCompanion<LetterRow> {
  final Value<String> id;
  final Value<String> body;
  final Value<DateTime> scheduledFor;
  final Value<String> timezone;
  final Value<DateTime> createdAt;
  final Value<DateTime?> openedAt;
  final Value<int> rowid;
  const LettersCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.timezone = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LettersCompanion.insert({
    required String id,
    required String body,
    required DateTime scheduledFor,
    required String timezone,
    required DateTime createdAt,
    this.openedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       body = Value(body),
       scheduledFor = Value(scheduledFor),
       timezone = Value(timezone),
       createdAt = Value(createdAt);
  static Insertable<LetterRow> custom({
    Expression<String>? id,
    Expression<String>? body,
    Expression<DateTime>? scheduledFor,
    Expression<String>? timezone,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? openedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'body': body,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (timezone != null) 'timezone': timezone,
      if (createdAt != null) 'created_at': createdAt,
      if (openedAt != null) 'opened_at': openedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LettersCompanion copyWith({
    Value<String>? id,
    Value<String>? body,
    Value<DateTime>? scheduledFor,
    Value<String>? timezone,
    Value<DateTime>? createdAt,
    Value<DateTime?>? openedAt,
    Value<int>? rowid,
  }) {
    return LettersCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      openedAt: openedAt ?? this.openedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LettersCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('timezone: $timezone, ')
          ..write('createdAt: $createdAt, ')
          ..write('openedAt: $openedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LettersTable letters = $LettersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [letters];
}

typedef $$LettersTableCreateCompanionBuilder = LettersCompanion Function({
  required String id,
  required String body,
  required DateTime scheduledFor,
  required String timezone,
  required DateTime createdAt,
  Value<DateTime?> openedAt,
  Value<int> rowid,
});
typedef $$LettersTableUpdateCompanionBuilder = LettersCompanion Function({
  Value<String> id,
  Value<String> body,
  Value<DateTime> scheduledFor,
  Value<String> timezone,
  Value<DateTime> createdAt,
  Value<DateTime?> openedAt,
  Value<int> rowid,
});

class $$LettersTableFilterComposer
    extends Composer<_$AppDatabase, $LettersTable> {
  $$LettersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LettersTableOrderingComposer
    extends Composer<_$AppDatabase, $LettersTable> {
  $$LettersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LettersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LettersTable> {
  $$LettersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);
}

class $$LettersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LettersTable,
          LetterRow,
          $$LettersTableFilterComposer,
          $$LettersTableOrderingComposer,
          $$LettersTableAnnotationComposer,
          $$LettersTableCreateCompanionBuilder,
          $$LettersTableUpdateCompanionBuilder,
          (LetterRow, BaseReferences<_$AppDatabase, $LettersTable, LetterRow>),
          LetterRow,
          PrefetchHooks Function()
        > {
  $$LettersTableTableManager(_$AppDatabase db, $LettersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LettersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LettersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LettersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LettersCompanion(
                id: id,
                body: body,
                scheduledFor: scheduledFor,
                timezone: timezone,
                createdAt: createdAt,
                openedAt: openedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String body,
                required DateTime scheduledFor,
                required String timezone,
                required DateTime createdAt,
                Value<DateTime?> openedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LettersCompanion.insert(
                id: id,
                body: body,
                scheduledFor: scheduledFor,
                timezone: timezone,
                createdAt: createdAt,
                openedAt: openedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LettersTable, LetterRow>(table),
                  BaseReferences<_$AppDatabase, $LettersTable, LetterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LettersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LettersTable,
      LetterRow,
      $$LettersTableFilterComposer,
      $$LettersTableOrderingComposer,
      $$LettersTableAnnotationComposer,
      $$LettersTableCreateCompanionBuilder,
      $$LettersTableUpdateCompanionBuilder,
      (LetterRow, BaseReferences<_$AppDatabase, $LettersTable, LetterRow>),
      LetterRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LettersTableTableManager get letters =>
      $$LettersTableTableManager(_db, _db.letters);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The letters database in the app's documents directory, which the OS
/// includes in device backups.

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The letters database in the app's documents directory, which the OS
/// includes in device backups.

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The letters database in the app's documents directory, which the OS
  /// includes in device backups.
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'04bcb139ba7284d605778a41fa0554beee20b2ac';

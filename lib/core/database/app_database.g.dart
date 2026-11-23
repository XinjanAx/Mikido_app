// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MesasTable extends Mesas with TableInfo<$MesasTable, Mesa> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MesasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, description, createdBy, createdAt, dirty, deletedLocally];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mesas';
  @override
  VerificationContext validateIntegrity(Insertable<Mesa> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mesa map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mesa(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally'])!,
    );
  }

  @override
  $MesasTable createAlias(String alias) {
    return $MesasTable(attachedDatabase, alias);
  }
}

class Mesa extends DataClass implements Insertable<Mesa> {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime? createdAt;

  /// true = hay cambios locales que aún no se subieron a Supabase.
  final bool dirty;

  /// Tombstone: se borró localmente pero aún no se confirmó el borrado remoto.
  final bool deletedLocally;
  const Mesa(
      {required this.id,
      required this.name,
      this.description,
      required this.createdBy,
      this.createdAt,
      required this.dirty,
      required this.deletedLocally});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['deleted_locally'] = Variable<bool>(deletedLocally);
    return map;
  }

  MesasCompanion toCompanion(bool nullToAbsent) {
    return MesasCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdBy: Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      dirty: Value(dirty),
      deletedLocally: Value(deletedLocally),
    );
  }

  factory Mesa.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mesa(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedLocally: serializer.fromJson<bool>(json['deletedLocally']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedLocally': serializer.toJson<bool>(deletedLocally),
    };
  }

  Mesa copyWith(
          {String? id,
          String? name,
          Value<String?> description = const Value.absent(),
          String? createdBy,
          Value<DateTime?> createdAt = const Value.absent(),
          bool? dirty,
          bool? deletedLocally}) =>
      Mesa(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        dirty: dirty ?? this.dirty,
        deletedLocally: deletedLocally ?? this.deletedLocally,
      );
  Mesa copyWithCompanion(MesasCompanion data) {
    return Mesa(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mesa(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, description, createdBy, createdAt, dirty, deletedLocally);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mesa &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.dirty == this.dirty &&
          other.deletedLocally == this.deletedLocally);
}

class MesasCompanion extends UpdateCompanion<Mesa> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> createdBy;
  final Value<DateTime?> createdAt;
  final Value<bool> dirty;
  final Value<bool> deletedLocally;
  final Value<int> rowid;
  const MesasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MesasCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required String createdBy,
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdBy = Value(createdBy);
  static Insertable<Mesa> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<bool>? dirty,
    Expression<bool>? deletedLocally,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (dirty != null) 'dirty': dirty,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MesasCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<String>? createdBy,
      Value<DateTime?>? createdAt,
      Value<bool>? dirty,
      Value<bool>? deletedLocally,
      Value<int>? rowid}) {
    return MesasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      dirty: dirty ?? this.dirty,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MesasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TournamentsTable extends Tournaments
    with TableInfo<$TournamentsTable, Tournament> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdByMeta =
      const VerificationMeta('createdBy');
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
      'created_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _mesaIdMeta = const VerificationMeta('mesaId');
  @override
  late final GeneratedColumn<String> mesaId = GeneratedColumn<String>(
      'mesa_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
      'color', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        mode,
        status,
        description,
        startDate,
        endDate,
        createdBy,
        createdAt,
        mesaId,
        color,
        dirty,
        deletedLocally
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournaments';
  @override
  VerificationContext validateIntegrity(Insertable<Tournament> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('created_by')) {
      context.handle(_createdByMeta,
          createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta));
    } else if (isInserting) {
      context.missing(_createdByMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('mesa_id')) {
      context.handle(_mesaIdMeta,
          mesaId.isAcceptableOrUnknown(data['mesa_id']!, _mesaIdMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tournament map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tournament(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date'])!,
      createdBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_by'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      mesaId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mesa_id']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally'])!,
    );
  }

  @override
  $TournamentsTable createAlias(String alias) {
    return $TournamentsTable(attachedDatabase, alias);
  }
}

class Tournament extends DataClass implements Insertable<Tournament> {
  final String id;
  final String name;
  final String mode;
  final String status;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime? createdAt;

  /// Mesa a la que pertenece la categoría (en la UI "torneo" se muestra
  /// como "categoría"). Nullable solo por los datos anteriores a la v6;
  /// toda categoría nueva se crea dentro de una mesa y no cambia de mesa.
  final String? mesaId;

  /// Color de la categoría, '#RRGGBB' (ver CategoryColors). null en datos
  /// anteriores a la v7.
  final String? color;

  /// true = hay cambios locales que aún no se subieron a Supabase.
  final bool dirty;

  /// Tombstone: se borró localmente pero aún no se confirmó el borrado remoto.
  final bool deletedLocally;
  const Tournament(
      {required this.id,
      required this.name,
      required this.mode,
      required this.status,
      this.description,
      required this.startDate,
      required this.endDate,
      required this.createdBy,
      this.createdAt,
      this.mesaId,
      this.color,
      required this.dirty,
      required this.deletedLocally});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['mode'] = Variable<String>(mode);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    map['end_date'] = Variable<DateTime>(endDate);
    map['created_by'] = Variable<String>(createdBy);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || mesaId != null) {
      map['mesa_id'] = Variable<String>(mesaId);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['deleted_locally'] = Variable<bool>(deletedLocally);
    return map;
  }

  TournamentsCompanion toCompanion(bool nullToAbsent) {
    return TournamentsCompanion(
      id: Value(id),
      name: Value(name),
      mode: Value(mode),
      status: Value(status),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      startDate: Value(startDate),
      endDate: Value(endDate),
      createdBy: Value(createdBy),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      mesaId:
          mesaId == null && nullToAbsent ? const Value.absent() : Value(mesaId),
      color:
          color == null && nullToAbsent ? const Value.absent() : Value(color),
      dirty: Value(dirty),
      deletedLocally: Value(deletedLocally),
    );
  }

  factory Tournament.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tournament(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      mode: serializer.fromJson<String>(json['mode']),
      status: serializer.fromJson<String>(json['status']),
      description: serializer.fromJson<String?>(json['description']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      endDate: serializer.fromJson<DateTime>(json['endDate']),
      createdBy: serializer.fromJson<String>(json['createdBy']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      mesaId: serializer.fromJson<String?>(json['mesaId']),
      color: serializer.fromJson<String?>(json['color']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedLocally: serializer.fromJson<bool>(json['deletedLocally']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'mode': serializer.toJson<String>(mode),
      'status': serializer.toJson<String>(status),
      'description': serializer.toJson<String?>(description),
      'startDate': serializer.toJson<DateTime>(startDate),
      'endDate': serializer.toJson<DateTime>(endDate),
      'createdBy': serializer.toJson<String>(createdBy),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'mesaId': serializer.toJson<String?>(mesaId),
      'color': serializer.toJson<String?>(color),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedLocally': serializer.toJson<bool>(deletedLocally),
    };
  }

  Tournament copyWith(
          {String? id,
          String? name,
          String? mode,
          String? status,
          Value<String?> description = const Value.absent(),
          DateTime? startDate,
          DateTime? endDate,
          String? createdBy,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<String?> mesaId = const Value.absent(),
          Value<String?> color = const Value.absent(),
          bool? dirty,
          bool? deletedLocally}) =>
      Tournament(
        id: id ?? this.id,
        name: name ?? this.name,
        mode: mode ?? this.mode,
        status: status ?? this.status,
        description: description.present ? description.value : this.description,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        mesaId: mesaId.present ? mesaId.value : this.mesaId,
        color: color.present ? color.value : this.color,
        dirty: dirty ?? this.dirty,
        deletedLocally: deletedLocally ?? this.deletedLocally,
      );
  Tournament copyWithCompanion(TournamentsCompanion data) {
    return Tournament(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      mode: data.mode.present ? data.mode.value : this.mode,
      status: data.status.present ? data.status.value : this.status,
      description:
          data.description.present ? data.description.value : this.description,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      mesaId: data.mesaId.present ? data.mesaId.value : this.mesaId,
      color: data.color.present ? data.color.value : this.color,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tournament(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('mesaId: $mesaId, ')
          ..write('color: $color, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      mode,
      status,
      description,
      startDate,
      endDate,
      createdBy,
      createdAt,
      mesaId,
      color,
      dirty,
      deletedLocally);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tournament &&
          other.id == this.id &&
          other.name == this.name &&
          other.mode == this.mode &&
          other.status == this.status &&
          other.description == this.description &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.createdBy == this.createdBy &&
          other.createdAt == this.createdAt &&
          other.mesaId == this.mesaId &&
          other.color == this.color &&
          other.dirty == this.dirty &&
          other.deletedLocally == this.deletedLocally);
}

class TournamentsCompanion extends UpdateCompanion<Tournament> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> mode;
  final Value<String> status;
  final Value<String?> description;
  final Value<DateTime> startDate;
  final Value<DateTime> endDate;
  final Value<String> createdBy;
  final Value<DateTime?> createdAt;
  final Value<String?> mesaId;
  final Value<String?> color;
  final Value<bool> dirty;
  final Value<bool> deletedLocally;
  final Value<int> rowid;
  const TournamentsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.mode = const Value.absent(),
    this.status = const Value.absent(),
    this.description = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.color = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TournamentsCompanion.insert({
    required String id,
    required String name,
    required String mode,
    required String status,
    this.description = const Value.absent(),
    required DateTime startDate,
    required DateTime endDate,
    required String createdBy,
    this.createdAt = const Value.absent(),
    this.mesaId = const Value.absent(),
    this.color = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        mode = Value(mode),
        status = Value(status),
        startDate = Value(startDate),
        endDate = Value(endDate),
        createdBy = Value(createdBy);
  static Insertable<Tournament> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? mode,
    Expression<String>? status,
    Expression<String>? description,
    Expression<DateTime>? startDate,
    Expression<DateTime>? endDate,
    Expression<String>? createdBy,
    Expression<DateTime>? createdAt,
    Expression<String>? mesaId,
    Expression<String>? color,
    Expression<bool>? dirty,
    Expression<bool>? deletedLocally,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (mode != null) 'mode': mode,
      if (status != null) 'status': status,
      if (description != null) 'description': description,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (createdBy != null) 'created_by': createdBy,
      if (createdAt != null) 'created_at': createdAt,
      if (mesaId != null) 'mesa_id': mesaId,
      if (color != null) 'color': color,
      if (dirty != null) 'dirty': dirty,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TournamentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? mode,
      Value<String>? status,
      Value<String?>? description,
      Value<DateTime>? startDate,
      Value<DateTime>? endDate,
      Value<String>? createdBy,
      Value<DateTime?>? createdAt,
      Value<String?>? mesaId,
      Value<String?>? color,
      Value<bool>? dirty,
      Value<bool>? deletedLocally,
      Value<int>? rowid}) {
    return TournamentsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      mesaId: mesaId ?? this.mesaId,
      color: color ?? this.color,
      dirty: dirty ?? this.dirty,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (mesaId.present) {
      map['mesa_id'] = Variable<String>(mesaId.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('mode: $mode, ')
          ..write('status: $status, ')
          ..write('description: $description, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('createdBy: $createdBy, ')
          ..write('createdAt: $createdAt, ')
          ..write('mesaId: $mesaId, ')
          ..write('color: $color, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _photoUrlMeta =
      const VerificationMeta('photoUrl');
  @override
  late final GeneratedColumn<String> photoUrl = GeneratedColumn<String>(
      'photo_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        email,
        phone,
        birthDate,
        photoUrl,
        createdAt,
        dirty,
        deletedLocally
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(Insertable<Player> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('photo_url')) {
      context.handle(_photoUrlMeta,
          photoUrl.isAcceptableOrUnknown(data['photo_url']!, _photoUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email']),
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      photoUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}photo_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally'])!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String id;
  final String name;
  final String? email;
  final String? phone;
  final DateTime? birthDate;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool dirty;
  final bool deletedLocally;
  const Player(
      {required this.id,
      required this.name,
      this.email,
      this.phone,
      this.birthDate,
      this.photoUrl,
      this.createdAt,
      required this.dirty,
      required this.deletedLocally});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || photoUrl != null) {
      map['photo_url'] = Variable<String>(photoUrl);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['deleted_locally'] = Variable<bool>(deletedLocally);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      name: Value(name),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      photoUrl: photoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(photoUrl),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      dirty: Value(dirty),
      deletedLocally: Value(deletedLocally),
    );
  }

  factory Player.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String?>(json['email']),
      phone: serializer.fromJson<String?>(json['phone']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      photoUrl: serializer.fromJson<String?>(json['photoUrl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedLocally: serializer.fromJson<bool>(json['deletedLocally']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String?>(email),
      'phone': serializer.toJson<String?>(phone),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'photoUrl': serializer.toJson<String?>(photoUrl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedLocally': serializer.toJson<bool>(deletedLocally),
    };
  }

  Player copyWith(
          {String? id,
          String? name,
          Value<String?> email = const Value.absent(),
          Value<String?> phone = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<String?> photoUrl = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? dirty,
          bool? deletedLocally}) =>
      Player(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email.present ? email.value : this.email,
        phone: phone.present ? phone.value : this.phone,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        photoUrl: photoUrl.present ? photoUrl.value : this.photoUrl,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        dirty: dirty ?? this.dirty,
        deletedLocally: deletedLocally ?? this.deletedLocally,
      );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      phone: data.phone.present ? data.phone.value : this.phone,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      photoUrl: data.photoUrl.present ? data.photoUrl.value : this.photoUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, phone, birthDate, photoUrl,
      createdAt, dirty, deletedLocally);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.phone == this.phone &&
          other.birthDate == this.birthDate &&
          other.photoUrl == this.photoUrl &&
          other.createdAt == this.createdAt &&
          other.dirty == this.dirty &&
          other.deletedLocally == this.deletedLocally);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> email;
  final Value<String?> phone;
  final Value<DateTime?> birthDate;
  final Value<String?> photoUrl;
  final Value<DateTime?> createdAt;
  final Value<bool> dirty;
  final Value<bool> deletedLocally;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required String name,
    this.email = const Value.absent(),
    this.phone = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.photoUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Player> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? phone,
    Expression<DateTime>? birthDate,
    Expression<String>? photoUrl,
    Expression<DateTime>? createdAt,
    Expression<bool>? dirty,
    Expression<bool>? deletedLocally,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (birthDate != null) 'birth_date': birthDate,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (dirty != null) 'dirty': dirty,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? email,
      Value<String?>? phone,
      Value<DateTime?>? birthDate,
      Value<String?>? photoUrl,
      Value<DateTime?>? createdAt,
      Value<bool>? dirty,
      Value<bool>? deletedLocally,
      Value<int>? rowid}) {
    return PlayersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      dirty: dirty ?? this.dirty,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (photoUrl.present) {
      map['photo_url'] = Variable<String>(photoUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('phone: $phone, ')
          ..write('birthDate: $birthDate, ')
          ..write('photoUrl: $photoUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnrollmentsTable extends Enrollments
    with TableInfo<$EnrollmentsTable, Enrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnrollmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tournamentIdMeta =
      const VerificationMeta('tournamentId');
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
      'tournament_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, tournamentId, playerId, dirty, deletedLocally];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrollments';
  @override
  VerificationContext validateIntegrity(Insertable<Enrollment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
          _tournamentIdMeta,
          tournamentId.isAcceptableOrUnknown(
              data['tournament_id']!, _tournamentIdMeta));
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Enrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Enrollment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tournamentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tournament_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally'])!,
    );
  }

  @override
  $EnrollmentsTable createAlias(String alias) {
    return $EnrollmentsTable(attachedDatabase, alias);
  }
}

class Enrollment extends DataClass implements Insertable<Enrollment> {
  final String id;
  final String tournamentId;
  final String playerId;
  final bool dirty;
  final bool deletedLocally;
  const Enrollment(
      {required this.id,
      required this.tournamentId,
      required this.playerId,
      required this.dirty,
      required this.deletedLocally});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tournament_id'] = Variable<String>(tournamentId);
    map['player_id'] = Variable<String>(playerId);
    map['dirty'] = Variable<bool>(dirty);
    map['deleted_locally'] = Variable<bool>(deletedLocally);
    return map;
  }

  EnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrollmentsCompanion(
      id: Value(id),
      tournamentId: Value(tournamentId),
      playerId: Value(playerId),
      dirty: Value(dirty),
      deletedLocally: Value(deletedLocally),
    );
  }

  factory Enrollment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Enrollment(
      id: serializer.fromJson<String>(json['id']),
      tournamentId: serializer.fromJson<String>(json['tournamentId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedLocally: serializer.fromJson<bool>(json['deletedLocally']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tournamentId': serializer.toJson<String>(tournamentId),
      'playerId': serializer.toJson<String>(playerId),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedLocally': serializer.toJson<bool>(deletedLocally),
    };
  }

  Enrollment copyWith(
          {String? id,
          String? tournamentId,
          String? playerId,
          bool? dirty,
          bool? deletedLocally}) =>
      Enrollment(
        id: id ?? this.id,
        tournamentId: tournamentId ?? this.tournamentId,
        playerId: playerId ?? this.playerId,
        dirty: dirty ?? this.dirty,
        deletedLocally: deletedLocally ?? this.deletedLocally,
      );
  Enrollment copyWithCompanion(EnrollmentsCompanion data) {
    return Enrollment(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Enrollment(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('playerId: $playerId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, tournamentId, playerId, dirty, deletedLocally);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Enrollment &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.playerId == this.playerId &&
          other.dirty == this.dirty &&
          other.deletedLocally == this.deletedLocally);
}

class EnrollmentsCompanion extends UpdateCompanion<Enrollment> {
  final Value<String> id;
  final Value<String> tournamentId;
  final Value<String> playerId;
  final Value<bool> dirty;
  final Value<bool> deletedLocally;
  final Value<int> rowid;
  const EnrollmentsCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnrollmentsCompanion.insert({
    required String id,
    required String tournamentId,
    required String playerId,
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tournamentId = Value(tournamentId),
        playerId = Value(playerId);
  static Insertable<Enrollment> custom({
    Expression<String>? id,
    Expression<String>? tournamentId,
    Expression<String>? playerId,
    Expression<bool>? dirty,
    Expression<bool>? deletedLocally,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (playerId != null) 'player_id': playerId,
      if (dirty != null) 'dirty': dirty,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnrollmentsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tournamentId,
      Value<String>? playerId,
      Value<bool>? dirty,
      Value<bool>? deletedLocally,
      Value<int>? rowid}) {
    return EnrollmentsCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      playerId: playerId ?? this.playerId,
      dirty: dirty ?? this.dirty,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('playerId: $playerId, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, MatchRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tournamentIdMeta =
      const VerificationMeta('tournamentId');
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
      'tournament_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _homePlayerIdMeta =
      const VerificationMeta('homePlayerId');
  @override
  late final GeneratedColumn<String> homePlayerId = GeneratedColumn<String>(
      'home_player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _awayPlayerIdMeta =
      const VerificationMeta('awayPlayerId');
  @override
  late final GeneratedColumn<String> awayPlayerId = GeneratedColumn<String>(
      'away_player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _homePlayerNameMeta =
      const VerificationMeta('homePlayerName');
  @override
  late final GeneratedColumn<String> homePlayerName = GeneratedColumn<String>(
      'home_player_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _awayPlayerNameMeta =
      const VerificationMeta('awayPlayerName');
  @override
  late final GeneratedColumn<String> awayPlayerName = GeneratedColumn<String>(
      'away_player_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _homeScoreMeta =
      const VerificationMeta('homeScore');
  @override
  late final GeneratedColumn<int> homeScore = GeneratedColumn<int>(
      'home_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _awayScoreMeta =
      const VerificationMeta('awayScore');
  @override
  late final GeneratedColumn<int> awayScore = GeneratedColumn<int>(
      'away_score', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<DateTime> scheduledAt = GeneratedColumn<DateTime>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _roundMeta = const VerificationMeta('round');
  @override
  late final GeneratedColumn<String> round = GeneratedColumn<String>(
      'round', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _matchNumberMeta =
      const VerificationMeta('matchNumber');
  @override
  late final GeneratedColumn<int> matchNumber = GeneratedColumn<int>(
      'match_number', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _mesaOrderMeta =
      const VerificationMeta('mesaOrder');
  @override
  late final GeneratedColumn<int> mesaOrder = GeneratedColumn<int>(
      'mesa_order', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _deletedLocallyMeta =
      const VerificationMeta('deletedLocally');
  @override
  late final GeneratedColumn<bool> deletedLocally = GeneratedColumn<bool>(
      'deleted_locally', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("deleted_locally" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tournamentId,
        homePlayerId,
        awayPlayerId,
        homePlayerName,
        awayPlayerName,
        homeScore,
        awayScore,
        status,
        scheduledAt,
        round,
        matchNumber,
        mesaOrder,
        createdAt,
        dirty,
        deletedLocally
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(Insertable<MatchRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
          _tournamentIdMeta,
          tournamentId.isAcceptableOrUnknown(
              data['tournament_id']!, _tournamentIdMeta));
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('home_player_id')) {
      context.handle(
          _homePlayerIdMeta,
          homePlayerId.isAcceptableOrUnknown(
              data['home_player_id']!, _homePlayerIdMeta));
    } else if (isInserting) {
      context.missing(_homePlayerIdMeta);
    }
    if (data.containsKey('away_player_id')) {
      context.handle(
          _awayPlayerIdMeta,
          awayPlayerId.isAcceptableOrUnknown(
              data['away_player_id']!, _awayPlayerIdMeta));
    } else if (isInserting) {
      context.missing(_awayPlayerIdMeta);
    }
    if (data.containsKey('home_player_name')) {
      context.handle(
          _homePlayerNameMeta,
          homePlayerName.isAcceptableOrUnknown(
              data['home_player_name']!, _homePlayerNameMeta));
    } else if (isInserting) {
      context.missing(_homePlayerNameMeta);
    }
    if (data.containsKey('away_player_name')) {
      context.handle(
          _awayPlayerNameMeta,
          awayPlayerName.isAcceptableOrUnknown(
              data['away_player_name']!, _awayPlayerNameMeta));
    } else if (isInserting) {
      context.missing(_awayPlayerNameMeta);
    }
    if (data.containsKey('home_score')) {
      context.handle(_homeScoreMeta,
          homeScore.isAcceptableOrUnknown(data['home_score']!, _homeScoreMeta));
    }
    if (data.containsKey('away_score')) {
      context.handle(_awayScoreMeta,
          awayScore.isAcceptableOrUnknown(data['away_score']!, _awayScoreMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('round')) {
      context.handle(
          _roundMeta, round.isAcceptableOrUnknown(data['round']!, _roundMeta));
    }
    if (data.containsKey('match_number')) {
      context.handle(
          _matchNumberMeta,
          matchNumber.isAcceptableOrUnknown(
              data['match_number']!, _matchNumberMeta));
    }
    if (data.containsKey('mesa_order')) {
      context.handle(_mesaOrderMeta,
          mesaOrder.isAcceptableOrUnknown(data['mesa_order']!, _mesaOrderMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    if (data.containsKey('deleted_locally')) {
      context.handle(
          _deletedLocallyMeta,
          deletedLocally.isAcceptableOrUnknown(
              data['deleted_locally']!, _deletedLocallyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MatchRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MatchRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tournamentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tournament_id'])!,
      homePlayerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}home_player_id'])!,
      awayPlayerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}away_player_id'])!,
      homePlayerName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}home_player_name'])!,
      awayPlayerName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}away_player_name'])!,
      homeScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}home_score']),
      awayScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}away_score']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}scheduled_at']),
      round: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}round']),
      matchNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}match_number']),
      mesaOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}mesa_order']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
      deletedLocally: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}deleted_locally'])!,
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }
}

class MatchRow extends DataClass implements Insertable<MatchRow> {
  final String id;
  final String tournamentId;
  final String homePlayerId;
  final String awayPlayerId;
  final String homePlayerName;
  final String awayPlayerName;
  final int? homeScore;
  final int? awayScore;
  final String status;
  final DateTime? scheduledAt;
  final String? round;
  final int? matchNumber;

  /// Turno global del encuentro dentro de su mesa (1, 2, 3...), mezclando
  /// todas las categorías de la mesa. Lo asigna MesaScheduleService, nunca
  /// el usuario. null = sin turno (los BYE, o datos anteriores a la v6).
  final int? mesaOrder;
  final DateTime? createdAt;
  final bool dirty;
  final bool deletedLocally;
  const MatchRow(
      {required this.id,
      required this.tournamentId,
      required this.homePlayerId,
      required this.awayPlayerId,
      required this.homePlayerName,
      required this.awayPlayerName,
      this.homeScore,
      this.awayScore,
      required this.status,
      this.scheduledAt,
      this.round,
      this.matchNumber,
      this.mesaOrder,
      this.createdAt,
      required this.dirty,
      required this.deletedLocally});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tournament_id'] = Variable<String>(tournamentId);
    map['home_player_id'] = Variable<String>(homePlayerId);
    map['away_player_id'] = Variable<String>(awayPlayerId);
    map['home_player_name'] = Variable<String>(homePlayerName);
    map['away_player_name'] = Variable<String>(awayPlayerName);
    if (!nullToAbsent || homeScore != null) {
      map['home_score'] = Variable<int>(homeScore);
    }
    if (!nullToAbsent || awayScore != null) {
      map['away_score'] = Variable<int>(awayScore);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt);
    }
    if (!nullToAbsent || round != null) {
      map['round'] = Variable<String>(round);
    }
    if (!nullToAbsent || matchNumber != null) {
      map['match_number'] = Variable<int>(matchNumber);
    }
    if (!nullToAbsent || mesaOrder != null) {
      map['mesa_order'] = Variable<int>(mesaOrder);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    map['dirty'] = Variable<bool>(dirty);
    map['deleted_locally'] = Variable<bool>(deletedLocally);
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      tournamentId: Value(tournamentId),
      homePlayerId: Value(homePlayerId),
      awayPlayerId: Value(awayPlayerId),
      homePlayerName: Value(homePlayerName),
      awayPlayerName: Value(awayPlayerName),
      homeScore: homeScore == null && nullToAbsent
          ? const Value.absent()
          : Value(homeScore),
      awayScore: awayScore == null && nullToAbsent
          ? const Value.absent()
          : Value(awayScore),
      status: Value(status),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      round:
          round == null && nullToAbsent ? const Value.absent() : Value(round),
      matchNumber: matchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(matchNumber),
      mesaOrder: mesaOrder == null && nullToAbsent
          ? const Value.absent()
          : Value(mesaOrder),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      dirty: Value(dirty),
      deletedLocally: Value(deletedLocally),
    );
  }

  factory MatchRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MatchRow(
      id: serializer.fromJson<String>(json['id']),
      tournamentId: serializer.fromJson<String>(json['tournamentId']),
      homePlayerId: serializer.fromJson<String>(json['homePlayerId']),
      awayPlayerId: serializer.fromJson<String>(json['awayPlayerId']),
      homePlayerName: serializer.fromJson<String>(json['homePlayerName']),
      awayPlayerName: serializer.fromJson<String>(json['awayPlayerName']),
      homeScore: serializer.fromJson<int?>(json['homeScore']),
      awayScore: serializer.fromJson<int?>(json['awayScore']),
      status: serializer.fromJson<String>(json['status']),
      scheduledAt: serializer.fromJson<DateTime?>(json['scheduledAt']),
      round: serializer.fromJson<String?>(json['round']),
      matchNumber: serializer.fromJson<int?>(json['matchNumber']),
      mesaOrder: serializer.fromJson<int?>(json['mesaOrder']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
      deletedLocally: serializer.fromJson<bool>(json['deletedLocally']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tournamentId': serializer.toJson<String>(tournamentId),
      'homePlayerId': serializer.toJson<String>(homePlayerId),
      'awayPlayerId': serializer.toJson<String>(awayPlayerId),
      'homePlayerName': serializer.toJson<String>(homePlayerName),
      'awayPlayerName': serializer.toJson<String>(awayPlayerName),
      'homeScore': serializer.toJson<int?>(homeScore),
      'awayScore': serializer.toJson<int?>(awayScore),
      'status': serializer.toJson<String>(status),
      'scheduledAt': serializer.toJson<DateTime?>(scheduledAt),
      'round': serializer.toJson<String?>(round),
      'matchNumber': serializer.toJson<int?>(matchNumber),
      'mesaOrder': serializer.toJson<int?>(mesaOrder),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'dirty': serializer.toJson<bool>(dirty),
      'deletedLocally': serializer.toJson<bool>(deletedLocally),
    };
  }

  MatchRow copyWith(
          {String? id,
          String? tournamentId,
          String? homePlayerId,
          String? awayPlayerId,
          String? homePlayerName,
          String? awayPlayerName,
          Value<int?> homeScore = const Value.absent(),
          Value<int?> awayScore = const Value.absent(),
          String? status,
          Value<DateTime?> scheduledAt = const Value.absent(),
          Value<String?> round = const Value.absent(),
          Value<int?> matchNumber = const Value.absent(),
          Value<int?> mesaOrder = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent(),
          bool? dirty,
          bool? deletedLocally}) =>
      MatchRow(
        id: id ?? this.id,
        tournamentId: tournamentId ?? this.tournamentId,
        homePlayerId: homePlayerId ?? this.homePlayerId,
        awayPlayerId: awayPlayerId ?? this.awayPlayerId,
        homePlayerName: homePlayerName ?? this.homePlayerName,
        awayPlayerName: awayPlayerName ?? this.awayPlayerName,
        homeScore: homeScore.present ? homeScore.value : this.homeScore,
        awayScore: awayScore.present ? awayScore.value : this.awayScore,
        status: status ?? this.status,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        round: round.present ? round.value : this.round,
        matchNumber: matchNumber.present ? matchNumber.value : this.matchNumber,
        mesaOrder: mesaOrder.present ? mesaOrder.value : this.mesaOrder,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        dirty: dirty ?? this.dirty,
        deletedLocally: deletedLocally ?? this.deletedLocally,
      );
  MatchRow copyWithCompanion(MatchesCompanion data) {
    return MatchRow(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      homePlayerId: data.homePlayerId.present
          ? data.homePlayerId.value
          : this.homePlayerId,
      awayPlayerId: data.awayPlayerId.present
          ? data.awayPlayerId.value
          : this.awayPlayerId,
      homePlayerName: data.homePlayerName.present
          ? data.homePlayerName.value
          : this.homePlayerName,
      awayPlayerName: data.awayPlayerName.present
          ? data.awayPlayerName.value
          : this.awayPlayerName,
      homeScore: data.homeScore.present ? data.homeScore.value : this.homeScore,
      awayScore: data.awayScore.present ? data.awayScore.value : this.awayScore,
      status: data.status.present ? data.status.value : this.status,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      round: data.round.present ? data.round.value : this.round,
      matchNumber:
          data.matchNumber.present ? data.matchNumber.value : this.matchNumber,
      mesaOrder: data.mesaOrder.present ? data.mesaOrder.value : this.mesaOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
      deletedLocally: data.deletedLocally.present
          ? data.deletedLocally.value
          : this.deletedLocally,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MatchRow(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homePlayerId: $homePlayerId, ')
          ..write('awayPlayerId: $awayPlayerId, ')
          ..write('homePlayerName: $homePlayerName, ')
          ..write('awayPlayerName: $awayPlayerName, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('status: $status, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('round: $round, ')
          ..write('matchNumber: $matchNumber, ')
          ..write('mesaOrder: $mesaOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tournamentId,
      homePlayerId,
      awayPlayerId,
      homePlayerName,
      awayPlayerName,
      homeScore,
      awayScore,
      status,
      scheduledAt,
      round,
      matchNumber,
      mesaOrder,
      createdAt,
      dirty,
      deletedLocally);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MatchRow &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.homePlayerId == this.homePlayerId &&
          other.awayPlayerId == this.awayPlayerId &&
          other.homePlayerName == this.homePlayerName &&
          other.awayPlayerName == this.awayPlayerName &&
          other.homeScore == this.homeScore &&
          other.awayScore == this.awayScore &&
          other.status == this.status &&
          other.scheduledAt == this.scheduledAt &&
          other.round == this.round &&
          other.matchNumber == this.matchNumber &&
          other.mesaOrder == this.mesaOrder &&
          other.createdAt == this.createdAt &&
          other.dirty == this.dirty &&
          other.deletedLocally == this.deletedLocally);
}

class MatchesCompanion extends UpdateCompanion<MatchRow> {
  final Value<String> id;
  final Value<String> tournamentId;
  final Value<String> homePlayerId;
  final Value<String> awayPlayerId;
  final Value<String> homePlayerName;
  final Value<String> awayPlayerName;
  final Value<int?> homeScore;
  final Value<int?> awayScore;
  final Value<String> status;
  final Value<DateTime?> scheduledAt;
  final Value<String?> round;
  final Value<int?> matchNumber;
  final Value<int?> mesaOrder;
  final Value<DateTime?> createdAt;
  final Value<bool> dirty;
  final Value<bool> deletedLocally;
  final Value<int> rowid;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.homePlayerId = const Value.absent(),
    this.awayPlayerId = const Value.absent(),
    this.homePlayerName = const Value.absent(),
    this.awayPlayerName = const Value.absent(),
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    this.status = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.round = const Value.absent(),
    this.matchNumber = const Value.absent(),
    this.mesaOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesCompanion.insert({
    required String id,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required String homePlayerName,
    required String awayPlayerName,
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    required String status,
    this.scheduledAt = const Value.absent(),
    this.round = const Value.absent(),
    this.matchNumber = const Value.absent(),
    this.mesaOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.deletedLocally = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tournamentId = Value(tournamentId),
        homePlayerId = Value(homePlayerId),
        awayPlayerId = Value(awayPlayerId),
        homePlayerName = Value(homePlayerName),
        awayPlayerName = Value(awayPlayerName),
        status = Value(status);
  static Insertable<MatchRow> custom({
    Expression<String>? id,
    Expression<String>? tournamentId,
    Expression<String>? homePlayerId,
    Expression<String>? awayPlayerId,
    Expression<String>? homePlayerName,
    Expression<String>? awayPlayerName,
    Expression<int>? homeScore,
    Expression<int>? awayScore,
    Expression<String>? status,
    Expression<DateTime>? scheduledAt,
    Expression<String>? round,
    Expression<int>? matchNumber,
    Expression<int>? mesaOrder,
    Expression<DateTime>? createdAt,
    Expression<bool>? dirty,
    Expression<bool>? deletedLocally,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (homePlayerId != null) 'home_player_id': homePlayerId,
      if (awayPlayerId != null) 'away_player_id': awayPlayerId,
      if (homePlayerName != null) 'home_player_name': homePlayerName,
      if (awayPlayerName != null) 'away_player_name': awayPlayerName,
      if (homeScore != null) 'home_score': homeScore,
      if (awayScore != null) 'away_score': awayScore,
      if (status != null) 'status': status,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (round != null) 'round': round,
      if (matchNumber != null) 'match_number': matchNumber,
      if (mesaOrder != null) 'mesa_order': mesaOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (dirty != null) 'dirty': dirty,
      if (deletedLocally != null) 'deleted_locally': deletedLocally,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesCompanion copyWith(
      {Value<String>? id,
      Value<String>? tournamentId,
      Value<String>? homePlayerId,
      Value<String>? awayPlayerId,
      Value<String>? homePlayerName,
      Value<String>? awayPlayerName,
      Value<int?>? homeScore,
      Value<int?>? awayScore,
      Value<String>? status,
      Value<DateTime?>? scheduledAt,
      Value<String?>? round,
      Value<int?>? matchNumber,
      Value<int?>? mesaOrder,
      Value<DateTime?>? createdAt,
      Value<bool>? dirty,
      Value<bool>? deletedLocally,
      Value<int>? rowid}) {
    return MatchesCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      homePlayerId: homePlayerId ?? this.homePlayerId,
      awayPlayerId: awayPlayerId ?? this.awayPlayerId,
      homePlayerName: homePlayerName ?? this.homePlayerName,
      awayPlayerName: awayPlayerName ?? this.awayPlayerName,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      round: round ?? this.round,
      matchNumber: matchNumber ?? this.matchNumber,
      mesaOrder: mesaOrder ?? this.mesaOrder,
      createdAt: createdAt ?? this.createdAt,
      dirty: dirty ?? this.dirty,
      deletedLocally: deletedLocally ?? this.deletedLocally,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (homePlayerId.present) {
      map['home_player_id'] = Variable<String>(homePlayerId.value);
    }
    if (awayPlayerId.present) {
      map['away_player_id'] = Variable<String>(awayPlayerId.value);
    }
    if (homePlayerName.present) {
      map['home_player_name'] = Variable<String>(homePlayerName.value);
    }
    if (awayPlayerName.present) {
      map['away_player_name'] = Variable<String>(awayPlayerName.value);
    }
    if (homeScore.present) {
      map['home_score'] = Variable<int>(homeScore.value);
    }
    if (awayScore.present) {
      map['away_score'] = Variable<int>(awayScore.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<DateTime>(scheduledAt.value);
    }
    if (round.present) {
      map['round'] = Variable<String>(round.value);
    }
    if (matchNumber.present) {
      map['match_number'] = Variable<int>(matchNumber.value);
    }
    if (mesaOrder.present) {
      map['mesa_order'] = Variable<int>(mesaOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (deletedLocally.present) {
      map['deleted_locally'] = Variable<bool>(deletedLocally.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homePlayerId: $homePlayerId, ')
          ..write('awayPlayerId: $awayPlayerId, ')
          ..write('homePlayerName: $homePlayerName, ')
          ..write('awayPlayerName: $awayPlayerName, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('status: $status, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('round: $round, ')
          ..write('matchNumber: $matchNumber, ')
          ..write('mesaOrder: $mesaOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('dirty: $dirty, ')
          ..write('deletedLocally: $deletedLocally, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResultsTable extends Results with TableInfo<$ResultsTable, Result> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _matchIdMeta =
      const VerificationMeta('matchId');
  @override
  late final GeneratedColumn<String> matchId = GeneratedColumn<String>(
      'match_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tournamentIdMeta =
      const VerificationMeta('tournamentId');
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
      'tournament_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _homePlayerIdMeta =
      const VerificationMeta('homePlayerId');
  @override
  late final GeneratedColumn<String> homePlayerId = GeneratedColumn<String>(
      'home_player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _awayPlayerIdMeta =
      const VerificationMeta('awayPlayerId');
  @override
  late final GeneratedColumn<String> awayPlayerId = GeneratedColumn<String>(
      'away_player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _homeScoreMeta =
      const VerificationMeta('homeScore');
  @override
  late final GeneratedColumn<int> homeScore = GeneratedColumn<int>(
      'home_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _awayScoreMeta =
      const VerificationMeta('awayScore');
  @override
  late final GeneratedColumn<int> awayScore = GeneratedColumn<int>(
      'away_score', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registeredByMeta =
      const VerificationMeta('registeredBy');
  @override
  late final GeneratedColumn<String> registeredBy = GeneratedColumn<String>(
      'registered_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _registeredAtMeta =
      const VerificationMeta('registeredAt');
  @override
  late final GeneratedColumn<DateTime> registeredAt = GeneratedColumn<DateTime>(
      'registered_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        matchId,
        tournamentId,
        homePlayerId,
        awayPlayerId,
        homeScore,
        awayScore,
        notes,
        registeredBy,
        registeredAt,
        dirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'results';
  @override
  VerificationContext validateIntegrity(Insertable<Result> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('match_id')) {
      context.handle(_matchIdMeta,
          matchId.isAcceptableOrUnknown(data['match_id']!, _matchIdMeta));
    } else if (isInserting) {
      context.missing(_matchIdMeta);
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
          _tournamentIdMeta,
          tournamentId.isAcceptableOrUnknown(
              data['tournament_id']!, _tournamentIdMeta));
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('home_player_id')) {
      context.handle(
          _homePlayerIdMeta,
          homePlayerId.isAcceptableOrUnknown(
              data['home_player_id']!, _homePlayerIdMeta));
    } else if (isInserting) {
      context.missing(_homePlayerIdMeta);
    }
    if (data.containsKey('away_player_id')) {
      context.handle(
          _awayPlayerIdMeta,
          awayPlayerId.isAcceptableOrUnknown(
              data['away_player_id']!, _awayPlayerIdMeta));
    } else if (isInserting) {
      context.missing(_awayPlayerIdMeta);
    }
    if (data.containsKey('home_score')) {
      context.handle(_homeScoreMeta,
          homeScore.isAcceptableOrUnknown(data['home_score']!, _homeScoreMeta));
    } else if (isInserting) {
      context.missing(_homeScoreMeta);
    }
    if (data.containsKey('away_score')) {
      context.handle(_awayScoreMeta,
          awayScore.isAcceptableOrUnknown(data['away_score']!, _awayScoreMeta));
    } else if (isInserting) {
      context.missing(_awayScoreMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('registered_by')) {
      context.handle(
          _registeredByMeta,
          registeredBy.isAcceptableOrUnknown(
              data['registered_by']!, _registeredByMeta));
    } else if (isInserting) {
      context.missing(_registeredByMeta);
    }
    if (data.containsKey('registered_at')) {
      context.handle(
          _registeredAtMeta,
          registeredAt.isAcceptableOrUnknown(
              data['registered_at']!, _registeredAtMeta));
    } else if (isInserting) {
      context.missing(_registeredAtMeta);
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Result map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Result(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      matchId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}match_id'])!,
      tournamentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tournament_id'])!,
      homePlayerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}home_player_id'])!,
      awayPlayerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}away_player_id'])!,
      homeScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}home_score'])!,
      awayScore: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}away_score'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      registeredBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}registered_by'])!,
      registeredAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}registered_at'])!,
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $ResultsTable createAlias(String alias) {
    return $ResultsTable(attachedDatabase, alias);
  }
}

class Result extends DataClass implements Insertable<Result> {
  final String id;
  final String matchId;
  final String tournamentId;
  final String homePlayerId;
  final String awayPlayerId;
  final int homeScore;
  final int awayScore;
  final String? notes;
  final String registeredBy;
  final DateTime registeredAt;
  final bool dirty;
  const Result(
      {required this.id,
      required this.matchId,
      required this.tournamentId,
      required this.homePlayerId,
      required this.awayPlayerId,
      required this.homeScore,
      required this.awayScore,
      this.notes,
      required this.registeredBy,
      required this.registeredAt,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['match_id'] = Variable<String>(matchId);
    map['tournament_id'] = Variable<String>(tournamentId);
    map['home_player_id'] = Variable<String>(homePlayerId);
    map['away_player_id'] = Variable<String>(awayPlayerId);
    map['home_score'] = Variable<int>(homeScore);
    map['away_score'] = Variable<int>(awayScore);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['registered_by'] = Variable<String>(registeredBy);
    map['registered_at'] = Variable<DateTime>(registeredAt);
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  ResultsCompanion toCompanion(bool nullToAbsent) {
    return ResultsCompanion(
      id: Value(id),
      matchId: Value(matchId),
      tournamentId: Value(tournamentId),
      homePlayerId: Value(homePlayerId),
      awayPlayerId: Value(awayPlayerId),
      homeScore: Value(homeScore),
      awayScore: Value(awayScore),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      registeredBy: Value(registeredBy),
      registeredAt: Value(registeredAt),
      dirty: Value(dirty),
    );
  }

  factory Result.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Result(
      id: serializer.fromJson<String>(json['id']),
      matchId: serializer.fromJson<String>(json['matchId']),
      tournamentId: serializer.fromJson<String>(json['tournamentId']),
      homePlayerId: serializer.fromJson<String>(json['homePlayerId']),
      awayPlayerId: serializer.fromJson<String>(json['awayPlayerId']),
      homeScore: serializer.fromJson<int>(json['homeScore']),
      awayScore: serializer.fromJson<int>(json['awayScore']),
      notes: serializer.fromJson<String?>(json['notes']),
      registeredBy: serializer.fromJson<String>(json['registeredBy']),
      registeredAt: serializer.fromJson<DateTime>(json['registeredAt']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'matchId': serializer.toJson<String>(matchId),
      'tournamentId': serializer.toJson<String>(tournamentId),
      'homePlayerId': serializer.toJson<String>(homePlayerId),
      'awayPlayerId': serializer.toJson<String>(awayPlayerId),
      'homeScore': serializer.toJson<int>(homeScore),
      'awayScore': serializer.toJson<int>(awayScore),
      'notes': serializer.toJson<String?>(notes),
      'registeredBy': serializer.toJson<String>(registeredBy),
      'registeredAt': serializer.toJson<DateTime>(registeredAt),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  Result copyWith(
          {String? id,
          String? matchId,
          String? tournamentId,
          String? homePlayerId,
          String? awayPlayerId,
          int? homeScore,
          int? awayScore,
          Value<String?> notes = const Value.absent(),
          String? registeredBy,
          DateTime? registeredAt,
          bool? dirty}) =>
      Result(
        id: id ?? this.id,
        matchId: matchId ?? this.matchId,
        tournamentId: tournamentId ?? this.tournamentId,
        homePlayerId: homePlayerId ?? this.homePlayerId,
        awayPlayerId: awayPlayerId ?? this.awayPlayerId,
        homeScore: homeScore ?? this.homeScore,
        awayScore: awayScore ?? this.awayScore,
        notes: notes.present ? notes.value : this.notes,
        registeredBy: registeredBy ?? this.registeredBy,
        registeredAt: registeredAt ?? this.registeredAt,
        dirty: dirty ?? this.dirty,
      );
  Result copyWithCompanion(ResultsCompanion data) {
    return Result(
      id: data.id.present ? data.id.value : this.id,
      matchId: data.matchId.present ? data.matchId.value : this.matchId,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      homePlayerId: data.homePlayerId.present
          ? data.homePlayerId.value
          : this.homePlayerId,
      awayPlayerId: data.awayPlayerId.present
          ? data.awayPlayerId.value
          : this.awayPlayerId,
      homeScore: data.homeScore.present ? data.homeScore.value : this.homeScore,
      awayScore: data.awayScore.present ? data.awayScore.value : this.awayScore,
      notes: data.notes.present ? data.notes.value : this.notes,
      registeredBy: data.registeredBy.present
          ? data.registeredBy.value
          : this.registeredBy,
      registeredAt: data.registeredAt.present
          ? data.registeredAt.value
          : this.registeredAt,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Result(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homePlayerId: $homePlayerId, ')
          ..write('awayPlayerId: $awayPlayerId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      matchId,
      tournamentId,
      homePlayerId,
      awayPlayerId,
      homeScore,
      awayScore,
      notes,
      registeredBy,
      registeredAt,
      dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Result &&
          other.id == this.id &&
          other.matchId == this.matchId &&
          other.tournamentId == this.tournamentId &&
          other.homePlayerId == this.homePlayerId &&
          other.awayPlayerId == this.awayPlayerId &&
          other.homeScore == this.homeScore &&
          other.awayScore == this.awayScore &&
          other.notes == this.notes &&
          other.registeredBy == this.registeredBy &&
          other.registeredAt == this.registeredAt &&
          other.dirty == this.dirty);
}

class ResultsCompanion extends UpdateCompanion<Result> {
  final Value<String> id;
  final Value<String> matchId;
  final Value<String> tournamentId;
  final Value<String> homePlayerId;
  final Value<String> awayPlayerId;
  final Value<int> homeScore;
  final Value<int> awayScore;
  final Value<String?> notes;
  final Value<String> registeredBy;
  final Value<DateTime> registeredAt;
  final Value<bool> dirty;
  final Value<int> rowid;
  const ResultsCompanion({
    this.id = const Value.absent(),
    this.matchId = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.homePlayerId = const Value.absent(),
    this.awayPlayerId = const Value.absent(),
    this.homeScore = const Value.absent(),
    this.awayScore = const Value.absent(),
    this.notes = const Value.absent(),
    this.registeredBy = const Value.absent(),
    this.registeredAt = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResultsCompanion.insert({
    required String id,
    required String matchId,
    required String tournamentId,
    required String homePlayerId,
    required String awayPlayerId,
    required int homeScore,
    required int awayScore,
    this.notes = const Value.absent(),
    required String registeredBy,
    required DateTime registeredAt,
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        matchId = Value(matchId),
        tournamentId = Value(tournamentId),
        homePlayerId = Value(homePlayerId),
        awayPlayerId = Value(awayPlayerId),
        homeScore = Value(homeScore),
        awayScore = Value(awayScore),
        registeredBy = Value(registeredBy),
        registeredAt = Value(registeredAt);
  static Insertable<Result> custom({
    Expression<String>? id,
    Expression<String>? matchId,
    Expression<String>? tournamentId,
    Expression<String>? homePlayerId,
    Expression<String>? awayPlayerId,
    Expression<int>? homeScore,
    Expression<int>? awayScore,
    Expression<String>? notes,
    Expression<String>? registeredBy,
    Expression<DateTime>? registeredAt,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (matchId != null) 'match_id': matchId,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (homePlayerId != null) 'home_player_id': homePlayerId,
      if (awayPlayerId != null) 'away_player_id': awayPlayerId,
      if (homeScore != null) 'home_score': homeScore,
      if (awayScore != null) 'away_score': awayScore,
      if (notes != null) 'notes': notes,
      if (registeredBy != null) 'registered_by': registeredBy,
      if (registeredAt != null) 'registered_at': registeredAt,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResultsCompanion copyWith(
      {Value<String>? id,
      Value<String>? matchId,
      Value<String>? tournamentId,
      Value<String>? homePlayerId,
      Value<String>? awayPlayerId,
      Value<int>? homeScore,
      Value<int>? awayScore,
      Value<String?>? notes,
      Value<String>? registeredBy,
      Value<DateTime>? registeredAt,
      Value<bool>? dirty,
      Value<int>? rowid}) {
    return ResultsCompanion(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      tournamentId: tournamentId ?? this.tournamentId,
      homePlayerId: homePlayerId ?? this.homePlayerId,
      awayPlayerId: awayPlayerId ?? this.awayPlayerId,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      notes: notes ?? this.notes,
      registeredBy: registeredBy ?? this.registeredBy,
      registeredAt: registeredAt ?? this.registeredAt,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (matchId.present) {
      map['match_id'] = Variable<String>(matchId.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (homePlayerId.present) {
      map['home_player_id'] = Variable<String>(homePlayerId.value);
    }
    if (awayPlayerId.present) {
      map['away_player_id'] = Variable<String>(awayPlayerId.value);
    }
    if (homeScore.present) {
      map['home_score'] = Variable<int>(homeScore.value);
    }
    if (awayScore.present) {
      map['away_score'] = Variable<int>(awayScore.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (registeredBy.present) {
      map['registered_by'] = Variable<String>(registeredBy.value);
    }
    if (registeredAt.present) {
      map['registered_at'] = Variable<DateTime>(registeredAt.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResultsCompanion(')
          ..write('id: $id, ')
          ..write('matchId: $matchId, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('homePlayerId: $homePlayerId, ')
          ..write('awayPlayerId: $awayPlayerId, ')
          ..write('homeScore: $homeScore, ')
          ..write('awayScore: $awayScore, ')
          ..write('notes: $notes, ')
          ..write('registeredBy: $registeredBy, ')
          ..write('registeredAt: $registeredAt, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StandingsTable extends Standings
    with TableInfo<$StandingsTable, Standing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StandingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tournamentIdMeta =
      const VerificationMeta('tournamentId');
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
      'tournament_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerIdMeta =
      const VerificationMeta('playerId');
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
      'player_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playerNameMeta =
      const VerificationMeta('playerName');
  @override
  late final GeneratedColumn<String> playerName = GeneratedColumn<String>(
      'player_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _playedMeta = const VerificationMeta('played');
  @override
  late final GeneratedColumn<int> played = GeneratedColumn<int>(
      'played', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wonMeta = const VerificationMeta('won');
  @override
  late final GeneratedColumn<int> won = GeneratedColumn<int>(
      'won', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _drawnMeta = const VerificationMeta('drawn');
  @override
  late final GeneratedColumn<int> drawn = GeneratedColumn<int>(
      'drawn', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lostMeta = const VerificationMeta('lost');
  @override
  late final GeneratedColumn<int> lost = GeneratedColumn<int>(
      'lost', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goalsForMeta =
      const VerificationMeta('goalsFor');
  @override
  late final GeneratedColumn<int> goalsFor = GeneratedColumn<int>(
      'goals_for', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _goalsAgainstMeta =
      const VerificationMeta('goalsAgainst');
  @override
  late final GeneratedColumn<int> goalsAgainst = GeneratedColumn<int>(
      'goals_against', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<int> points = GeneratedColumn<int>(
      'points', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _manualRankMeta =
      const VerificationMeta('manualRank');
  @override
  late final GeneratedColumn<int> manualRank = GeneratedColumn<int>(
      'manual_rank', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dirtyMeta = const VerificationMeta('dirty');
  @override
  late final GeneratedColumn<bool> dirty = GeneratedColumn<bool>(
      'dirty', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("dirty" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        tournamentId,
        playerId,
        playerName,
        played,
        won,
        drawn,
        lost,
        goalsFor,
        goalsAgainst,
        points,
        manualRank,
        dirty
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'standings';
  @override
  VerificationContext validateIntegrity(Insertable<Standing> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
          _tournamentIdMeta,
          tournamentId.isAcceptableOrUnknown(
              data['tournament_id']!, _tournamentIdMeta));
    } else if (isInserting) {
      context.missing(_tournamentIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(_playerIdMeta,
          playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta));
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('player_name')) {
      context.handle(
          _playerNameMeta,
          playerName.isAcceptableOrUnknown(
              data['player_name']!, _playerNameMeta));
    } else if (isInserting) {
      context.missing(_playerNameMeta);
    }
    if (data.containsKey('played')) {
      context.handle(_playedMeta,
          played.isAcceptableOrUnknown(data['played']!, _playedMeta));
    }
    if (data.containsKey('won')) {
      context.handle(
          _wonMeta, won.isAcceptableOrUnknown(data['won']!, _wonMeta));
    }
    if (data.containsKey('drawn')) {
      context.handle(
          _drawnMeta, drawn.isAcceptableOrUnknown(data['drawn']!, _drawnMeta));
    }
    if (data.containsKey('lost')) {
      context.handle(
          _lostMeta, lost.isAcceptableOrUnknown(data['lost']!, _lostMeta));
    }
    if (data.containsKey('goals_for')) {
      context.handle(_goalsForMeta,
          goalsFor.isAcceptableOrUnknown(data['goals_for']!, _goalsForMeta));
    }
    if (data.containsKey('goals_against')) {
      context.handle(
          _goalsAgainstMeta,
          goalsAgainst.isAcceptableOrUnknown(
              data['goals_against']!, _goalsAgainstMeta));
    }
    if (data.containsKey('points')) {
      context.handle(_pointsMeta,
          points.isAcceptableOrUnknown(data['points']!, _pointsMeta));
    }
    if (data.containsKey('manual_rank')) {
      context.handle(
          _manualRankMeta,
          manualRank.isAcceptableOrUnknown(
              data['manual_rank']!, _manualRankMeta));
    }
    if (data.containsKey('dirty')) {
      context.handle(
          _dirtyMeta, dirty.isAcceptableOrUnknown(data['dirty']!, _dirtyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Standing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Standing(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      tournamentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tournament_id'])!,
      playerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_id'])!,
      playerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}player_name'])!,
      played: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}played'])!,
      won: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}won'])!,
      drawn: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}drawn'])!,
      lost: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lost'])!,
      goalsFor: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goals_for'])!,
      goalsAgainst: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}goals_against'])!,
      points: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}points'])!,
      manualRank: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}manual_rank']),
      dirty: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}dirty'])!,
    );
  }

  @override
  $StandingsTable createAlias(String alias) {
    return $StandingsTable(attachedDatabase, alias);
  }
}

class Standing extends DataClass implements Insertable<Standing> {
  final String id;
  final String tournamentId;
  final String playerId;
  final String playerName;
  final int played;
  final int won;
  final int drawn;
  final int lost;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final int? manualRank;
  final bool dirty;
  const Standing(
      {required this.id,
      required this.tournamentId,
      required this.playerId,
      required this.playerName,
      required this.played,
      required this.won,
      required this.drawn,
      required this.lost,
      required this.goalsFor,
      required this.goalsAgainst,
      required this.points,
      this.manualRank,
      required this.dirty});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tournament_id'] = Variable<String>(tournamentId);
    map['player_id'] = Variable<String>(playerId);
    map['player_name'] = Variable<String>(playerName);
    map['played'] = Variable<int>(played);
    map['won'] = Variable<int>(won);
    map['drawn'] = Variable<int>(drawn);
    map['lost'] = Variable<int>(lost);
    map['goals_for'] = Variable<int>(goalsFor);
    map['goals_against'] = Variable<int>(goalsAgainst);
    map['points'] = Variable<int>(points);
    if (!nullToAbsent || manualRank != null) {
      map['manual_rank'] = Variable<int>(manualRank);
    }
    map['dirty'] = Variable<bool>(dirty);
    return map;
  }

  StandingsCompanion toCompanion(bool nullToAbsent) {
    return StandingsCompanion(
      id: Value(id),
      tournamentId: Value(tournamentId),
      playerId: Value(playerId),
      playerName: Value(playerName),
      played: Value(played),
      won: Value(won),
      drawn: Value(drawn),
      lost: Value(lost),
      goalsFor: Value(goalsFor),
      goalsAgainst: Value(goalsAgainst),
      points: Value(points),
      manualRank: manualRank == null && nullToAbsent
          ? const Value.absent()
          : Value(manualRank),
      dirty: Value(dirty),
    );
  }

  factory Standing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Standing(
      id: serializer.fromJson<String>(json['id']),
      tournamentId: serializer.fromJson<String>(json['tournamentId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      playerName: serializer.fromJson<String>(json['playerName']),
      played: serializer.fromJson<int>(json['played']),
      won: serializer.fromJson<int>(json['won']),
      drawn: serializer.fromJson<int>(json['drawn']),
      lost: serializer.fromJson<int>(json['lost']),
      goalsFor: serializer.fromJson<int>(json['goalsFor']),
      goalsAgainst: serializer.fromJson<int>(json['goalsAgainst']),
      points: serializer.fromJson<int>(json['points']),
      manualRank: serializer.fromJson<int?>(json['manualRank']),
      dirty: serializer.fromJson<bool>(json['dirty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tournamentId': serializer.toJson<String>(tournamentId),
      'playerId': serializer.toJson<String>(playerId),
      'playerName': serializer.toJson<String>(playerName),
      'played': serializer.toJson<int>(played),
      'won': serializer.toJson<int>(won),
      'drawn': serializer.toJson<int>(drawn),
      'lost': serializer.toJson<int>(lost),
      'goalsFor': serializer.toJson<int>(goalsFor),
      'goalsAgainst': serializer.toJson<int>(goalsAgainst),
      'points': serializer.toJson<int>(points),
      'manualRank': serializer.toJson<int?>(manualRank),
      'dirty': serializer.toJson<bool>(dirty),
    };
  }

  Standing copyWith(
          {String? id,
          String? tournamentId,
          String? playerId,
          String? playerName,
          int? played,
          int? won,
          int? drawn,
          int? lost,
          int? goalsFor,
          int? goalsAgainst,
          int? points,
          Value<int?> manualRank = const Value.absent(),
          bool? dirty}) =>
      Standing(
        id: id ?? this.id,
        tournamentId: tournamentId ?? this.tournamentId,
        playerId: playerId ?? this.playerId,
        playerName: playerName ?? this.playerName,
        played: played ?? this.played,
        won: won ?? this.won,
        drawn: drawn ?? this.drawn,
        lost: lost ?? this.lost,
        goalsFor: goalsFor ?? this.goalsFor,
        goalsAgainst: goalsAgainst ?? this.goalsAgainst,
        points: points ?? this.points,
        manualRank: manualRank.present ? manualRank.value : this.manualRank,
        dirty: dirty ?? this.dirty,
      );
  Standing copyWithCompanion(StandingsCompanion data) {
    return Standing(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      playerName:
          data.playerName.present ? data.playerName.value : this.playerName,
      played: data.played.present ? data.played.value : this.played,
      won: data.won.present ? data.won.value : this.won,
      drawn: data.drawn.present ? data.drawn.value : this.drawn,
      lost: data.lost.present ? data.lost.value : this.lost,
      goalsFor: data.goalsFor.present ? data.goalsFor.value : this.goalsFor,
      goalsAgainst: data.goalsAgainst.present
          ? data.goalsAgainst.value
          : this.goalsAgainst,
      points: data.points.present ? data.points.value : this.points,
      manualRank:
          data.manualRank.present ? data.manualRank.value : this.manualRank,
      dirty: data.dirty.present ? data.dirty.value : this.dirty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Standing(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('played: $played, ')
          ..write('won: $won, ')
          ..write('drawn: $drawn, ')
          ..write('lost: $lost, ')
          ..write('goalsFor: $goalsFor, ')
          ..write('goalsAgainst: $goalsAgainst, ')
          ..write('points: $points, ')
          ..write('manualRank: $manualRank, ')
          ..write('dirty: $dirty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      tournamentId,
      playerId,
      playerName,
      played,
      won,
      drawn,
      lost,
      goalsFor,
      goalsAgainst,
      points,
      manualRank,
      dirty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Standing &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.playerId == this.playerId &&
          other.playerName == this.playerName &&
          other.played == this.played &&
          other.won == this.won &&
          other.drawn == this.drawn &&
          other.lost == this.lost &&
          other.goalsFor == this.goalsFor &&
          other.goalsAgainst == this.goalsAgainst &&
          other.points == this.points &&
          other.manualRank == this.manualRank &&
          other.dirty == this.dirty);
}

class StandingsCompanion extends UpdateCompanion<Standing> {
  final Value<String> id;
  final Value<String> tournamentId;
  final Value<String> playerId;
  final Value<String> playerName;
  final Value<int> played;
  final Value<int> won;
  final Value<int> drawn;
  final Value<int> lost;
  final Value<int> goalsFor;
  final Value<int> goalsAgainst;
  final Value<int> points;
  final Value<int?> manualRank;
  final Value<bool> dirty;
  final Value<int> rowid;
  const StandingsCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.playerName = const Value.absent(),
    this.played = const Value.absent(),
    this.won = const Value.absent(),
    this.drawn = const Value.absent(),
    this.lost = const Value.absent(),
    this.goalsFor = const Value.absent(),
    this.goalsAgainst = const Value.absent(),
    this.points = const Value.absent(),
    this.manualRank = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StandingsCompanion.insert({
    required String id,
    required String tournamentId,
    required String playerId,
    required String playerName,
    this.played = const Value.absent(),
    this.won = const Value.absent(),
    this.drawn = const Value.absent(),
    this.lost = const Value.absent(),
    this.goalsFor = const Value.absent(),
    this.goalsAgainst = const Value.absent(),
    this.points = const Value.absent(),
    this.manualRank = const Value.absent(),
    this.dirty = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        tournamentId = Value(tournamentId),
        playerId = Value(playerId),
        playerName = Value(playerName);
  static Insertable<Standing> custom({
    Expression<String>? id,
    Expression<String>? tournamentId,
    Expression<String>? playerId,
    Expression<String>? playerName,
    Expression<int>? played,
    Expression<int>? won,
    Expression<int>? drawn,
    Expression<int>? lost,
    Expression<int>? goalsFor,
    Expression<int>? goalsAgainst,
    Expression<int>? points,
    Expression<int>? manualRank,
    Expression<bool>? dirty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (playerId != null) 'player_id': playerId,
      if (playerName != null) 'player_name': playerName,
      if (played != null) 'played': played,
      if (won != null) 'won': won,
      if (drawn != null) 'drawn': drawn,
      if (lost != null) 'lost': lost,
      if (goalsFor != null) 'goals_for': goalsFor,
      if (goalsAgainst != null) 'goals_against': goalsAgainst,
      if (points != null) 'points': points,
      if (manualRank != null) 'manual_rank': manualRank,
      if (dirty != null) 'dirty': dirty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StandingsCompanion copyWith(
      {Value<String>? id,
      Value<String>? tournamentId,
      Value<String>? playerId,
      Value<String>? playerName,
      Value<int>? played,
      Value<int>? won,
      Value<int>? drawn,
      Value<int>? lost,
      Value<int>? goalsFor,
      Value<int>? goalsAgainst,
      Value<int>? points,
      Value<int?>? manualRank,
      Value<bool>? dirty,
      Value<int>? rowid}) {
    return StandingsCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      playerId: playerId ?? this.playerId,
      playerName: playerName ?? this.playerName,
      played: played ?? this.played,
      won: won ?? this.won,
      drawn: drawn ?? this.drawn,
      lost: lost ?? this.lost,
      goalsFor: goalsFor ?? this.goalsFor,
      goalsAgainst: goalsAgainst ?? this.goalsAgainst,
      points: points ?? this.points,
      manualRank: manualRank ?? this.manualRank,
      dirty: dirty ?? this.dirty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (playerName.present) {
      map['player_name'] = Variable<String>(playerName.value);
    }
    if (played.present) {
      map['played'] = Variable<int>(played.value);
    }
    if (won.present) {
      map['won'] = Variable<int>(won.value);
    }
    if (drawn.present) {
      map['drawn'] = Variable<int>(drawn.value);
    }
    if (lost.present) {
      map['lost'] = Variable<int>(lost.value);
    }
    if (goalsFor.present) {
      map['goals_for'] = Variable<int>(goalsFor.value);
    }
    if (goalsAgainst.present) {
      map['goals_against'] = Variable<int>(goalsAgainst.value);
    }
    if (points.present) {
      map['points'] = Variable<int>(points.value);
    }
    if (manualRank.present) {
      map['manual_rank'] = Variable<int>(manualRank.value);
    }
    if (dirty.present) {
      map['dirty'] = Variable<bool>(dirty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StandingsCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('playerId: $playerId, ')
          ..write('playerName: $playerName, ')
          ..write('played: $played, ')
          ..write('won: $won, ')
          ..write('drawn: $drawn, ')
          ..write('lost: $lost, ')
          ..write('goalsFor: $goalsFor, ')
          ..write('goalsAgainst: $goalsAgainst, ')
          ..write('points: $points, ')
          ..write('manualRank: $manualRank, ')
          ..write('dirty: $dirty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueEntriesTable extends SyncQueueEntries
    with TableInfo<$SyncQueueEntriesTable, SyncQueueEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entityTableMeta =
      const VerificationMeta('entityTable');
  @override
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
      'entity_table', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
      'row_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _operationMeta =
      const VerificationMeta('operation');
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
      'operation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastErrorMeta =
      const VerificationMeta('lastError');
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
      'last_error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        entityTable,
        rowId,
        operation,
        payload,
        createdAt,
        retryCount,
        lastError
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SyncQueueEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
          _entityTableMeta,
          entityTable.isAcceptableOrUnknown(
              data['entity_table']!, _entityTableMeta));
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
          _rowIdMeta, rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta));
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(_operationMeta,
          operation.isAcceptableOrUnknown(data['operation']!, _operationMeta));
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('last_error')) {
      context.handle(_lastErrorMeta,
          lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entityTable: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_table'])!,
      rowId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}row_id'])!,
      operation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}operation'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      lastError: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_error']),
    );
  }

  @override
  $SyncQueueEntriesTable createAlias(String alias) {
    return $SyncQueueEntriesTable(attachedDatabase, alias);
  }
}

class SyncQueueEntry extends DataClass implements Insertable<SyncQueueEntry> {
  final String id;
  final String entityTable;
  final String rowId;

  /// 'upsert' | 'delete'
  final String operation;

  /// JSON con los datos de la fila (solo aplica para 'upsert').
  final String? payload;
  final DateTime createdAt;
  final int retryCount;
  final String? lastError;
  const SyncQueueEntry(
      {required this.id,
      required this.entityTable,
      required this.rowId,
      required this.operation,
      this.payload,
      required this.createdAt,
      required this.retryCount,
      this.lastError});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['entity_table'] = Variable<String>(entityTable);
    map['row_id'] = Variable<String>(rowId);
    map['operation'] = Variable<String>(operation);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  SyncQueueEntriesCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueEntriesCompanion(
      id: Value(id),
      entityTable: Value(entityTable),
      rowId: Value(rowId),
      operation: Value(operation),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory SyncQueueEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueEntry(
      id: serializer.fromJson<String>(json['id']),
      entityTable: serializer.fromJson<String>(json['entityTable']),
      rowId: serializer.fromJson<String>(json['rowId']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entityTable': serializer.toJson<String>(entityTable),
      'rowId': serializer.toJson<String>(rowId),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  SyncQueueEntry copyWith(
          {String? id,
          String? entityTable,
          String? rowId,
          String? operation,
          Value<String?> payload = const Value.absent(),
          DateTime? createdAt,
          int? retryCount,
          Value<String?> lastError = const Value.absent()}) =>
      SyncQueueEntry(
        id: id ?? this.id,
        entityTable: entityTable ?? this.entityTable,
        rowId: rowId ?? this.rowId,
        operation: operation ?? this.operation,
        payload: payload.present ? payload.value : this.payload,
        createdAt: createdAt ?? this.createdAt,
        retryCount: retryCount ?? this.retryCount,
        lastError: lastError.present ? lastError.value : this.lastError,
      );
  SyncQueueEntry copyWithCompanion(SyncQueueEntriesCompanion data) {
    return SyncQueueEntry(
      id: data.id.present ? data.id.value : this.id,
      entityTable:
          data.entityTable.present ? data.entityTable.value : this.entityTable,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntry(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, entityTable, rowId, operation, payload,
      createdAt, retryCount, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueEntry &&
          other.id == this.id &&
          other.entityTable == this.entityTable &&
          other.rowId == this.rowId &&
          other.operation == this.operation &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError);
}

class SyncQueueEntriesCompanion extends UpdateCompanion<SyncQueueEntry> {
  final Value<String> id;
  final Value<String> entityTable;
  final Value<String> rowId;
  final Value<String> operation;
  final Value<String?> payload;
  final Value<DateTime> createdAt;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> rowid;
  const SyncQueueEntriesCompanion({
    this.id = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.rowId = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueEntriesCompanion.insert({
    required String id,
    required String entityTable,
    required String rowId,
    required String operation,
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entityTable = Value(entityTable),
        rowId = Value(rowId),
        operation = Value(operation);
  static Insertable<SyncQueueEntry> custom({
    Expression<String>? id,
    Expression<String>? entityTable,
    Expression<String>? rowId,
    Expression<String>? operation,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entityTable != null) 'entity_table': entityTable,
      if (rowId != null) 'row_id': rowId,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? entityTable,
      Value<String>? rowId,
      Value<String>? operation,
      Value<String?>? payload,
      Value<DateTime>? createdAt,
      Value<int>? retryCount,
      Value<String?>? lastError,
      Value<int>? rowid}) {
    return SyncQueueEntriesCompanion(
      id: id ?? this.id,
      entityTable: entityTable ?? this.entityTable,
      rowId: rowId ?? this.rowId,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueEntriesCompanion(')
          ..write('id: $id, ')
          ..write('entityTable: $entityTable, ')
          ..write('rowId: $rowId, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MesasTable mesas = $MesasTable(this);
  late final $TournamentsTable tournaments = $TournamentsTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $EnrollmentsTable enrollments = $EnrollmentsTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  late final $ResultsTable results = $ResultsTable(this);
  late final $StandingsTable standings = $StandingsTable(this);
  late final $SyncQueueEntriesTable syncQueueEntries =
      $SyncQueueEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mesas,
        tournaments,
        players,
        enrollments,
        matches,
        results,
        standings,
        syncQueueEntries
      ];
}

typedef $$MesasTableCreateCompanionBuilder = MesasCompanion Function({
  required String id,
  required String name,
  Value<String?> description,
  required String createdBy,
  Value<DateTime?> createdAt,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});
typedef $$MesasTableUpdateCompanionBuilder = MesasCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> description,
  Value<String> createdBy,
  Value<DateTime?> createdAt,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});

class $$MesasTableFilterComposer extends Composer<_$AppDatabase, $MesasTable> {
  $$MesasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));
}

class $$MesasTableOrderingComposer
    extends Composer<_$AppDatabase, $MesasTable> {
  $$MesasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));
}

class $$MesasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MesasTable> {
  $$MesasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);
}

class $$MesasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MesasTable,
    Mesa,
    $$MesasTableFilterComposer,
    $$MesasTableOrderingComposer,
    $$MesasTableAnnotationComposer,
    $$MesasTableCreateCompanionBuilder,
    $$MesasTableUpdateCompanionBuilder,
    (Mesa, BaseReferences<_$AppDatabase, $MesasTable, Mesa>),
    Mesa,
    PrefetchHooks Function()> {
  $$MesasTableTableManager(_$AppDatabase db, $MesasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MesasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MesasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MesasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MesasCompanion(
            id: id,
            name: name,
            description: description,
            createdBy: createdBy,
            createdAt: createdAt,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> description = const Value.absent(),
            required String createdBy,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MesasCompanion.insert(
            id: id,
            name: name,
            description: description,
            createdBy: createdBy,
            createdAt: createdAt,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MesasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MesasTable,
    Mesa,
    $$MesasTableFilterComposer,
    $$MesasTableOrderingComposer,
    $$MesasTableAnnotationComposer,
    $$MesasTableCreateCompanionBuilder,
    $$MesasTableUpdateCompanionBuilder,
    (Mesa, BaseReferences<_$AppDatabase, $MesasTable, Mesa>),
    Mesa,
    PrefetchHooks Function()>;
typedef $$TournamentsTableCreateCompanionBuilder = TournamentsCompanion
    Function({
  required String id,
  required String name,
  required String mode,
  required String status,
  Value<String?> description,
  required DateTime startDate,
  required DateTime endDate,
  required String createdBy,
  Value<DateTime?> createdAt,
  Value<String?> mesaId,
  Value<String?> color,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});
typedef $$TournamentsTableUpdateCompanionBuilder = TournamentsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> mode,
  Value<String> status,
  Value<String?> description,
  Value<DateTime> startDate,
  Value<DateTime> endDate,
  Value<String> createdBy,
  Value<DateTime?> createdAt,
  Value<String?> mesaId,
  Value<String?> color,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});

class $$TournamentsTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mesaId => $composableBuilder(
      column: $table.mesaId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));
}

class $$TournamentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdBy => $composableBuilder(
      column: $table.createdBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mesaId => $composableBuilder(
      column: $table.mesaId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));
}

class $$TournamentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get mesaId =>
      $composableBuilder(column: $table.mesaId, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);
}

class $$TournamentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TournamentsTable,
    Tournament,
    $$TournamentsTableFilterComposer,
    $$TournamentsTableOrderingComposer,
    $$TournamentsTableAnnotationComposer,
    $$TournamentsTableCreateCompanionBuilder,
    $$TournamentsTableUpdateCompanionBuilder,
    (Tournament, BaseReferences<_$AppDatabase, $TournamentsTable, Tournament>),
    Tournament,
    PrefetchHooks Function()> {
  $$TournamentsTableTableManager(_$AppDatabase db, $TournamentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TournamentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TournamentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> mode = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime> endDate = const Value.absent(),
            Value<String> createdBy = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> mesaId = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TournamentsCompanion(
            id: id,
            name: name,
            mode: mode,
            status: status,
            description: description,
            startDate: startDate,
            endDate: endDate,
            createdBy: createdBy,
            createdAt: createdAt,
            mesaId: mesaId,
            color: color,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String mode,
            required String status,
            Value<String?> description = const Value.absent(),
            required DateTime startDate,
            required DateTime endDate,
            required String createdBy,
            Value<DateTime?> createdAt = const Value.absent(),
            Value<String?> mesaId = const Value.absent(),
            Value<String?> color = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TournamentsCompanion.insert(
            id: id,
            name: name,
            mode: mode,
            status: status,
            description: description,
            startDate: startDate,
            endDate: endDate,
            createdBy: createdBy,
            createdAt: createdAt,
            mesaId: mesaId,
            color: color,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TournamentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TournamentsTable,
    Tournament,
    $$TournamentsTableFilterComposer,
    $$TournamentsTableOrderingComposer,
    $$TournamentsTableAnnotationComposer,
    $$TournamentsTableCreateCompanionBuilder,
    $$TournamentsTableUpdateCompanionBuilder,
    (Tournament, BaseReferences<_$AppDatabase, $TournamentsTable, Tournament>),
    Tournament,
    PrefetchHooks Function()>;
typedef $$PlayersTableCreateCompanionBuilder = PlayersCompanion Function({
  required String id,
  required String name,
  Value<String?> email,
  Value<String?> phone,
  Value<DateTime?> birthDate,
  Value<String?> photoUrl,
  Value<DateTime?> createdAt,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});
typedef $$PlayersTableUpdateCompanionBuilder = PlayersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> email,
  Value<String?> phone,
  Value<DateTime?> birthDate,
  Value<String?> photoUrl,
  Value<DateTime?> createdAt,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get photoUrl => $composableBuilder(
      column: $table.photoUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get photoUrl =>
      $composableBuilder(column: $table.photoUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);
}

class $$PlayersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
    Player,
    PrefetchHooks Function()> {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersCompanion(
            id: id,
            name: name,
            email: email,
            phone: phone,
            birthDate: birthDate,
            photoUrl: photoUrl,
            createdAt: createdAt,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> email = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<String?> photoUrl = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              PlayersCompanion.insert(
            id: id,
            name: name,
            email: email,
            phone: phone,
            birthDate: birthDate,
            photoUrl: photoUrl,
            createdAt: createdAt,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlayersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlayersTable,
    Player,
    $$PlayersTableFilterComposer,
    $$PlayersTableOrderingComposer,
    $$PlayersTableAnnotationComposer,
    $$PlayersTableCreateCompanionBuilder,
    $$PlayersTableUpdateCompanionBuilder,
    (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
    Player,
    PrefetchHooks Function()>;
typedef $$EnrollmentsTableCreateCompanionBuilder = EnrollmentsCompanion
    Function({
  required String id,
  required String tournamentId,
  required String playerId,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});
typedef $$EnrollmentsTableUpdateCompanionBuilder = EnrollmentsCompanion
    Function({
  Value<String> id,
  Value<String> tournamentId,
  Value<String> playerId,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});

class $$EnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));
}

class $$EnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));
}

class $$EnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);
}

class $$EnrollmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EnrollmentsTable,
    Enrollment,
    $$EnrollmentsTableFilterComposer,
    $$EnrollmentsTableOrderingComposer,
    $$EnrollmentsTableAnnotationComposer,
    $$EnrollmentsTableCreateCompanionBuilder,
    $$EnrollmentsTableUpdateCompanionBuilder,
    (Enrollment, BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment>),
    Enrollment,
    PrefetchHooks Function()> {
  $$EnrollmentsTableTableManager(_$AppDatabase db, $EnrollmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tournamentId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnrollmentsCompanion(
            id: id,
            tournamentId: tournamentId,
            playerId: playerId,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tournamentId,
            required String playerId,
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnrollmentsCompanion.insert(
            id: id,
            tournamentId: tournamentId,
            playerId: playerId,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EnrollmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EnrollmentsTable,
    Enrollment,
    $$EnrollmentsTableFilterComposer,
    $$EnrollmentsTableOrderingComposer,
    $$EnrollmentsTableAnnotationComposer,
    $$EnrollmentsTableCreateCompanionBuilder,
    $$EnrollmentsTableUpdateCompanionBuilder,
    (Enrollment, BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment>),
    Enrollment,
    PrefetchHooks Function()>;
typedef $$MatchesTableCreateCompanionBuilder = MatchesCompanion Function({
  required String id,
  required String tournamentId,
  required String homePlayerId,
  required String awayPlayerId,
  required String homePlayerName,
  required String awayPlayerName,
  Value<int?> homeScore,
  Value<int?> awayScore,
  required String status,
  Value<DateTime?> scheduledAt,
  Value<String?> round,
  Value<int?> matchNumber,
  Value<int?> mesaOrder,
  Value<DateTime?> createdAt,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});
typedef $$MatchesTableUpdateCompanionBuilder = MatchesCompanion Function({
  Value<String> id,
  Value<String> tournamentId,
  Value<String> homePlayerId,
  Value<String> awayPlayerId,
  Value<String> homePlayerName,
  Value<String> awayPlayerName,
  Value<int?> homeScore,
  Value<int?> awayScore,
  Value<String> status,
  Value<DateTime?> scheduledAt,
  Value<String?> round,
  Value<int?> matchNumber,
  Value<int?> mesaOrder,
  Value<DateTime?> createdAt,
  Value<bool> dirty,
  Value<bool> deletedLocally,
  Value<int> rowid,
});

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homePlayerId => $composableBuilder(
      column: $table.homePlayerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get awayPlayerId => $composableBuilder(
      column: $table.awayPlayerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homePlayerName => $composableBuilder(
      column: $table.homePlayerName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get awayPlayerName => $composableBuilder(
      column: $table.awayPlayerName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get homeScore => $composableBuilder(
      column: $table.homeScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get awayScore => $composableBuilder(
      column: $table.awayScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get round => $composableBuilder(
      column: $table.round, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get matchNumber => $composableBuilder(
      column: $table.matchNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get mesaOrder => $composableBuilder(
      column: $table.mesaOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnFilters(column));
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homePlayerId => $composableBuilder(
      column: $table.homePlayerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get awayPlayerId => $composableBuilder(
      column: $table.awayPlayerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homePlayerName => $composableBuilder(
      column: $table.homePlayerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get awayPlayerName => $composableBuilder(
      column: $table.awayPlayerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get homeScore => $composableBuilder(
      column: $table.homeScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get awayScore => $composableBuilder(
      column: $table.awayScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get round => $composableBuilder(
      column: $table.round, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get matchNumber => $composableBuilder(
      column: $table.matchNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get mesaOrder => $composableBuilder(
      column: $table.mesaOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally,
      builder: (column) => ColumnOrderings(column));
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => column);

  GeneratedColumn<String> get homePlayerId => $composableBuilder(
      column: $table.homePlayerId, builder: (column) => column);

  GeneratedColumn<String> get awayPlayerId => $composableBuilder(
      column: $table.awayPlayerId, builder: (column) => column);

  GeneratedColumn<String> get homePlayerName => $composableBuilder(
      column: $table.homePlayerName, builder: (column) => column);

  GeneratedColumn<String> get awayPlayerName => $composableBuilder(
      column: $table.awayPlayerName, builder: (column) => column);

  GeneratedColumn<int> get homeScore =>
      $composableBuilder(column: $table.homeScore, builder: (column) => column);

  GeneratedColumn<int> get awayScore =>
      $composableBuilder(column: $table.awayScore, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<String> get round =>
      $composableBuilder(column: $table.round, builder: (column) => column);

  GeneratedColumn<int> get matchNumber => $composableBuilder(
      column: $table.matchNumber, builder: (column) => column);

  GeneratedColumn<int> get mesaOrder =>
      $composableBuilder(column: $table.mesaOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);

  GeneratedColumn<bool> get deletedLocally => $composableBuilder(
      column: $table.deletedLocally, builder: (column) => column);
}

class $$MatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MatchesTable,
    MatchRow,
    $$MatchesTableFilterComposer,
    $$MatchesTableOrderingComposer,
    $$MatchesTableAnnotationComposer,
    $$MatchesTableCreateCompanionBuilder,
    $$MatchesTableUpdateCompanionBuilder,
    (MatchRow, BaseReferences<_$AppDatabase, $MatchesTable, MatchRow>),
    MatchRow,
    PrefetchHooks Function()> {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tournamentId = const Value.absent(),
            Value<String> homePlayerId = const Value.absent(),
            Value<String> awayPlayerId = const Value.absent(),
            Value<String> homePlayerName = const Value.absent(),
            Value<String> awayPlayerName = const Value.absent(),
            Value<int?> homeScore = const Value.absent(),
            Value<int?> awayScore = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String?> round = const Value.absent(),
            Value<int?> matchNumber = const Value.absent(),
            Value<int?> mesaOrder = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchesCompanion(
            id: id,
            tournamentId: tournamentId,
            homePlayerId: homePlayerId,
            awayPlayerId: awayPlayerId,
            homePlayerName: homePlayerName,
            awayPlayerName: awayPlayerName,
            homeScore: homeScore,
            awayScore: awayScore,
            status: status,
            scheduledAt: scheduledAt,
            round: round,
            matchNumber: matchNumber,
            mesaOrder: mesaOrder,
            createdAt: createdAt,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tournamentId,
            required String homePlayerId,
            required String awayPlayerId,
            required String homePlayerName,
            required String awayPlayerName,
            Value<int?> homeScore = const Value.absent(),
            Value<int?> awayScore = const Value.absent(),
            required String status,
            Value<DateTime?> scheduledAt = const Value.absent(),
            Value<String?> round = const Value.absent(),
            Value<int?> matchNumber = const Value.absent(),
            Value<int?> mesaOrder = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<bool> deletedLocally = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MatchesCompanion.insert(
            id: id,
            tournamentId: tournamentId,
            homePlayerId: homePlayerId,
            awayPlayerId: awayPlayerId,
            homePlayerName: homePlayerName,
            awayPlayerName: awayPlayerName,
            homeScore: homeScore,
            awayScore: awayScore,
            status: status,
            scheduledAt: scheduledAt,
            round: round,
            matchNumber: matchNumber,
            mesaOrder: mesaOrder,
            createdAt: createdAt,
            dirty: dirty,
            deletedLocally: deletedLocally,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MatchesTable,
    MatchRow,
    $$MatchesTableFilterComposer,
    $$MatchesTableOrderingComposer,
    $$MatchesTableAnnotationComposer,
    $$MatchesTableCreateCompanionBuilder,
    $$MatchesTableUpdateCompanionBuilder,
    (MatchRow, BaseReferences<_$AppDatabase, $MatchesTable, MatchRow>),
    MatchRow,
    PrefetchHooks Function()>;
typedef $$ResultsTableCreateCompanionBuilder = ResultsCompanion Function({
  required String id,
  required String matchId,
  required String tournamentId,
  required String homePlayerId,
  required String awayPlayerId,
  required int homeScore,
  required int awayScore,
  Value<String?> notes,
  required String registeredBy,
  required DateTime registeredAt,
  Value<bool> dirty,
  Value<int> rowid,
});
typedef $$ResultsTableUpdateCompanionBuilder = ResultsCompanion Function({
  Value<String> id,
  Value<String> matchId,
  Value<String> tournamentId,
  Value<String> homePlayerId,
  Value<String> awayPlayerId,
  Value<int> homeScore,
  Value<int> awayScore,
  Value<String?> notes,
  Value<String> registeredBy,
  Value<DateTime> registeredAt,
  Value<bool> dirty,
  Value<int> rowid,
});

class $$ResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get homePlayerId => $composableBuilder(
      column: $table.homePlayerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get awayPlayerId => $composableBuilder(
      column: $table.awayPlayerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get homeScore => $composableBuilder(
      column: $table.homeScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get awayScore => $composableBuilder(
      column: $table.awayScore, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get registeredBy => $composableBuilder(
      column: $table.registeredBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));
}

class $$ResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get matchId => $composableBuilder(
      column: $table.matchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get homePlayerId => $composableBuilder(
      column: $table.homePlayerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get awayPlayerId => $composableBuilder(
      column: $table.awayPlayerId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get homeScore => $composableBuilder(
      column: $table.homeScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get awayScore => $composableBuilder(
      column: $table.awayScore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get registeredBy => $composableBuilder(
      column: $table.registeredBy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));
}

class $$ResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get matchId =>
      $composableBuilder(column: $table.matchId, builder: (column) => column);

  GeneratedColumn<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => column);

  GeneratedColumn<String> get homePlayerId => $composableBuilder(
      column: $table.homePlayerId, builder: (column) => column);

  GeneratedColumn<String> get awayPlayerId => $composableBuilder(
      column: $table.awayPlayerId, builder: (column) => column);

  GeneratedColumn<int> get homeScore =>
      $composableBuilder(column: $table.homeScore, builder: (column) => column);

  GeneratedColumn<int> get awayScore =>
      $composableBuilder(column: $table.awayScore, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get registeredBy => $composableBuilder(
      column: $table.registeredBy, builder: (column) => column);

  GeneratedColumn<DateTime> get registeredAt => $composableBuilder(
      column: $table.registeredAt, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$ResultsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ResultsTable,
    Result,
    $$ResultsTableFilterComposer,
    $$ResultsTableOrderingComposer,
    $$ResultsTableAnnotationComposer,
    $$ResultsTableCreateCompanionBuilder,
    $$ResultsTableUpdateCompanionBuilder,
    (Result, BaseReferences<_$AppDatabase, $ResultsTable, Result>),
    Result,
    PrefetchHooks Function()> {
  $$ResultsTableTableManager(_$AppDatabase db, $ResultsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> matchId = const Value.absent(),
            Value<String> tournamentId = const Value.absent(),
            Value<String> homePlayerId = const Value.absent(),
            Value<String> awayPlayerId = const Value.absent(),
            Value<int> homeScore = const Value.absent(),
            Value<int> awayScore = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> registeredBy = const Value.absent(),
            Value<DateTime> registeredAt = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ResultsCompanion(
            id: id,
            matchId: matchId,
            tournamentId: tournamentId,
            homePlayerId: homePlayerId,
            awayPlayerId: awayPlayerId,
            homeScore: homeScore,
            awayScore: awayScore,
            notes: notes,
            registeredBy: registeredBy,
            registeredAt: registeredAt,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String matchId,
            required String tournamentId,
            required String homePlayerId,
            required String awayPlayerId,
            required int homeScore,
            required int awayScore,
            Value<String?> notes = const Value.absent(),
            required String registeredBy,
            required DateTime registeredAt,
            Value<bool> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ResultsCompanion.insert(
            id: id,
            matchId: matchId,
            tournamentId: tournamentId,
            homePlayerId: homePlayerId,
            awayPlayerId: awayPlayerId,
            homeScore: homeScore,
            awayScore: awayScore,
            notes: notes,
            registeredBy: registeredBy,
            registeredAt: registeredAt,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ResultsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ResultsTable,
    Result,
    $$ResultsTableFilterComposer,
    $$ResultsTableOrderingComposer,
    $$ResultsTableAnnotationComposer,
    $$ResultsTableCreateCompanionBuilder,
    $$ResultsTableUpdateCompanionBuilder,
    (Result, BaseReferences<_$AppDatabase, $ResultsTable, Result>),
    Result,
    PrefetchHooks Function()>;
typedef $$StandingsTableCreateCompanionBuilder = StandingsCompanion Function({
  required String id,
  required String tournamentId,
  required String playerId,
  required String playerName,
  Value<int> played,
  Value<int> won,
  Value<int> drawn,
  Value<int> lost,
  Value<int> goalsFor,
  Value<int> goalsAgainst,
  Value<int> points,
  Value<int?> manualRank,
  Value<bool> dirty,
  Value<int> rowid,
});
typedef $$StandingsTableUpdateCompanionBuilder = StandingsCompanion Function({
  Value<String> id,
  Value<String> tournamentId,
  Value<String> playerId,
  Value<String> playerName,
  Value<int> played,
  Value<int> won,
  Value<int> drawn,
  Value<int> lost,
  Value<int> goalsFor,
  Value<int> goalsAgainst,
  Value<int> points,
  Value<int?> manualRank,
  Value<bool> dirty,
  Value<int> rowid,
});

class $$StandingsTableFilterComposer
    extends Composer<_$AppDatabase, $StandingsTable> {
  $$StandingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get playerName => $composableBuilder(
      column: $table.playerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get played => $composableBuilder(
      column: $table.played, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get won => $composableBuilder(
      column: $table.won, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get drawn => $composableBuilder(
      column: $table.drawn, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lost => $composableBuilder(
      column: $table.lost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goalsFor => $composableBuilder(
      column: $table.goalsFor, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get goalsAgainst => $composableBuilder(
      column: $table.goalsAgainst, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get manualRank => $composableBuilder(
      column: $table.manualRank, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnFilters(column));
}

class $$StandingsTableOrderingComposer
    extends Composer<_$AppDatabase, $StandingsTable> {
  $$StandingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerId => $composableBuilder(
      column: $table.playerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get playerName => $composableBuilder(
      column: $table.playerName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get played => $composableBuilder(
      column: $table.played, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get won => $composableBuilder(
      column: $table.won, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get drawn => $composableBuilder(
      column: $table.drawn, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lost => $composableBuilder(
      column: $table.lost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goalsFor => $composableBuilder(
      column: $table.goalsFor, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get goalsAgainst => $composableBuilder(
      column: $table.goalsAgainst,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get points => $composableBuilder(
      column: $table.points, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get manualRank => $composableBuilder(
      column: $table.manualRank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get dirty => $composableBuilder(
      column: $table.dirty, builder: (column) => ColumnOrderings(column));
}

class $$StandingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StandingsTable> {
  $$StandingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tournamentId => $composableBuilder(
      column: $table.tournamentId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get playerName => $composableBuilder(
      column: $table.playerName, builder: (column) => column);

  GeneratedColumn<int> get played =>
      $composableBuilder(column: $table.played, builder: (column) => column);

  GeneratedColumn<int> get won =>
      $composableBuilder(column: $table.won, builder: (column) => column);

  GeneratedColumn<int> get drawn =>
      $composableBuilder(column: $table.drawn, builder: (column) => column);

  GeneratedColumn<int> get lost =>
      $composableBuilder(column: $table.lost, builder: (column) => column);

  GeneratedColumn<int> get goalsFor =>
      $composableBuilder(column: $table.goalsFor, builder: (column) => column);

  GeneratedColumn<int> get goalsAgainst => $composableBuilder(
      column: $table.goalsAgainst, builder: (column) => column);

  GeneratedColumn<int> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  GeneratedColumn<int> get manualRank => $composableBuilder(
      column: $table.manualRank, builder: (column) => column);

  GeneratedColumn<bool> get dirty =>
      $composableBuilder(column: $table.dirty, builder: (column) => column);
}

class $$StandingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StandingsTable,
    Standing,
    $$StandingsTableFilterComposer,
    $$StandingsTableOrderingComposer,
    $$StandingsTableAnnotationComposer,
    $$StandingsTableCreateCompanionBuilder,
    $$StandingsTableUpdateCompanionBuilder,
    (Standing, BaseReferences<_$AppDatabase, $StandingsTable, Standing>),
    Standing,
    PrefetchHooks Function()> {
  $$StandingsTableTableManager(_$AppDatabase db, $StandingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StandingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StandingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StandingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> tournamentId = const Value.absent(),
            Value<String> playerId = const Value.absent(),
            Value<String> playerName = const Value.absent(),
            Value<int> played = const Value.absent(),
            Value<int> won = const Value.absent(),
            Value<int> drawn = const Value.absent(),
            Value<int> lost = const Value.absent(),
            Value<int> goalsFor = const Value.absent(),
            Value<int> goalsAgainst = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<int?> manualRank = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StandingsCompanion(
            id: id,
            tournamentId: tournamentId,
            playerId: playerId,
            playerName: playerName,
            played: played,
            won: won,
            drawn: drawn,
            lost: lost,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
            points: points,
            manualRank: manualRank,
            dirty: dirty,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String tournamentId,
            required String playerId,
            required String playerName,
            Value<int> played = const Value.absent(),
            Value<int> won = const Value.absent(),
            Value<int> drawn = const Value.absent(),
            Value<int> lost = const Value.absent(),
            Value<int> goalsFor = const Value.absent(),
            Value<int> goalsAgainst = const Value.absent(),
            Value<int> points = const Value.absent(),
            Value<int?> manualRank = const Value.absent(),
            Value<bool> dirty = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StandingsCompanion.insert(
            id: id,
            tournamentId: tournamentId,
            playerId: playerId,
            playerName: playerName,
            played: played,
            won: won,
            drawn: drawn,
            lost: lost,
            goalsFor: goalsFor,
            goalsAgainst: goalsAgainst,
            points: points,
            manualRank: manualRank,
            dirty: dirty,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StandingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StandingsTable,
    Standing,
    $$StandingsTableFilterComposer,
    $$StandingsTableOrderingComposer,
    $$StandingsTableAnnotationComposer,
    $$StandingsTableCreateCompanionBuilder,
    $$StandingsTableUpdateCompanionBuilder,
    (Standing, BaseReferences<_$AppDatabase, $StandingsTable, Standing>),
    Standing,
    PrefetchHooks Function()>;
typedef $$SyncQueueEntriesTableCreateCompanionBuilder
    = SyncQueueEntriesCompanion Function({
  required String id,
  required String entityTable,
  required String rowId,
  required String operation,
  Value<String?> payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> rowid,
});
typedef $$SyncQueueEntriesTableUpdateCompanionBuilder
    = SyncQueueEntriesCompanion Function({
  Value<String> id,
  Value<String> entityTable,
  Value<String> rowId,
  Value<String> operation,
  Value<String?> payload,
  Value<DateTime> createdAt,
  Value<int> retryCount,
  Value<String?> lastError,
  Value<int> rowid,
});

class $$SyncQueueEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnFilters(column));
}

class $$SyncQueueEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rowId => $composableBuilder(
      column: $table.rowId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get operation => $composableBuilder(
      column: $table.operation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastError => $composableBuilder(
      column: $table.lastError, builder: (column) => ColumnOrderings(column));
}

class $$SyncQueueEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueEntriesTable> {
  $$SyncQueueEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
      column: $table.entityTable, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$SyncQueueEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncQueueEntriesTable,
    SyncQueueEntry,
    $$SyncQueueEntriesTableFilterComposer,
    $$SyncQueueEntriesTableOrderingComposer,
    $$SyncQueueEntriesTableAnnotationComposer,
    $$SyncQueueEntriesTableCreateCompanionBuilder,
    $$SyncQueueEntriesTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()> {
  $$SyncQueueEntriesTableTableManager(
      _$AppDatabase db, $SyncQueueEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entityTable = const Value.absent(),
            Value<String> rowId = const Value.absent(),
            Value<String> operation = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueEntriesCompanion(
            id: id,
            entityTable: entityTable,
            rowId: rowId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entityTable,
            required String rowId,
            required String operation,
            Value<String?> payload = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<String?> lastError = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncQueueEntriesCompanion.insert(
            id: id,
            entityTable: entityTable,
            rowId: rowId,
            operation: operation,
            payload: payload,
            createdAt: createdAt,
            retryCount: retryCount,
            lastError: lastError,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncQueueEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncQueueEntriesTable,
    SyncQueueEntry,
    $$SyncQueueEntriesTableFilterComposer,
    $$SyncQueueEntriesTableOrderingComposer,
    $$SyncQueueEntriesTableAnnotationComposer,
    $$SyncQueueEntriesTableCreateCompanionBuilder,
    $$SyncQueueEntriesTableUpdateCompanionBuilder,
    (
      SyncQueueEntry,
      BaseReferences<_$AppDatabase, $SyncQueueEntriesTable, SyncQueueEntry>
    ),
    SyncQueueEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MesasTableTableManager get mesas =>
      $$MesasTableTableManager(_db, _db.mesas);
  $$TournamentsTableTableManager get tournaments =>
      $$TournamentsTableTableManager(_db, _db.tournaments);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$EnrollmentsTableTableManager get enrollments =>
      $$EnrollmentsTableTableManager(_db, _db.enrollments);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
  $$ResultsTableTableManager get results =>
      $$ResultsTableTableManager(_db, _db.results);
  $$StandingsTableTableManager get standings =>
      $$StandingsTableTableManager(_db, _db.standings);
  $$SyncQueueEntriesTableTableManager get syncQueueEntries =>
      $$SyncQueueEntriesTableTableManager(_db, _db.syncQueueEntries);
}

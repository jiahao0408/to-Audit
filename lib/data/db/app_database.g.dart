// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DaysTable extends Days with TableInfo<$DaysTable, DayData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DaysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DayStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DayStatus>($DaysTable.$converterstatus);
  static const VerificationMeta _openingFloatCentsMeta = const VerificationMeta(
    'openingFloatCents',
  );
  @override
  late final GeneratedColumn<int> openingFloatCents = GeneratedColumn<int>(
    'opening_float_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _countedCashCentsMeta = const VerificationMeta(
    'countedCashCents',
  );
  @override
  late final GeneratedColumn<int> countedCashCents = GeneratedColumn<int>(
    'counted_cash_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _denominationCountsMeta =
      const VerificationMeta('denominationCounts');
  @override
  late final GeneratedColumn<String> denominationCounts =
      GeneratedColumn<String>(
        'denomination_counts',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _terminalTotalCentsMeta =
      const VerificationMeta('terminalTotalCents');
  @override
  late final GeneratedColumn<int> terminalTotalCents = GeneratedColumn<int>(
    'terminal_total_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cashTipsCentsMeta = const VerificationMeta(
    'cashTipsCents',
  );
  @override
  late final GeneratedColumn<int> cashTipsCents = GeneratedColumn<int>(
    'cash_tips_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cardTipsCentsMeta = const VerificationMeta(
    'cardTipsCents',
  );
  @override
  late final GeneratedColumn<int> cardTipsCents = GeneratedColumn<int>(
    'card_tips_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cashDiffCentsMeta = const VerificationMeta(
    'cashDiffCents',
  );
  @override
  late final GeneratedColumn<int> cashDiffCents = GeneratedColumn<int>(
    'cash_diff_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardDiffCentsMeta = const VerificationMeta(
    'cardDiffCents',
  );
  @override
  late final GeneratedColumn<int> cardDiffCents = GeneratedColumn<int>(
    'card_diff_cents',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<String> closedAt = GeneratedColumn<String>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    date,
    status,
    openingFloatCents,
    countedCashCents,
    denominationCounts,
    terminalTotalCents,
    cashTipsCents,
    cardTipsCents,
    cashDiffCents,
    cardDiffCents,
    comment,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dia_caja';
  @override
  VerificationContext validateIntegrity(
    Insertable<DayData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('opening_float_cents')) {
      context.handle(
        _openingFloatCentsMeta,
        openingFloatCents.isAcceptableOrUnknown(
          data['opening_float_cents']!,
          _openingFloatCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingFloatCentsMeta);
    }
    if (data.containsKey('counted_cash_cents')) {
      context.handle(
        _countedCashCentsMeta,
        countedCashCents.isAcceptableOrUnknown(
          data['counted_cash_cents']!,
          _countedCashCentsMeta,
        ),
      );
    }
    if (data.containsKey('denomination_counts')) {
      context.handle(
        _denominationCountsMeta,
        denominationCounts.isAcceptableOrUnknown(
          data['denomination_counts']!,
          _denominationCountsMeta,
        ),
      );
    }
    if (data.containsKey('terminal_total_cents')) {
      context.handle(
        _terminalTotalCentsMeta,
        terminalTotalCents.isAcceptableOrUnknown(
          data['terminal_total_cents']!,
          _terminalTotalCentsMeta,
        ),
      );
    }
    if (data.containsKey('cash_tips_cents')) {
      context.handle(
        _cashTipsCentsMeta,
        cashTipsCents.isAcceptableOrUnknown(
          data['cash_tips_cents']!,
          _cashTipsCentsMeta,
        ),
      );
    }
    if (data.containsKey('card_tips_cents')) {
      context.handle(
        _cardTipsCentsMeta,
        cardTipsCents.isAcceptableOrUnknown(
          data['card_tips_cents']!,
          _cardTipsCentsMeta,
        ),
      );
    }
    if (data.containsKey('cash_diff_cents')) {
      context.handle(
        _cashDiffCentsMeta,
        cashDiffCents.isAcceptableOrUnknown(
          data['cash_diff_cents']!,
          _cashDiffCentsMeta,
        ),
      );
    }
    if (data.containsKey('card_diff_cents')) {
      context.handle(
        _cardDiffCentsMeta,
        cardDiffCents.isAcceptableOrUnknown(
          data['card_diff_cents']!,
          _cardDiffCentsMeta,
        ),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DayData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DayData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      status: $DaysTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      openingFloatCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_float_cents'],
      )!,
      countedCashCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}counted_cash_cents'],
      ),
      denominationCounts: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}denomination_counts'],
      ),
      terminalTotalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}terminal_total_cents'],
      ),
      cashTipsCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_tips_cents'],
      )!,
      cardTipsCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_tips_cents'],
      )!,
      cashDiffCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cash_diff_cents'],
      ),
      cardDiffCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_diff_cents'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $DaysTable createAlias(String alias) {
    return $DaysTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DayStatus, String, String> $converterstatus =
      const EnumNameConverter<DayStatus>(DayStatus.values);
}

class DayData extends DataClass implements Insertable<DayData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String date;
  final DayStatus status;
  final int openingFloatCents;
  final int? countedCashCents;
  final String? denominationCounts;
  final int? terminalTotalCents;
  final int cashTipsCents;
  final int cardTipsCents;
  final int? cashDiffCents;
  final int? cardDiffCents;
  final String? comment;
  final String? closedAt;
  const DayData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.date,
    required this.status,
    required this.openingFloatCents,
    this.countedCashCents,
    this.denominationCounts,
    this.terminalTotalCents,
    required this.cashTipsCents,
    required this.cardTipsCents,
    this.cashDiffCents,
    this.cardDiffCents,
    this.comment,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['date'] = Variable<String>(date);
    {
      map['status'] = Variable<String>(
        $DaysTable.$converterstatus.toSql(status),
      );
    }
    map['opening_float_cents'] = Variable<int>(openingFloatCents);
    if (!nullToAbsent || countedCashCents != null) {
      map['counted_cash_cents'] = Variable<int>(countedCashCents);
    }
    if (!nullToAbsent || denominationCounts != null) {
      map['denomination_counts'] = Variable<String>(denominationCounts);
    }
    if (!nullToAbsent || terminalTotalCents != null) {
      map['terminal_total_cents'] = Variable<int>(terminalTotalCents);
    }
    map['cash_tips_cents'] = Variable<int>(cashTipsCents);
    map['card_tips_cents'] = Variable<int>(cardTipsCents);
    if (!nullToAbsent || cashDiffCents != null) {
      map['cash_diff_cents'] = Variable<int>(cashDiffCents);
    }
    if (!nullToAbsent || cardDiffCents != null) {
      map['card_diff_cents'] = Variable<int>(cardDiffCents);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<String>(closedAt);
    }
    return map;
  }

  DaysCompanion toCompanion(bool nullToAbsent) {
    return DaysCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      date: Value(date),
      status: Value(status),
      openingFloatCents: Value(openingFloatCents),
      countedCashCents: countedCashCents == null && nullToAbsent
          ? const Value.absent()
          : Value(countedCashCents),
      denominationCounts: denominationCounts == null && nullToAbsent
          ? const Value.absent()
          : Value(denominationCounts),
      terminalTotalCents: terminalTotalCents == null && nullToAbsent
          ? const Value.absent()
          : Value(terminalTotalCents),
      cashTipsCents: Value(cashTipsCents),
      cardTipsCents: Value(cardTipsCents),
      cashDiffCents: cashDiffCents == null && nullToAbsent
          ? const Value.absent()
          : Value(cashDiffCents),
      cardDiffCents: cardDiffCents == null && nullToAbsent
          ? const Value.absent()
          : Value(cardDiffCents),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory DayData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DayData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      date: serializer.fromJson<String>(json['date']),
      status: $DaysTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      openingFloatCents: serializer.fromJson<int>(json['openingFloatCents']),
      countedCashCents: serializer.fromJson<int?>(json['countedCashCents']),
      denominationCounts: serializer.fromJson<String?>(
        json['denominationCounts'],
      ),
      terminalTotalCents: serializer.fromJson<int?>(json['terminalTotalCents']),
      cashTipsCents: serializer.fromJson<int>(json['cashTipsCents']),
      cardTipsCents: serializer.fromJson<int>(json['cardTipsCents']),
      cashDiffCents: serializer.fromJson<int?>(json['cashDiffCents']),
      cardDiffCents: serializer.fromJson<int?>(json['cardDiffCents']),
      comment: serializer.fromJson<String?>(json['comment']),
      closedAt: serializer.fromJson<String?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'date': serializer.toJson<String>(date),
      'status': serializer.toJson<String>(
        $DaysTable.$converterstatus.toJson(status),
      ),
      'openingFloatCents': serializer.toJson<int>(openingFloatCents),
      'countedCashCents': serializer.toJson<int?>(countedCashCents),
      'denominationCounts': serializer.toJson<String?>(denominationCounts),
      'terminalTotalCents': serializer.toJson<int?>(terminalTotalCents),
      'cashTipsCents': serializer.toJson<int>(cashTipsCents),
      'cardTipsCents': serializer.toJson<int>(cardTipsCents),
      'cashDiffCents': serializer.toJson<int?>(cashDiffCents),
      'cardDiffCents': serializer.toJson<int?>(cardDiffCents),
      'comment': serializer.toJson<String?>(comment),
      'closedAt': serializer.toJson<String?>(closedAt),
    };
  }

  DayData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? date,
    DayStatus? status,
    int? openingFloatCents,
    Value<int?> countedCashCents = const Value.absent(),
    Value<String?> denominationCounts = const Value.absent(),
    Value<int?> terminalTotalCents = const Value.absent(),
    int? cashTipsCents,
    int? cardTipsCents,
    Value<int?> cashDiffCents = const Value.absent(),
    Value<int?> cardDiffCents = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    Value<String?> closedAt = const Value.absent(),
  }) => DayData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    date: date ?? this.date,
    status: status ?? this.status,
    openingFloatCents: openingFloatCents ?? this.openingFloatCents,
    countedCashCents: countedCashCents.present
        ? countedCashCents.value
        : this.countedCashCents,
    denominationCounts: denominationCounts.present
        ? denominationCounts.value
        : this.denominationCounts,
    terminalTotalCents: terminalTotalCents.present
        ? terminalTotalCents.value
        : this.terminalTotalCents,
    cashTipsCents: cashTipsCents ?? this.cashTipsCents,
    cardTipsCents: cardTipsCents ?? this.cardTipsCents,
    cashDiffCents: cashDiffCents.present
        ? cashDiffCents.value
        : this.cashDiffCents,
    cardDiffCents: cardDiffCents.present
        ? cardDiffCents.value
        : this.cardDiffCents,
    comment: comment.present ? comment.value : this.comment,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  DayData copyWithCompanion(DaysCompanion data) {
    return DayData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      openingFloatCents: data.openingFloatCents.present
          ? data.openingFloatCents.value
          : this.openingFloatCents,
      countedCashCents: data.countedCashCents.present
          ? data.countedCashCents.value
          : this.countedCashCents,
      denominationCounts: data.denominationCounts.present
          ? data.denominationCounts.value
          : this.denominationCounts,
      terminalTotalCents: data.terminalTotalCents.present
          ? data.terminalTotalCents.value
          : this.terminalTotalCents,
      cashTipsCents: data.cashTipsCents.present
          ? data.cashTipsCents.value
          : this.cashTipsCents,
      cardTipsCents: data.cardTipsCents.present
          ? data.cardTipsCents.value
          : this.cardTipsCents,
      cashDiffCents: data.cashDiffCents.present
          ? data.cashDiffCents.value
          : this.cashDiffCents,
      cardDiffCents: data.cardDiffCents.present
          ? data.cardDiffCents.value
          : this.cardDiffCents,
      comment: data.comment.present ? data.comment.value : this.comment,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DayData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('openingFloatCents: $openingFloatCents, ')
          ..write('countedCashCents: $countedCashCents, ')
          ..write('denominationCounts: $denominationCounts, ')
          ..write('terminalTotalCents: $terminalTotalCents, ')
          ..write('cashTipsCents: $cashTipsCents, ')
          ..write('cardTipsCents: $cardTipsCents, ')
          ..write('cashDiffCents: $cashDiffCents, ')
          ..write('cardDiffCents: $cardDiffCents, ')
          ..write('comment: $comment, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    date,
    status,
    openingFloatCents,
    countedCashCents,
    denominationCounts,
    terminalTotalCents,
    cashTipsCents,
    cardTipsCents,
    cashDiffCents,
    cardDiffCents,
    comment,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DayData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.date == this.date &&
          other.status == this.status &&
          other.openingFloatCents == this.openingFloatCents &&
          other.countedCashCents == this.countedCashCents &&
          other.denominationCounts == this.denominationCounts &&
          other.terminalTotalCents == this.terminalTotalCents &&
          other.cashTipsCents == this.cashTipsCents &&
          other.cardTipsCents == this.cardTipsCents &&
          other.cashDiffCents == this.cashDiffCents &&
          other.cardDiffCents == this.cardDiffCents &&
          other.comment == this.comment &&
          other.closedAt == this.closedAt);
}

class DaysCompanion extends UpdateCompanion<DayData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> date;
  final Value<DayStatus> status;
  final Value<int> openingFloatCents;
  final Value<int?> countedCashCents;
  final Value<String?> denominationCounts;
  final Value<int?> terminalTotalCents;
  final Value<int> cashTipsCents;
  final Value<int> cardTipsCents;
  final Value<int?> cashDiffCents;
  final Value<int?> cardDiffCents;
  final Value<String?> comment;
  final Value<String?> closedAt;
  final Value<int> rowid;
  const DaysCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.openingFloatCents = const Value.absent(),
    this.countedCashCents = const Value.absent(),
    this.denominationCounts = const Value.absent(),
    this.terminalTotalCents = const Value.absent(),
    this.cashTipsCents = const Value.absent(),
    this.cardTipsCents = const Value.absent(),
    this.cashDiffCents = const Value.absent(),
    this.cardDiffCents = const Value.absent(),
    this.comment = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DaysCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String date,
    required DayStatus status,
    required int openingFloatCents,
    this.countedCashCents = const Value.absent(),
    this.denominationCounts = const Value.absent(),
    this.terminalTotalCents = const Value.absent(),
    this.cashTipsCents = const Value.absent(),
    this.cardTipsCents = const Value.absent(),
    this.cashDiffCents = const Value.absent(),
    this.cardDiffCents = const Value.absent(),
    this.comment = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       status = Value(status),
       openingFloatCents = Value(openingFloatCents);
  static Insertable<DayData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? date,
    Expression<String>? status,
    Expression<int>? openingFloatCents,
    Expression<int>? countedCashCents,
    Expression<String>? denominationCounts,
    Expression<int>? terminalTotalCents,
    Expression<int>? cashTipsCents,
    Expression<int>? cardTipsCents,
    Expression<int>? cashDiffCents,
    Expression<int>? cardDiffCents,
    Expression<String>? comment,
    Expression<String>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (openingFloatCents != null) 'opening_float_cents': openingFloatCents,
      if (countedCashCents != null) 'counted_cash_cents': countedCashCents,
      if (denominationCounts != null) 'denomination_counts': denominationCounts,
      if (terminalTotalCents != null)
        'terminal_total_cents': terminalTotalCents,
      if (cashTipsCents != null) 'cash_tips_cents': cashTipsCents,
      if (cardTipsCents != null) 'card_tips_cents': cardTipsCents,
      if (cashDiffCents != null) 'cash_diff_cents': cashDiffCents,
      if (cardDiffCents != null) 'card_diff_cents': cardDiffCents,
      if (comment != null) 'comment': comment,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DaysCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? date,
    Value<DayStatus>? status,
    Value<int>? openingFloatCents,
    Value<int?>? countedCashCents,
    Value<String?>? denominationCounts,
    Value<int?>? terminalTotalCents,
    Value<int>? cashTipsCents,
    Value<int>? cardTipsCents,
    Value<int?>? cashDiffCents,
    Value<int?>? cardDiffCents,
    Value<String?>? comment,
    Value<String?>? closedAt,
    Value<int>? rowid,
  }) {
    return DaysCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      date: date ?? this.date,
      status: status ?? this.status,
      openingFloatCents: openingFloatCents ?? this.openingFloatCents,
      countedCashCents: countedCashCents ?? this.countedCashCents,
      denominationCounts: denominationCounts ?? this.denominationCounts,
      terminalTotalCents: terminalTotalCents ?? this.terminalTotalCents,
      cashTipsCents: cashTipsCents ?? this.cashTipsCents,
      cardTipsCents: cardTipsCents ?? this.cardTipsCents,
      cashDiffCents: cashDiffCents ?? this.cashDiffCents,
      cardDiffCents: cardDiffCents ?? this.cardDiffCents,
      comment: comment ?? this.comment,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DaysTable.$converterstatus.toSql(status.value),
      );
    }
    if (openingFloatCents.present) {
      map['opening_float_cents'] = Variable<int>(openingFloatCents.value);
    }
    if (countedCashCents.present) {
      map['counted_cash_cents'] = Variable<int>(countedCashCents.value);
    }
    if (denominationCounts.present) {
      map['denomination_counts'] = Variable<String>(denominationCounts.value);
    }
    if (terminalTotalCents.present) {
      map['terminal_total_cents'] = Variable<int>(terminalTotalCents.value);
    }
    if (cashTipsCents.present) {
      map['cash_tips_cents'] = Variable<int>(cashTipsCents.value);
    }
    if (cardTipsCents.present) {
      map['card_tips_cents'] = Variable<int>(cardTipsCents.value);
    }
    if (cashDiffCents.present) {
      map['cash_diff_cents'] = Variable<int>(cashDiffCents.value);
    }
    if (cardDiffCents.present) {
      map['card_diff_cents'] = Variable<int>(cardDiffCents.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<String>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DaysCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('openingFloatCents: $openingFloatCents, ')
          ..write('countedCashCents: $countedCashCents, ')
          ..write('denominationCounts: $denominationCounts, ')
          ..write('terminalTotalCents: $terminalTotalCents, ')
          ..write('cashTipsCents: $cashTipsCents, ')
          ..write('cardTipsCents: $cardTipsCents, ')
          ..write('cashDiffCents: $cashDiffCents, ')
          ..write('cardDiffCents: $cardDiffCents, ')
          ..write('comment: $comment, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentMethodsTable extends PaymentMethods
    with TableInfo<$PaymentMethodsTable, PaymentMethodData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentMethodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PaymentKind>($PaymentMethodsTable.$converterkind);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    code,
    name,
    kind,
    sortOrder,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'forma_pago';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentMethodData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentMethodData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentMethodData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $PaymentMethodsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $PaymentMethodsTable createAlias(String alias) {
    return $PaymentMethodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentKind, String, String> $converterkind =
      const EnumNameConverter<PaymentKind>(PaymentKind.values);
}

class PaymentMethodData extends DataClass
    implements Insertable<PaymentMethodData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String? code;
  final String name;
  final PaymentKind kind;
  final int sortOrder;
  final bool active;
  const PaymentMethodData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    this.code,
    required this.name,
    required this.kind,
    required this.sortOrder,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $PaymentMethodsTable.$converterkind.toSql(kind),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['active'] = Variable<bool>(active);
    return map;
  }

  PaymentMethodsCompanion toCompanion(bool nullToAbsent) {
    return PaymentMethodsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      kind: Value(kind),
      sortOrder: Value(sortOrder),
      active: Value(active),
    );
  }

  factory PaymentMethodData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentMethodData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      kind: $PaymentMethodsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $PaymentMethodsTable.$converterkind.toJson(kind),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'active': serializer.toJson<bool>(active),
    };
  }

  PaymentMethodData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    Value<String?> code = const Value.absent(),
    String? name,
    PaymentKind? kind,
    int? sortOrder,
    bool? active,
  }) => PaymentMethodData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
  );
  PaymentMethodData copyWithCompanion(PaymentMethodsCompanion data) {
    return PaymentMethodData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    code,
    name,
    kind,
    sortOrder,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentMethodData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.code == this.code &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.sortOrder == this.sortOrder &&
          other.active == this.active);
}

class PaymentMethodsCompanion extends UpdateCompanion<PaymentMethodData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String?> code;
  final Value<String> name;
  final Value<PaymentKind> kind;
  final Value<int> sortOrder;
  final Value<bool> active;
  final Value<int> rowid;
  const PaymentMethodsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentMethodsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    this.code = const Value.absent(),
    required String name,
    required PaymentKind kind,
    required int sortOrder,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       kind = Value(kind),
       sortOrder = Value(sortOrder);
  static Insertable<PaymentMethodData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? sortOrder,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentMethodsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String?>? code,
    Value<String>? name,
    Value<PaymentKind>? kind,
    Value<int>? sortOrder,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return PaymentMethodsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      code: code ?? this.code,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $PaymentMethodsTable.$converterkind.toSql(kind.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentMethodsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dia_caja (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Shift, String> shift =
      GeneratedColumn<String>(
        'shift',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Shift>($SalesTable.$convertershift);
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<String> paymentMethodId = GeneratedColumn<String>(
    'payment_method_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES forma_pago (id)',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    dayId,
    shift,
    paymentMethodId,
    amountCents,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'venta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentMethodIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dayId, shift, paymentMethodId},
  ];
  @override
  SaleData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      shift: $SalesTable.$convertershift.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shift'],
        )!,
      ),
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Shift, String, String> $convertershift =
      const EnumNameConverter<Shift>(Shift.values);
}

class SaleData extends DataClass implements Insertable<SaleData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String dayId;
  final Shift shift;
  final String paymentMethodId;
  final int amountCents;
  const SaleData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.dayId,
    required this.shift,
    required this.paymentMethodId,
    required this.amountCents,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['day_id'] = Variable<String>(dayId);
    {
      map['shift'] = Variable<String>($SalesTable.$convertershift.toSql(shift));
    }
    map['payment_method_id'] = Variable<String>(paymentMethodId);
    map['amount_cents'] = Variable<int>(amountCents);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      dayId: Value(dayId),
      shift: Value(shift),
      paymentMethodId: Value(paymentMethodId),
      amountCents: Value(amountCents),
    );
  }

  factory SaleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      dayId: serializer.fromJson<String>(json['dayId']),
      shift: $SalesTable.$convertershift.fromJson(
        serializer.fromJson<String>(json['shift']),
      ),
      paymentMethodId: serializer.fromJson<String>(json['paymentMethodId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'dayId': serializer.toJson<String>(dayId),
      'shift': serializer.toJson<String>(
        $SalesTable.$convertershift.toJson(shift),
      ),
      'paymentMethodId': serializer.toJson<String>(paymentMethodId),
      'amountCents': serializer.toJson<int>(amountCents),
    };
  }

  SaleData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? dayId,
    Shift? shift,
    String? paymentMethodId,
    int? amountCents,
  }) => SaleData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    dayId: dayId ?? this.dayId,
    shift: shift ?? this.shift,
    paymentMethodId: paymentMethodId ?? this.paymentMethodId,
    amountCents: amountCents ?? this.amountCents,
  );
  SaleData copyWithCompanion(SalesCompanion data) {
    return SaleData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      shift: data.shift.present ? data.shift.value : this.shift,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('dayId: $dayId, ')
          ..write('shift: $shift, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('amountCents: $amountCents')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    dayId,
    shift,
    paymentMethodId,
    amountCents,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.dayId == this.dayId &&
          other.shift == this.shift &&
          other.paymentMethodId == this.paymentMethodId &&
          other.amountCents == this.amountCents);
}

class SalesCompanion extends UpdateCompanion<SaleData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> dayId;
  final Value<Shift> shift;
  final Value<String> paymentMethodId;
  final Value<int> amountCents;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.dayId = const Value.absent(),
    this.shift = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String dayId,
    required Shift shift,
    required String paymentMethodId,
    required int amountCents,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       dayId = Value(dayId),
       shift = Value(shift),
       paymentMethodId = Value(paymentMethodId),
       amountCents = Value(amountCents);
  static Insertable<SaleData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? dayId,
    Expression<String>? shift,
    Expression<String>? paymentMethodId,
    Expression<int>? amountCents,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (dayId != null) 'day_id': dayId,
      if (shift != null) 'shift': shift,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? dayId,
    Value<Shift>? shift,
    Value<String>? paymentMethodId,
    Value<int>? amountCents,
    Value<int>? rowid,
  }) {
    return SalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      dayId: dayId ?? this.dayId,
      shift: shift ?? this.shift,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amountCents: amountCents ?? this.amountCents,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (shift.present) {
      map['shift'] = Variable<String>(
        $SalesTable.$convertershift.toSql(shift.value),
      );
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<String>(paymentMethodId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('dayId: $dayId, ')
          ..write('shift: $shift, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('amountCents: $amountCents, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoversTable extends Covers with TableInfo<$CoversTable, CoverData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoversTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dia_caja (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Shift, String> shift =
      GeneratedColumn<String>(
        'shift',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Shift>($CoversTable.$convertershift);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
    'count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    dayId,
    shift,
    count,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'comensales';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoverData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
        _countMeta,
        count.isAcceptableOrUnknown(data['count']!, _countMeta),
      );
    } else if (isInserting) {
      context.missing(_countMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dayId, shift},
  ];
  @override
  CoverData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoverData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      shift: $CoversTable.$convertershift.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}shift'],
        )!,
      ),
      count: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}count'],
      )!,
    );
  }

  @override
  $CoversTable createAlias(String alias) {
    return $CoversTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Shift, String, String> $convertershift =
      const EnumNameConverter<Shift>(Shift.values);
}

class CoverData extends DataClass implements Insertable<CoverData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String dayId;
  final Shift shift;
  final int count;
  const CoverData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.dayId,
    required this.shift,
    required this.count,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['day_id'] = Variable<String>(dayId);
    {
      map['shift'] = Variable<String>(
        $CoversTable.$convertershift.toSql(shift),
      );
    }
    map['count'] = Variable<int>(count);
    return map;
  }

  CoversCompanion toCompanion(bool nullToAbsent) {
    return CoversCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      dayId: Value(dayId),
      shift: Value(shift),
      count: Value(count),
    );
  }

  factory CoverData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoverData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      dayId: serializer.fromJson<String>(json['dayId']),
      shift: $CoversTable.$convertershift.fromJson(
        serializer.fromJson<String>(json['shift']),
      ),
      count: serializer.fromJson<int>(json['count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'dayId': serializer.toJson<String>(dayId),
      'shift': serializer.toJson<String>(
        $CoversTable.$convertershift.toJson(shift),
      ),
      'count': serializer.toJson<int>(count),
    };
  }

  CoverData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? dayId,
    Shift? shift,
    int? count,
  }) => CoverData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    dayId: dayId ?? this.dayId,
    shift: shift ?? this.shift,
    count: count ?? this.count,
  );
  CoverData copyWithCompanion(CoversCompanion data) {
    return CoverData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      shift: data.shift.present ? data.shift.value : this.shift,
      count: data.count.present ? data.count.value : this.count,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoverData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('dayId: $dayId, ')
          ..write('shift: $shift, ')
          ..write('count: $count')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, author, dayId, shift, count);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoverData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.dayId == this.dayId &&
          other.shift == this.shift &&
          other.count == this.count);
}

class CoversCompanion extends UpdateCompanion<CoverData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> dayId;
  final Value<Shift> shift;
  final Value<int> count;
  final Value<int> rowid;
  const CoversCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.dayId = const Value.absent(),
    this.shift = const Value.absent(),
    this.count = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoversCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String dayId,
    required Shift shift,
    required int count,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       dayId = Value(dayId),
       shift = Value(shift),
       count = Value(count);
  static Insertable<CoverData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? dayId,
    Expression<String>? shift,
    Expression<int>? count,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (dayId != null) 'day_id': dayId,
      if (shift != null) 'shift': shift,
      if (count != null) 'count': count,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoversCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? dayId,
    Value<Shift>? shift,
    Value<int>? count,
    Value<int>? rowid,
  }) {
    return CoversCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      dayId: dayId ?? this.dayId,
      shift: shift ?? this.shift,
      count: count ?? this.count,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (shift.present) {
      map['shift'] = Variable<String>(
        $CoversTable.$convertershift.toSql(shift.value),
      );
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoversCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('dayId: $dayId, ')
          ..write('shift: $shift, ')
          ..write('count: $count, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseCategoriesTable extends ExpenseCategories
    with TableInfo<$ExpenseCategoriesTable, ExpenseCategoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CategoryKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CategoryKind>($ExpenseCategoriesTable.$converterkind);
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    code,
    name,
    kind,
    sortOrder,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categoria_gasto';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseCategoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseCategoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseCategoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $ExpenseCategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $ExpenseCategoriesTable createAlias(String alias) {
    return $ExpenseCategoriesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CategoryKind, String, String> $converterkind =
      const EnumNameConverter<CategoryKind>(CategoryKind.values);
}

class ExpenseCategoryData extends DataClass
    implements Insertable<ExpenseCategoryData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String? code;
  final String name;
  final CategoryKind kind;
  final int sortOrder;
  final bool active;
  const ExpenseCategoryData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    this.code,
    required this.name,
    required this.kind,
    required this.sortOrder,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>(
        $ExpenseCategoriesTable.$converterkind.toSql(kind),
      );
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['active'] = Variable<bool>(active);
    return map;
  }

  ExpenseCategoriesCompanion toCompanion(bool nullToAbsent) {
    return ExpenseCategoriesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      kind: Value(kind),
      sortOrder: Value(sortOrder),
      active: Value(active),
    );
  }

  factory ExpenseCategoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseCategoryData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      kind: $ExpenseCategoriesTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<String>(
        $ExpenseCategoriesTable.$converterkind.toJson(kind),
      ),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'active': serializer.toJson<bool>(active),
    };
  }

  ExpenseCategoryData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    Value<String?> code = const Value.absent(),
    String? name,
    CategoryKind? kind,
    int? sortOrder,
    bool? active,
  }) => ExpenseCategoryData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
  );
  ExpenseCategoryData copyWithCompanion(ExpenseCategoriesCompanion data) {
    return ExpenseCategoryData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoryData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    code,
    name,
    kind,
    sortOrder,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseCategoryData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.code == this.code &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.sortOrder == this.sortOrder &&
          other.active == this.active);
}

class ExpenseCategoriesCompanion extends UpdateCompanion<ExpenseCategoryData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String?> code;
  final Value<String> name;
  final Value<CategoryKind> kind;
  final Value<int> sortOrder;
  final Value<bool> active;
  final Value<int> rowid;
  const ExpenseCategoriesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseCategoriesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    this.code = const Value.absent(),
    required String name,
    required CategoryKind kind,
    required int sortOrder,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       kind = Value(kind),
       sortOrder = Value(sortOrder);
  static Insertable<ExpenseCategoryData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<int>? sortOrder,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String?>? code,
    Value<String>? name,
    Value<CategoryKind>? kind,
    Value<int>? sortOrder,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return ExpenseCategoriesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      code: code ?? this.code,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ExpenseCategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, SupplierData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taxIdMeta = const VerificationMeta('taxId');
  @override
  late final GeneratedColumn<String> taxId = GeneratedColumn<String>(
    'tax_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categoria_gasto (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    name,
    taxId,
    phone,
    categoryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'proveedor';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplierData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('tax_id')) {
      context.handle(
        _taxIdMeta,
        taxId.isAcceptableOrUnknown(data['tax_id']!, _taxIdMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplierData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplierData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      taxId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tax_id'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class SupplierData extends DataClass implements Insertable<SupplierData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String name;
  final String? taxId;
  final String? phone;
  final String? categoryId;
  const SupplierData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.name,
    this.taxId,
    this.phone,
    this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || taxId != null) {
      map['tax_id'] = Variable<String>(taxId);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      name: Value(name),
      taxId: taxId == null && nullToAbsent
          ? const Value.absent()
          : Value(taxId),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory SupplierData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplierData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      name: serializer.fromJson<String>(json['name']),
      taxId: serializer.fromJson<String?>(json['taxId']),
      phone: serializer.fromJson<String?>(json['phone']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'name': serializer.toJson<String>(name),
      'taxId': serializer.toJson<String?>(taxId),
      'phone': serializer.toJson<String?>(phone),
      'categoryId': serializer.toJson<String?>(categoryId),
    };
  }

  SupplierData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? name,
    Value<String?> taxId = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> categoryId = const Value.absent(),
  }) => SupplierData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    name: name ?? this.name,
    taxId: taxId.present ? taxId.value : this.taxId,
    phone: phone.present ? phone.value : this.phone,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
  );
  SupplierData copyWithCompanion(SuppliersCompanion data) {
    return SupplierData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      name: data.name.present ? data.name.value : this.name,
      taxId: data.taxId.present ? data.taxId.value : this.taxId,
      phone: data.phone.present ? data.phone.value : this.phone,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplierData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('name: $name, ')
          ..write('taxId: $taxId, ')
          ..write('phone: $phone, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    name,
    taxId,
    phone,
    categoryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplierData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.name == this.name &&
          other.taxId == this.taxId &&
          other.phone == this.phone &&
          other.categoryId == this.categoryId);
}

class SuppliersCompanion extends UpdateCompanion<SupplierData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> name;
  final Value<String?> taxId;
  final Value<String?> phone;
  final Value<String?> categoryId;
  final Value<int> rowid;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.name = const Value.absent(),
    this.taxId = const Value.absent(),
    this.phone = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String name,
    this.taxId = const Value.absent(),
    this.phone = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<SupplierData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? name,
    Expression<String>? taxId,
    Expression<String>? phone,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (name != null) 'name': name,
      if (taxId != null) 'tax_id': taxId,
      if (phone != null) 'phone': phone,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? name,
    Value<String?>? taxId,
    Value<String?>? phone,
    Value<String?>? categoryId,
    Value<int>? rowid,
  }) {
    return SuppliersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      name: name ?? this.name,
      taxId: taxId ?? this.taxId,
      phone: phone ?? this.phone,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (taxId.present) {
      map['tax_id'] = Variable<String>(taxId.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('name: $name, ')
          ..write('taxId: $taxId, ')
          ..write('phone: $phone, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FixedCostsTable extends FixedCosts
    with TableInfo<$FixedCostsTable, FixedCostData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FixedCostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _conceptMeta = const VerificationMeta(
    'concept',
  );
  @override
  late final GeneratedColumn<String> concept = GeneratedColumn<String>(
    'concept',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categoria_gasto (id)',
    ),
  );
  static const VerificationMeta _plannedAmountCentsMeta =
      const VerificationMeta('plannedAmountCents');
  @override
  late final GeneratedColumn<int> plannedAmountCents = GeneratedColumn<int>(
    'planned_amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vatPctMeta = const VerificationMeta('vatPct');
  @override
  late final GeneratedColumn<int> vatPct = GeneratedColumn<int>(
    'vat_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Periodicity, String> periodicity =
      GeneratedColumn<String>(
        'periodicity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Periodicity>($FixedCostsTable.$converterperiodicity);
  static const VerificationMeta _chargeDayMeta = const VerificationMeta(
    'chargeDay',
  );
  @override
  late final GeneratedColumn<int> chargeDay = GeneratedColumn<int>(
    'charge_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMonthMeta = const VerificationMeta(
    'startMonth',
  );
  @override
  late final GeneratedColumn<String> startMonth = GeneratedColumn<String>(
    'start_month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    concept,
    categoryId,
    plannedAmountCents,
    vatPct,
    periodicity,
    chargeDay,
    startMonth,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gasto_fijo';
  @override
  VerificationContext validateIntegrity(
    Insertable<FixedCostData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('concept')) {
      context.handle(
        _conceptMeta,
        concept.isAcceptableOrUnknown(data['concept']!, _conceptMeta),
      );
    } else if (isInserting) {
      context.missing(_conceptMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('planned_amount_cents')) {
      context.handle(
        _plannedAmountCentsMeta,
        plannedAmountCents.isAcceptableOrUnknown(
          data['planned_amount_cents']!,
          _plannedAmountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedAmountCentsMeta);
    }
    if (data.containsKey('vat_pct')) {
      context.handle(
        _vatPctMeta,
        vatPct.isAcceptableOrUnknown(data['vat_pct']!, _vatPctMeta),
      );
    }
    if (data.containsKey('charge_day')) {
      context.handle(
        _chargeDayMeta,
        chargeDay.isAcceptableOrUnknown(data['charge_day']!, _chargeDayMeta),
      );
    } else if (isInserting) {
      context.missing(_chargeDayMeta);
    }
    if (data.containsKey('start_month')) {
      context.handle(
        _startMonthMeta,
        startMonth.isAcceptableOrUnknown(data['start_month']!, _startMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_startMonthMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FixedCostData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FixedCostData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      concept: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}concept'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      plannedAmountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_amount_cents'],
      )!,
      vatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vat_pct'],
      )!,
      periodicity: $FixedCostsTable.$converterperiodicity.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}periodicity'],
        )!,
      ),
      chargeDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}charge_day'],
      )!,
      startMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_month'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $FixedCostsTable createAlias(String alias) {
    return $FixedCostsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Periodicity, String, String> $converterperiodicity =
      const EnumNameConverter<Periodicity>(Periodicity.values);
}

class FixedCostData extends DataClass implements Insertable<FixedCostData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String concept;
  final String categoryId;
  final int plannedAmountCents;
  final int vatPct;
  final Periodicity periodicity;
  final int chargeDay;
  final String startMonth;
  final bool active;
  const FixedCostData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.concept,
    required this.categoryId,
    required this.plannedAmountCents,
    required this.vatPct,
    required this.periodicity,
    required this.chargeDay,
    required this.startMonth,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['concept'] = Variable<String>(concept);
    map['category_id'] = Variable<String>(categoryId);
    map['planned_amount_cents'] = Variable<int>(plannedAmountCents);
    map['vat_pct'] = Variable<int>(vatPct);
    {
      map['periodicity'] = Variable<String>(
        $FixedCostsTable.$converterperiodicity.toSql(periodicity),
      );
    }
    map['charge_day'] = Variable<int>(chargeDay);
    map['start_month'] = Variable<String>(startMonth);
    map['active'] = Variable<bool>(active);
    return map;
  }

  FixedCostsCompanion toCompanion(bool nullToAbsent) {
    return FixedCostsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      concept: Value(concept),
      categoryId: Value(categoryId),
      plannedAmountCents: Value(plannedAmountCents),
      vatPct: Value(vatPct),
      periodicity: Value(periodicity),
      chargeDay: Value(chargeDay),
      startMonth: Value(startMonth),
      active: Value(active),
    );
  }

  factory FixedCostData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FixedCostData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      concept: serializer.fromJson<String>(json['concept']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      plannedAmountCents: serializer.fromJson<int>(json['plannedAmountCents']),
      vatPct: serializer.fromJson<int>(json['vatPct']),
      periodicity: $FixedCostsTable.$converterperiodicity.fromJson(
        serializer.fromJson<String>(json['periodicity']),
      ),
      chargeDay: serializer.fromJson<int>(json['chargeDay']),
      startMonth: serializer.fromJson<String>(json['startMonth']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'concept': serializer.toJson<String>(concept),
      'categoryId': serializer.toJson<String>(categoryId),
      'plannedAmountCents': serializer.toJson<int>(plannedAmountCents),
      'vatPct': serializer.toJson<int>(vatPct),
      'periodicity': serializer.toJson<String>(
        $FixedCostsTable.$converterperiodicity.toJson(periodicity),
      ),
      'chargeDay': serializer.toJson<int>(chargeDay),
      'startMonth': serializer.toJson<String>(startMonth),
      'active': serializer.toJson<bool>(active),
    };
  }

  FixedCostData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? concept,
    String? categoryId,
    int? plannedAmountCents,
    int? vatPct,
    Periodicity? periodicity,
    int? chargeDay,
    String? startMonth,
    bool? active,
  }) => FixedCostData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    concept: concept ?? this.concept,
    categoryId: categoryId ?? this.categoryId,
    plannedAmountCents: plannedAmountCents ?? this.plannedAmountCents,
    vatPct: vatPct ?? this.vatPct,
    periodicity: periodicity ?? this.periodicity,
    chargeDay: chargeDay ?? this.chargeDay,
    startMonth: startMonth ?? this.startMonth,
    active: active ?? this.active,
  );
  FixedCostData copyWithCompanion(FixedCostsCompanion data) {
    return FixedCostData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      concept: data.concept.present ? data.concept.value : this.concept,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      plannedAmountCents: data.plannedAmountCents.present
          ? data.plannedAmountCents.value
          : this.plannedAmountCents,
      vatPct: data.vatPct.present ? data.vatPct.value : this.vatPct,
      periodicity: data.periodicity.present
          ? data.periodicity.value
          : this.periodicity,
      chargeDay: data.chargeDay.present ? data.chargeDay.value : this.chargeDay,
      startMonth: data.startMonth.present
          ? data.startMonth.value
          : this.startMonth,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FixedCostData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('concept: $concept, ')
          ..write('categoryId: $categoryId, ')
          ..write('plannedAmountCents: $plannedAmountCents, ')
          ..write('vatPct: $vatPct, ')
          ..write('periodicity: $periodicity, ')
          ..write('chargeDay: $chargeDay, ')
          ..write('startMonth: $startMonth, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    concept,
    categoryId,
    plannedAmountCents,
    vatPct,
    periodicity,
    chargeDay,
    startMonth,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FixedCostData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.concept == this.concept &&
          other.categoryId == this.categoryId &&
          other.plannedAmountCents == this.plannedAmountCents &&
          other.vatPct == this.vatPct &&
          other.periodicity == this.periodicity &&
          other.chargeDay == this.chargeDay &&
          other.startMonth == this.startMonth &&
          other.active == this.active);
}

class FixedCostsCompanion extends UpdateCompanion<FixedCostData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> concept;
  final Value<String> categoryId;
  final Value<int> plannedAmountCents;
  final Value<int> vatPct;
  final Value<Periodicity> periodicity;
  final Value<int> chargeDay;
  final Value<String> startMonth;
  final Value<bool> active;
  final Value<int> rowid;
  const FixedCostsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.concept = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.plannedAmountCents = const Value.absent(),
    this.vatPct = const Value.absent(),
    this.periodicity = const Value.absent(),
    this.chargeDay = const Value.absent(),
    this.startMonth = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FixedCostsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String concept,
    required String categoryId,
    required int plannedAmountCents,
    this.vatPct = const Value.absent(),
    required Periodicity periodicity,
    required int chargeDay,
    required String startMonth,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       concept = Value(concept),
       categoryId = Value(categoryId),
       plannedAmountCents = Value(plannedAmountCents),
       periodicity = Value(periodicity),
       chargeDay = Value(chargeDay),
       startMonth = Value(startMonth);
  static Insertable<FixedCostData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? concept,
    Expression<String>? categoryId,
    Expression<int>? plannedAmountCents,
    Expression<int>? vatPct,
    Expression<String>? periodicity,
    Expression<int>? chargeDay,
    Expression<String>? startMonth,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (concept != null) 'concept': concept,
      if (categoryId != null) 'category_id': categoryId,
      if (plannedAmountCents != null)
        'planned_amount_cents': plannedAmountCents,
      if (vatPct != null) 'vat_pct': vatPct,
      if (periodicity != null) 'periodicity': periodicity,
      if (chargeDay != null) 'charge_day': chargeDay,
      if (startMonth != null) 'start_month': startMonth,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FixedCostsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? concept,
    Value<String>? categoryId,
    Value<int>? plannedAmountCents,
    Value<int>? vatPct,
    Value<Periodicity>? periodicity,
    Value<int>? chargeDay,
    Value<String>? startMonth,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return FixedCostsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      concept: concept ?? this.concept,
      categoryId: categoryId ?? this.categoryId,
      plannedAmountCents: plannedAmountCents ?? this.plannedAmountCents,
      vatPct: vatPct ?? this.vatPct,
      periodicity: periodicity ?? this.periodicity,
      chargeDay: chargeDay ?? this.chargeDay,
      startMonth: startMonth ?? this.startMonth,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (concept.present) {
      map['concept'] = Variable<String>(concept.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (plannedAmountCents.present) {
      map['planned_amount_cents'] = Variable<int>(plannedAmountCents.value);
    }
    if (vatPct.present) {
      map['vat_pct'] = Variable<int>(vatPct.value);
    }
    if (periodicity.present) {
      map['periodicity'] = Variable<String>(
        $FixedCostsTable.$converterperiodicity.toSql(periodicity.value),
      );
    }
    if (chargeDay.present) {
      map['charge_day'] = Variable<int>(chargeDay.value);
    }
    if (startMonth.present) {
      map['start_month'] = Variable<String>(startMonth.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FixedCostsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('concept: $concept, ')
          ..write('categoryId: $categoryId, ')
          ..write('plannedAmountCents: $plannedAmountCents, ')
          ..write('vatPct: $vatPct, ')
          ..write('periodicity: $periodicity, ')
          ..write('chargeDay: $chargeDay, ')
          ..write('startMonth: $startMonth, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES proveedor (id)',
    ),
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categoria_gasto (id)',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseCentsMeta = const VerificationMeta(
    'baseCents',
  );
  @override
  late final GeneratedColumn<int> baseCents = GeneratedColumn<int>(
    'base_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vatPctMeta = const VerificationMeta('vatPct');
  @override
  late final GeneratedColumn<int> vatPct = GeneratedColumn<int>(
    'vat_pct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vatCentsMeta = const VerificationMeta(
    'vatCents',
  );
  @override
  late final GeneratedColumn<int> vatCents = GeneratedColumn<int>(
    'vat_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalCentsMeta = const VerificationMeta(
    'totalCents',
  );
  @override
  late final GeneratedColumn<int> totalCents = GeneratedColumn<int>(
    'total_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<String> paymentMethodId = GeneratedColumn<String>(
    'payment_method_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES forma_pago (id)',
    ),
  );
  static const VerificationMeta _paidInCashDayIdMeta = const VerificationMeta(
    'paidInCashDayId',
  );
  @override
  late final GeneratedColumn<String> paidInCashDayId = GeneratedColumn<String>(
    'paid_in_cash_day_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dia_caja (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PaymentStatus, String>
  paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<PaymentStatus>($ExpensesTable.$converterpaymentStatus);
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<String> dueDate = GeneratedColumn<String>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ExpenseOrigin, String> origin =
      GeneratedColumn<String>(
        'origin',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExpenseOrigin>($ExpensesTable.$converterorigin);
  static const VerificationMeta _fixedCostIdMeta = const VerificationMeta(
    'fixedCostId',
  );
  @override
  late final GeneratedColumn<String> fixedCostId = GeneratedColumn<String>(
    'fixed_cost_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gasto_fijo (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<FixedStatus?, String>
  fixedStatus = GeneratedColumn<String>(
    'fixed_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<FixedStatus?>($ExpensesTable.$converterfixedStatusn);
  static const VerificationMeta _voidedMeta = const VerificationMeta('voided');
  @override
  late final GeneratedColumn<bool> voided = GeneratedColumn<bool>(
    'voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    date,
    supplierId,
    categoryId,
    invoiceNumber,
    baseCents,
    vatPct,
    vatCents,
    totalCents,
    paymentMethodId,
    paidInCashDayId,
    paymentStatus,
    dueDate,
    origin,
    fixedCostId,
    fixedStatus,
    voided,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gasto';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpenseData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    }
    if (data.containsKey('base_cents')) {
      context.handle(
        _baseCentsMeta,
        baseCents.isAcceptableOrUnknown(data['base_cents']!, _baseCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_baseCentsMeta);
    }
    if (data.containsKey('vat_pct')) {
      context.handle(
        _vatPctMeta,
        vatPct.isAcceptableOrUnknown(data['vat_pct']!, _vatPctMeta),
      );
    }
    if (data.containsKey('vat_cents')) {
      context.handle(
        _vatCentsMeta,
        vatCents.isAcceptableOrUnknown(data['vat_cents']!, _vatCentsMeta),
      );
    }
    if (data.containsKey('total_cents')) {
      context.handle(
        _totalCentsMeta,
        totalCents.isAcceptableOrUnknown(data['total_cents']!, _totalCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCentsMeta);
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('paid_in_cash_day_id')) {
      context.handle(
        _paidInCashDayIdMeta,
        paidInCashDayId.isAcceptableOrUnknown(
          data['paid_in_cash_day_id']!,
          _paidInCashDayIdMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('fixed_cost_id')) {
      context.handle(
        _fixedCostIdMeta,
        fixedCostId.isAcceptableOrUnknown(
          data['fixed_cost_id']!,
          _fixedCostIdMeta,
        ),
      );
    }
    if (data.containsKey('voided')) {
      context.handle(
        _voidedMeta,
        voided.isAcceptableOrUnknown(data['voided']!, _voidedMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {fixedCostId, date},
  ];
  @override
  ExpenseData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      ),
      baseCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_cents'],
      )!,
      vatPct: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vat_pct'],
      )!,
      vatCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vat_cents'],
      )!,
      totalCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_cents'],
      )!,
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_id'],
      ),
      paidInCashDayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}paid_in_cash_day_id'],
      ),
      paymentStatus: $ExpensesTable.$converterpaymentStatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}payment_status'],
        )!,
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}due_date'],
      ),
      origin: $ExpensesTable.$converterorigin.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}origin'],
        )!,
      ),
      fixedCostId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixed_cost_id'],
      ),
      fixedStatus: $ExpensesTable.$converterfixedStatusn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fixed_status'],
        ),
      ),
      voided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voided'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PaymentStatus, String, String>
  $converterpaymentStatus = const EnumNameConverter<PaymentStatus>(
    PaymentStatus.values,
  );
  static JsonTypeConverter2<ExpenseOrigin, String, String> $converterorigin =
      const EnumNameConverter<ExpenseOrigin>(ExpenseOrigin.values);
  static JsonTypeConverter2<FixedStatus, String, String> $converterfixedStatus =
      const EnumNameConverter<FixedStatus>(FixedStatus.values);
  static JsonTypeConverter2<FixedStatus?, String?, String?>
  $converterfixedStatusn = JsonTypeConverter2.asNullable($converterfixedStatus);
}

class ExpenseData extends DataClass implements Insertable<ExpenseData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String date;
  final String? supplierId;
  final String categoryId;
  final String? invoiceNumber;
  final int baseCents;
  final int vatPct;
  final int vatCents;
  final int totalCents;
  final String? paymentMethodId;
  final String? paidInCashDayId;
  final PaymentStatus paymentStatus;
  final String? dueDate;
  final ExpenseOrigin origin;
  final String? fixedCostId;
  final FixedStatus? fixedStatus;
  final bool voided;
  final String? voidReason;
  const ExpenseData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.date,
    this.supplierId,
    required this.categoryId,
    this.invoiceNumber,
    required this.baseCents,
    required this.vatPct,
    required this.vatCents,
    required this.totalCents,
    this.paymentMethodId,
    this.paidInCashDayId,
    required this.paymentStatus,
    this.dueDate,
    required this.origin,
    this.fixedCostId,
    this.fixedStatus,
    required this.voided,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['category_id'] = Variable<String>(categoryId);
    if (!nullToAbsent || invoiceNumber != null) {
      map['invoice_number'] = Variable<String>(invoiceNumber);
    }
    map['base_cents'] = Variable<int>(baseCents);
    map['vat_pct'] = Variable<int>(vatPct);
    map['vat_cents'] = Variable<int>(vatCents);
    map['total_cents'] = Variable<int>(totalCents);
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<String>(paymentMethodId);
    }
    if (!nullToAbsent || paidInCashDayId != null) {
      map['paid_in_cash_day_id'] = Variable<String>(paidInCashDayId);
    }
    {
      map['payment_status'] = Variable<String>(
        $ExpensesTable.$converterpaymentStatus.toSql(paymentStatus),
      );
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<String>(dueDate);
    }
    {
      map['origin'] = Variable<String>(
        $ExpensesTable.$converterorigin.toSql(origin),
      );
    }
    if (!nullToAbsent || fixedCostId != null) {
      map['fixed_cost_id'] = Variable<String>(fixedCostId);
    }
    if (!nullToAbsent || fixedStatus != null) {
      map['fixed_status'] = Variable<String>(
        $ExpensesTable.$converterfixedStatusn.toSql(fixedStatus),
      );
    }
    map['voided'] = Variable<bool>(voided);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      date: Value(date),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      categoryId: Value(categoryId),
      invoiceNumber: invoiceNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(invoiceNumber),
      baseCents: Value(baseCents),
      vatPct: Value(vatPct),
      vatCents: Value(vatCents),
      totalCents: Value(totalCents),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      paidInCashDayId: paidInCashDayId == null && nullToAbsent
          ? const Value.absent()
          : Value(paidInCashDayId),
      paymentStatus: Value(paymentStatus),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      origin: Value(origin),
      fixedCostId: fixedCostId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedCostId),
      fixedStatus: fixedStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedStatus),
      voided: Value(voided),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory ExpenseData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      date: serializer.fromJson<String>(json['date']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      invoiceNumber: serializer.fromJson<String?>(json['invoiceNumber']),
      baseCents: serializer.fromJson<int>(json['baseCents']),
      vatPct: serializer.fromJson<int>(json['vatPct']),
      vatCents: serializer.fromJson<int>(json['vatCents']),
      totalCents: serializer.fromJson<int>(json['totalCents']),
      paymentMethodId: serializer.fromJson<String?>(json['paymentMethodId']),
      paidInCashDayId: serializer.fromJson<String?>(json['paidInCashDayId']),
      paymentStatus: $ExpensesTable.$converterpaymentStatus.fromJson(
        serializer.fromJson<String>(json['paymentStatus']),
      ),
      dueDate: serializer.fromJson<String?>(json['dueDate']),
      origin: $ExpensesTable.$converterorigin.fromJson(
        serializer.fromJson<String>(json['origin']),
      ),
      fixedCostId: serializer.fromJson<String?>(json['fixedCostId']),
      fixedStatus: $ExpensesTable.$converterfixedStatusn.fromJson(
        serializer.fromJson<String?>(json['fixedStatus']),
      ),
      voided: serializer.fromJson<bool>(json['voided']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'date': serializer.toJson<String>(date),
      'supplierId': serializer.toJson<String?>(supplierId),
      'categoryId': serializer.toJson<String>(categoryId),
      'invoiceNumber': serializer.toJson<String?>(invoiceNumber),
      'baseCents': serializer.toJson<int>(baseCents),
      'vatPct': serializer.toJson<int>(vatPct),
      'vatCents': serializer.toJson<int>(vatCents),
      'totalCents': serializer.toJson<int>(totalCents),
      'paymentMethodId': serializer.toJson<String?>(paymentMethodId),
      'paidInCashDayId': serializer.toJson<String?>(paidInCashDayId),
      'paymentStatus': serializer.toJson<String>(
        $ExpensesTable.$converterpaymentStatus.toJson(paymentStatus),
      ),
      'dueDate': serializer.toJson<String?>(dueDate),
      'origin': serializer.toJson<String>(
        $ExpensesTable.$converterorigin.toJson(origin),
      ),
      'fixedCostId': serializer.toJson<String?>(fixedCostId),
      'fixedStatus': serializer.toJson<String?>(
        $ExpensesTable.$converterfixedStatusn.toJson(fixedStatus),
      ),
      'voided': serializer.toJson<bool>(voided),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  ExpenseData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? date,
    Value<String?> supplierId = const Value.absent(),
    String? categoryId,
    Value<String?> invoiceNumber = const Value.absent(),
    int? baseCents,
    int? vatPct,
    int? vatCents,
    int? totalCents,
    Value<String?> paymentMethodId = const Value.absent(),
    Value<String?> paidInCashDayId = const Value.absent(),
    PaymentStatus? paymentStatus,
    Value<String?> dueDate = const Value.absent(),
    ExpenseOrigin? origin,
    Value<String?> fixedCostId = const Value.absent(),
    Value<FixedStatus?> fixedStatus = const Value.absent(),
    bool? voided,
    Value<String?> voidReason = const Value.absent(),
  }) => ExpenseData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    date: date ?? this.date,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    categoryId: categoryId ?? this.categoryId,
    invoiceNumber: invoiceNumber.present
        ? invoiceNumber.value
        : this.invoiceNumber,
    baseCents: baseCents ?? this.baseCents,
    vatPct: vatPct ?? this.vatPct,
    vatCents: vatCents ?? this.vatCents,
    totalCents: totalCents ?? this.totalCents,
    paymentMethodId: paymentMethodId.present
        ? paymentMethodId.value
        : this.paymentMethodId,
    paidInCashDayId: paidInCashDayId.present
        ? paidInCashDayId.value
        : this.paidInCashDayId,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    origin: origin ?? this.origin,
    fixedCostId: fixedCostId.present ? fixedCostId.value : this.fixedCostId,
    fixedStatus: fixedStatus.present ? fixedStatus.value : this.fixedStatus,
    voided: voided ?? this.voided,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  ExpenseData copyWithCompanion(ExpensesCompanion data) {
    return ExpenseData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      date: data.date.present ? data.date.value : this.date,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      baseCents: data.baseCents.present ? data.baseCents.value : this.baseCents,
      vatPct: data.vatPct.present ? data.vatPct.value : this.vatPct,
      vatCents: data.vatCents.present ? data.vatCents.value : this.vatCents,
      totalCents: data.totalCents.present
          ? data.totalCents.value
          : this.totalCents,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      paidInCashDayId: data.paidInCashDayId.present
          ? data.paidInCashDayId.value
          : this.paidInCashDayId,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      origin: data.origin.present ? data.origin.value : this.origin,
      fixedCostId: data.fixedCostId.present
          ? data.fixedCostId.value
          : this.fixedCostId,
      fixedStatus: data.fixedStatus.present
          ? data.fixedStatus.value
          : this.fixedStatus,
      voided: data.voided.present ? data.voided.value : this.voided,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('date: $date, ')
          ..write('supplierId: $supplierId, ')
          ..write('categoryId: $categoryId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('baseCents: $baseCents, ')
          ..write('vatPct: $vatPct, ')
          ..write('vatCents: $vatCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('paidInCashDayId: $paidInCashDayId, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('dueDate: $dueDate, ')
          ..write('origin: $origin, ')
          ..write('fixedCostId: $fixedCostId, ')
          ..write('fixedStatus: $fixedStatus, ')
          ..write('voided: $voided, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    author,
    date,
    supplierId,
    categoryId,
    invoiceNumber,
    baseCents,
    vatPct,
    vatCents,
    totalCents,
    paymentMethodId,
    paidInCashDayId,
    paymentStatus,
    dueDate,
    origin,
    fixedCostId,
    fixedStatus,
    voided,
    voidReason,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.date == this.date &&
          other.supplierId == this.supplierId &&
          other.categoryId == this.categoryId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.baseCents == this.baseCents &&
          other.vatPct == this.vatPct &&
          other.vatCents == this.vatCents &&
          other.totalCents == this.totalCents &&
          other.paymentMethodId == this.paymentMethodId &&
          other.paidInCashDayId == this.paidInCashDayId &&
          other.paymentStatus == this.paymentStatus &&
          other.dueDate == this.dueDate &&
          other.origin == this.origin &&
          other.fixedCostId == this.fixedCostId &&
          other.fixedStatus == this.fixedStatus &&
          other.voided == this.voided &&
          other.voidReason == this.voidReason);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> date;
  final Value<String?> supplierId;
  final Value<String> categoryId;
  final Value<String?> invoiceNumber;
  final Value<int> baseCents;
  final Value<int> vatPct;
  final Value<int> vatCents;
  final Value<int> totalCents;
  final Value<String?> paymentMethodId;
  final Value<String?> paidInCashDayId;
  final Value<PaymentStatus> paymentStatus;
  final Value<String?> dueDate;
  final Value<ExpenseOrigin> origin;
  final Value<String?> fixedCostId;
  final Value<FixedStatus?> fixedStatus;
  final Value<bool> voided;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.date = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.baseCents = const Value.absent(),
    this.vatPct = const Value.absent(),
    this.vatCents = const Value.absent(),
    this.totalCents = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.paidInCashDayId = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.origin = const Value.absent(),
    this.fixedCostId = const Value.absent(),
    this.fixedStatus = const Value.absent(),
    this.voided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String date,
    this.supplierId = const Value.absent(),
    required String categoryId,
    this.invoiceNumber = const Value.absent(),
    required int baseCents,
    this.vatPct = const Value.absent(),
    this.vatCents = const Value.absent(),
    required int totalCents,
    this.paymentMethodId = const Value.absent(),
    this.paidInCashDayId = const Value.absent(),
    required PaymentStatus paymentStatus,
    this.dueDate = const Value.absent(),
    required ExpenseOrigin origin,
    this.fixedCostId = const Value.absent(),
    this.fixedStatus = const Value.absent(),
    this.voided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       date = Value(date),
       categoryId = Value(categoryId),
       baseCents = Value(baseCents),
       totalCents = Value(totalCents),
       paymentStatus = Value(paymentStatus),
       origin = Value(origin);
  static Insertable<ExpenseData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? date,
    Expression<String>? supplierId,
    Expression<String>? categoryId,
    Expression<String>? invoiceNumber,
    Expression<int>? baseCents,
    Expression<int>? vatPct,
    Expression<int>? vatCents,
    Expression<int>? totalCents,
    Expression<String>? paymentMethodId,
    Expression<String>? paidInCashDayId,
    Expression<String>? paymentStatus,
    Expression<String>? dueDate,
    Expression<String>? origin,
    Expression<String>? fixedCostId,
    Expression<String>? fixedStatus,
    Expression<bool>? voided,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (date != null) 'date': date,
      if (supplierId != null) 'supplier_id': supplierId,
      if (categoryId != null) 'category_id': categoryId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (baseCents != null) 'base_cents': baseCents,
      if (vatPct != null) 'vat_pct': vatPct,
      if (vatCents != null) 'vat_cents': vatCents,
      if (totalCents != null) 'total_cents': totalCents,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (paidInCashDayId != null) 'paid_in_cash_day_id': paidInCashDayId,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (dueDate != null) 'due_date': dueDate,
      if (origin != null) 'origin': origin,
      if (fixedCostId != null) 'fixed_cost_id': fixedCostId,
      if (fixedStatus != null) 'fixed_status': fixedStatus,
      if (voided != null) 'voided': voided,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? date,
    Value<String?>? supplierId,
    Value<String>? categoryId,
    Value<String?>? invoiceNumber,
    Value<int>? baseCents,
    Value<int>? vatPct,
    Value<int>? vatCents,
    Value<int>? totalCents,
    Value<String?>? paymentMethodId,
    Value<String?>? paidInCashDayId,
    Value<PaymentStatus>? paymentStatus,
    Value<String?>? dueDate,
    Value<ExpenseOrigin>? origin,
    Value<String?>? fixedCostId,
    Value<FixedStatus?>? fixedStatus,
    Value<bool>? voided,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return ExpensesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      date: date ?? this.date,
      supplierId: supplierId ?? this.supplierId,
      categoryId: categoryId ?? this.categoryId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      baseCents: baseCents ?? this.baseCents,
      vatPct: vatPct ?? this.vatPct,
      vatCents: vatCents ?? this.vatCents,
      totalCents: totalCents ?? this.totalCents,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      paidInCashDayId: paidInCashDayId ?? this.paidInCashDayId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      dueDate: dueDate ?? this.dueDate,
      origin: origin ?? this.origin,
      fixedCostId: fixedCostId ?? this.fixedCostId,
      fixedStatus: fixedStatus ?? this.fixedStatus,
      voided: voided ?? this.voided,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (baseCents.present) {
      map['base_cents'] = Variable<int>(baseCents.value);
    }
    if (vatPct.present) {
      map['vat_pct'] = Variable<int>(vatPct.value);
    }
    if (vatCents.present) {
      map['vat_cents'] = Variable<int>(vatCents.value);
    }
    if (totalCents.present) {
      map['total_cents'] = Variable<int>(totalCents.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<String>(paymentMethodId.value);
    }
    if (paidInCashDayId.present) {
      map['paid_in_cash_day_id'] = Variable<String>(paidInCashDayId.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(
        $ExpensesTable.$converterpaymentStatus.toSql(paymentStatus.value),
      );
    }
    if (dueDate.present) {
      map['due_date'] = Variable<String>(dueDate.value);
    }
    if (origin.present) {
      map['origin'] = Variable<String>(
        $ExpensesTable.$converterorigin.toSql(origin.value),
      );
    }
    if (fixedCostId.present) {
      map['fixed_cost_id'] = Variable<String>(fixedCostId.value);
    }
    if (fixedStatus.present) {
      map['fixed_status'] = Variable<String>(
        $ExpensesTable.$converterfixedStatusn.toSql(fixedStatus.value),
      );
    }
    if (voided.present) {
      map['voided'] = Variable<bool>(voided.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('date: $date, ')
          ..write('supplierId: $supplierId, ')
          ..write('categoryId: $categoryId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('baseCents: $baseCents, ')
          ..write('vatPct: $vatPct, ')
          ..write('vatCents: $vatCents, ')
          ..write('totalCents: $totalCents, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('paidInCashDayId: $paidInCashDayId, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('dueDate: $dueDate, ')
          ..write('origin: $origin, ')
          ..write('fixedCostId: $fixedCostId, ')
          ..write('fixedStatus: $fixedStatus, ')
          ..write('voided: $voided, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts
    with TableInfo<$ReceiptsTable, ReceiptData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES gasto (id)',
    ),
  );
  static const VerificationMeta _relativePathMeta = const VerificationMeta(
    'relativePath',
  );
  @override
  late final GeneratedColumn<String> relativePath = GeneratedColumn<String>(
    'relative_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ReceiptKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ReceiptKind>($ReceiptsTable.$converterkind);
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    expenseId,
    relativePath,
    kind,
    sizeBytes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'justificante';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('relative_path')) {
      context.handle(
        _relativePathMeta,
        relativePath.isAcceptableOrUnknown(
          data['relative_path']!,
          _relativePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_relativePathMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      relativePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relative_path'],
      )!,
      kind: $ReceiptsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReceiptKind, String, String> $converterkind =
      const EnumNameConverter<ReceiptKind>(ReceiptKind.values);
}

class ReceiptData extends DataClass implements Insertable<ReceiptData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String expenseId;
  final String relativePath;
  final ReceiptKind kind;
  final int sizeBytes;
  const ReceiptData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.expenseId,
    required this.relativePath,
    required this.kind,
    required this.sizeBytes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['expense_id'] = Variable<String>(expenseId);
    map['relative_path'] = Variable<String>(relativePath);
    {
      map['kind'] = Variable<String>($ReceiptsTable.$converterkind.toSql(kind));
    }
    map['size_bytes'] = Variable<int>(sizeBytes);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      expenseId: Value(expenseId),
      relativePath: Value(relativePath),
      kind: Value(kind),
      sizeBytes: Value(sizeBytes),
    );
  }

  factory ReceiptData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      relativePath: serializer.fromJson<String>(json['relativePath']),
      kind: $ReceiptsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'expenseId': serializer.toJson<String>(expenseId),
      'relativePath': serializer.toJson<String>(relativePath),
      'kind': serializer.toJson<String>(
        $ReceiptsTable.$converterkind.toJson(kind),
      ),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
    };
  }

  ReceiptData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? expenseId,
    String? relativePath,
    ReceiptKind? kind,
    int? sizeBytes,
  }) => ReceiptData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    expenseId: expenseId ?? this.expenseId,
    relativePath: relativePath ?? this.relativePath,
    kind: kind ?? this.kind,
    sizeBytes: sizeBytes ?? this.sizeBytes,
  );
  ReceiptData copyWithCompanion(ReceiptsCompanion data) {
    return ReceiptData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      relativePath: data.relativePath.present
          ? data.relativePath.value
          : this.relativePath,
      kind: data.kind.present ? data.kind.value : this.kind,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('expenseId: $expenseId, ')
          ..write('relativePath: $relativePath, ')
          ..write('kind: $kind, ')
          ..write('sizeBytes: $sizeBytes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    expenseId,
    relativePath,
    kind,
    sizeBytes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.expenseId == this.expenseId &&
          other.relativePath == this.relativePath &&
          other.kind == this.kind &&
          other.sizeBytes == this.sizeBytes);
}

class ReceiptsCompanion extends UpdateCompanion<ReceiptData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> expenseId;
  final Value<String> relativePath;
  final Value<ReceiptKind> kind;
  final Value<int> sizeBytes;
  final Value<int> rowid;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.relativePath = const Value.absent(),
    this.kind = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String expenseId,
    required String relativePath,
    required ReceiptKind kind,
    required int sizeBytes,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       expenseId = Value(expenseId),
       relativePath = Value(relativePath),
       kind = Value(kind),
       sizeBytes = Value(sizeBytes);
  static Insertable<ReceiptData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? expenseId,
    Expression<String>? relativePath,
    Expression<String>? kind,
    Expression<int>? sizeBytes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (expenseId != null) 'expense_id': expenseId,
      if (relativePath != null) 'relative_path': relativePath,
      if (kind != null) 'kind': kind,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? expenseId,
    Value<String>? relativePath,
    Value<ReceiptKind>? kind,
    Value<int>? sizeBytes,
    Value<int>? rowid,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      expenseId: expenseId ?? this.expenseId,
      relativePath: relativePath ?? this.relativePath,
      kind: kind ?? this.kind,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (relativePath.present) {
      map['relative_path'] = Variable<String>(relativePath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $ReceiptsTable.$converterkind.toSql(kind.value),
      );
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('expenseId: $expenseId, ')
          ..write('relativePath: $relativePath, ')
          ..write('kind: $kind, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EmployeesTable extends Employees
    with TableInfo<$EmployeesTable, EmployeeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EmployeesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hireDateMeta = const VerificationMeta(
    'hireDate',
  );
  @override
  late final GeneratedColumn<String> hireDate = GeneratedColumn<String>(
    'hire_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _terminationDateMeta = const VerificationMeta(
    'terminationDate',
  );
  @override
  late final GeneratedColumn<String> terminationDate = GeneratedColumn<String>(
    'termination_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    name,
    position,
    hireDate,
    terminationDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'empleado';
  @override
  VerificationContext validateIntegrity(
    Insertable<EmployeeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('hire_date')) {
      context.handle(
        _hireDateMeta,
        hireDate.isAcceptableOrUnknown(data['hire_date']!, _hireDateMeta),
      );
    }
    if (data.containsKey('termination_date')) {
      context.handle(
        _terminationDateMeta,
        terminationDate.isAcceptableOrUnknown(
          data['termination_date']!,
          _terminationDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EmployeeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EmployeeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
      hireDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hire_date'],
      ),
      terminationDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}termination_date'],
      ),
    );
  }

  @override
  $EmployeesTable createAlias(String alias) {
    return $EmployeesTable(attachedDatabase, alias);
  }
}

class EmployeeData extends DataClass implements Insertable<EmployeeData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String name;
  final String? position;
  final String? hireDate;
  final String? terminationDate;
  const EmployeeData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.name,
    this.position,
    this.hireDate,
    this.terminationDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    if (!nullToAbsent || hireDate != null) {
      map['hire_date'] = Variable<String>(hireDate);
    }
    if (!nullToAbsent || terminationDate != null) {
      map['termination_date'] = Variable<String>(terminationDate);
    }
    return map;
  }

  EmployeesCompanion toCompanion(bool nullToAbsent) {
    return EmployeesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      name: Value(name),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
      hireDate: hireDate == null && nullToAbsent
          ? const Value.absent()
          : Value(hireDate),
      terminationDate: terminationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(terminationDate),
    );
  }

  factory EmployeeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EmployeeData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      name: serializer.fromJson<String>(json['name']),
      position: serializer.fromJson<String?>(json['position']),
      hireDate: serializer.fromJson<String?>(json['hireDate']),
      terminationDate: serializer.fromJson<String?>(json['terminationDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'name': serializer.toJson<String>(name),
      'position': serializer.toJson<String?>(position),
      'hireDate': serializer.toJson<String?>(hireDate),
      'terminationDate': serializer.toJson<String?>(terminationDate),
    };
  }

  EmployeeData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? name,
    Value<String?> position = const Value.absent(),
    Value<String?> hireDate = const Value.absent(),
    Value<String?> terminationDate = const Value.absent(),
  }) => EmployeeData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    name: name ?? this.name,
    position: position.present ? position.value : this.position,
    hireDate: hireDate.present ? hireDate.value : this.hireDate,
    terminationDate: terminationDate.present
        ? terminationDate.value
        : this.terminationDate,
  );
  EmployeeData copyWithCompanion(EmployeesCompanion data) {
    return EmployeeData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      name: data.name.present ? data.name.value : this.name,
      position: data.position.present ? data.position.value : this.position,
      hireDate: data.hireDate.present ? data.hireDate.value : this.hireDate,
      terminationDate: data.terminationDate.present
          ? data.terminationDate.value
          : this.terminationDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EmployeeData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('hireDate: $hireDate, ')
          ..write('terminationDate: $terminationDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    name,
    position,
    hireDate,
    terminationDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EmployeeData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.name == this.name &&
          other.position == this.position &&
          other.hireDate == this.hireDate &&
          other.terminationDate == this.terminationDate);
}

class EmployeesCompanion extends UpdateCompanion<EmployeeData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> name;
  final Value<String?> position;
  final Value<String?> hireDate;
  final Value<String?> terminationDate;
  final Value<int> rowid;
  const EmployeesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.name = const Value.absent(),
    this.position = const Value.absent(),
    this.hireDate = const Value.absent(),
    this.terminationDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EmployeesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String name,
    this.position = const Value.absent(),
    this.hireDate = const Value.absent(),
    this.terminationDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<EmployeeData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? name,
    Expression<String>? position,
    Expression<String>? hireDate,
    Expression<String>? terminationDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (name != null) 'name': name,
      if (position != null) 'position': position,
      if (hireDate != null) 'hire_date': hireDate,
      if (terminationDate != null) 'termination_date': terminationDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EmployeesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? name,
    Value<String?>? position,
    Value<String?>? hireDate,
    Value<String?>? terminationDate,
    Value<int>? rowid,
  }) {
    return EmployeesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      name: name ?? this.name,
      position: position ?? this.position,
      hireDate: hireDate ?? this.hireDate,
      terminationDate: terminationDate ?? this.terminationDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (hireDate.present) {
      map['hire_date'] = Variable<String>(hireDate.value);
    }
    if (terminationDate.present) {
      map['termination_date'] = Variable<String>(terminationDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EmployeesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('name: $name, ')
          ..write('position: $position, ')
          ..write('hireDate: $hireDate, ')
          ..write('terminationDate: $terminationDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PayrollPaymentsTable extends PayrollPayments
    with TableInfo<$PayrollPaymentsTable, PayrollPaymentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PayrollPaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _employeeIdMeta = const VerificationMeta(
    'employeeId',
  );
  @override
  late final GeneratedColumn<String> employeeId = GeneratedColumn<String>(
    'employee_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES empleado (id)',
    ),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grossCentsMeta = const VerificationMeta(
    'grossCents',
  );
  @override
  late final GeneratedColumn<int> grossCents = GeneratedColumn<int>(
    'gross_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netCentsMeta = const VerificationMeta(
    'netCents',
  );
  @override
  late final GeneratedColumn<int> netCents = GeneratedColumn<int>(
    'net_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _employerSsCentsMeta = const VerificationMeta(
    'employerSsCents',
  );
  @override
  late final GeneratedColumn<int> employerSsCents = GeneratedColumn<int>(
    'employer_ss_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodIdMeta = const VerificationMeta(
    'paymentMethodId',
  );
  @override
  late final GeneratedColumn<String> paymentMethodId = GeneratedColumn<String>(
    'payment_method_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES forma_pago (id)',
    ),
  );
  static const VerificationMeta _voidedMeta = const VerificationMeta('voided');
  @override
  late final GeneratedColumn<bool> voided = GeneratedColumn<bool>(
    'voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    employeeId,
    month,
    grossCents,
    netCents,
    employerSsCents,
    paymentMethodId,
    voided,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pago_nomina';
  @override
  VerificationContext validateIntegrity(
    Insertable<PayrollPaymentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('employee_id')) {
      context.handle(
        _employeeIdMeta,
        employeeId.isAcceptableOrUnknown(data['employee_id']!, _employeeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeIdMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('gross_cents')) {
      context.handle(
        _grossCentsMeta,
        grossCents.isAcceptableOrUnknown(data['gross_cents']!, _grossCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_grossCentsMeta);
    }
    if (data.containsKey('net_cents')) {
      context.handle(
        _netCentsMeta,
        netCents.isAcceptableOrUnknown(data['net_cents']!, _netCentsMeta),
      );
    } else if (isInserting) {
      context.missing(_netCentsMeta);
    }
    if (data.containsKey('employer_ss_cents')) {
      context.handle(
        _employerSsCentsMeta,
        employerSsCents.isAcceptableOrUnknown(
          data['employer_ss_cents']!,
          _employerSsCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_employerSsCentsMeta);
    }
    if (data.containsKey('payment_method_id')) {
      context.handle(
        _paymentMethodIdMeta,
        paymentMethodId.isAcceptableOrUnknown(
          data['payment_method_id']!,
          _paymentMethodIdMeta,
        ),
      );
    }
    if (data.containsKey('voided')) {
      context.handle(
        _voidedMeta,
        voided.isAcceptableOrUnknown(data['voided']!, _voidedMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PayrollPaymentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PayrollPaymentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      employeeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_id'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      grossCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gross_cents'],
      )!,
      netCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}net_cents'],
      )!,
      employerSsCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}employer_ss_cents'],
      )!,
      paymentMethodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method_id'],
      ),
      voided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voided'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $PayrollPaymentsTable createAlias(String alias) {
    return $PayrollPaymentsTable(attachedDatabase, alias);
  }
}

class PayrollPaymentData extends DataClass
    implements Insertable<PayrollPaymentData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String employeeId;
  final String month;
  final int grossCents;
  final int netCents;
  final int employerSsCents;
  final String? paymentMethodId;
  final bool voided;
  final String? voidReason;
  const PayrollPaymentData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.employeeId,
    required this.month,
    required this.grossCents,
    required this.netCents,
    required this.employerSsCents,
    this.paymentMethodId,
    required this.voided,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['employee_id'] = Variable<String>(employeeId);
    map['month'] = Variable<String>(month);
    map['gross_cents'] = Variable<int>(grossCents);
    map['net_cents'] = Variable<int>(netCents);
    map['employer_ss_cents'] = Variable<int>(employerSsCents);
    if (!nullToAbsent || paymentMethodId != null) {
      map['payment_method_id'] = Variable<String>(paymentMethodId);
    }
    map['voided'] = Variable<bool>(voided);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  PayrollPaymentsCompanion toCompanion(bool nullToAbsent) {
    return PayrollPaymentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      employeeId: Value(employeeId),
      month: Value(month),
      grossCents: Value(grossCents),
      netCents: Value(netCents),
      employerSsCents: Value(employerSsCents),
      paymentMethodId: paymentMethodId == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentMethodId),
      voided: Value(voided),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory PayrollPaymentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PayrollPaymentData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      employeeId: serializer.fromJson<String>(json['employeeId']),
      month: serializer.fromJson<String>(json['month']),
      grossCents: serializer.fromJson<int>(json['grossCents']),
      netCents: serializer.fromJson<int>(json['netCents']),
      employerSsCents: serializer.fromJson<int>(json['employerSsCents']),
      paymentMethodId: serializer.fromJson<String?>(json['paymentMethodId']),
      voided: serializer.fromJson<bool>(json['voided']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'employeeId': serializer.toJson<String>(employeeId),
      'month': serializer.toJson<String>(month),
      'grossCents': serializer.toJson<int>(grossCents),
      'netCents': serializer.toJson<int>(netCents),
      'employerSsCents': serializer.toJson<int>(employerSsCents),
      'paymentMethodId': serializer.toJson<String?>(paymentMethodId),
      'voided': serializer.toJson<bool>(voided),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  PayrollPaymentData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? employeeId,
    String? month,
    int? grossCents,
    int? netCents,
    int? employerSsCents,
    Value<String?> paymentMethodId = const Value.absent(),
    bool? voided,
    Value<String?> voidReason = const Value.absent(),
  }) => PayrollPaymentData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    employeeId: employeeId ?? this.employeeId,
    month: month ?? this.month,
    grossCents: grossCents ?? this.grossCents,
    netCents: netCents ?? this.netCents,
    employerSsCents: employerSsCents ?? this.employerSsCents,
    paymentMethodId: paymentMethodId.present
        ? paymentMethodId.value
        : this.paymentMethodId,
    voided: voided ?? this.voided,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  PayrollPaymentData copyWithCompanion(PayrollPaymentsCompanion data) {
    return PayrollPaymentData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      employeeId: data.employeeId.present
          ? data.employeeId.value
          : this.employeeId,
      month: data.month.present ? data.month.value : this.month,
      grossCents: data.grossCents.present
          ? data.grossCents.value
          : this.grossCents,
      netCents: data.netCents.present ? data.netCents.value : this.netCents,
      employerSsCents: data.employerSsCents.present
          ? data.employerSsCents.value
          : this.employerSsCents,
      paymentMethodId: data.paymentMethodId.present
          ? data.paymentMethodId.value
          : this.paymentMethodId,
      voided: data.voided.present ? data.voided.value : this.voided,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PayrollPaymentData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('employeeId: $employeeId, ')
          ..write('month: $month, ')
          ..write('grossCents: $grossCents, ')
          ..write('netCents: $netCents, ')
          ..write('employerSsCents: $employerSsCents, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('voided: $voided, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    employeeId,
    month,
    grossCents,
    netCents,
    employerSsCents,
    paymentMethodId,
    voided,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PayrollPaymentData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.employeeId == this.employeeId &&
          other.month == this.month &&
          other.grossCents == this.grossCents &&
          other.netCents == this.netCents &&
          other.employerSsCents == this.employerSsCents &&
          other.paymentMethodId == this.paymentMethodId &&
          other.voided == this.voided &&
          other.voidReason == this.voidReason);
}

class PayrollPaymentsCompanion extends UpdateCompanion<PayrollPaymentData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> employeeId;
  final Value<String> month;
  final Value<int> grossCents;
  final Value<int> netCents;
  final Value<int> employerSsCents;
  final Value<String?> paymentMethodId;
  final Value<bool> voided;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const PayrollPaymentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.employeeId = const Value.absent(),
    this.month = const Value.absent(),
    this.grossCents = const Value.absent(),
    this.netCents = const Value.absent(),
    this.employerSsCents = const Value.absent(),
    this.paymentMethodId = const Value.absent(),
    this.voided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PayrollPaymentsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String employeeId,
    required String month,
    required int grossCents,
    required int netCents,
    required int employerSsCents,
    this.paymentMethodId = const Value.absent(),
    this.voided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       employeeId = Value(employeeId),
       month = Value(month),
       grossCents = Value(grossCents),
       netCents = Value(netCents),
       employerSsCents = Value(employerSsCents);
  static Insertable<PayrollPaymentData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? employeeId,
    Expression<String>? month,
    Expression<int>? grossCents,
    Expression<int>? netCents,
    Expression<int>? employerSsCents,
    Expression<String>? paymentMethodId,
    Expression<bool>? voided,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (employeeId != null) 'employee_id': employeeId,
      if (month != null) 'month': month,
      if (grossCents != null) 'gross_cents': grossCents,
      if (netCents != null) 'net_cents': netCents,
      if (employerSsCents != null) 'employer_ss_cents': employerSsCents,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      if (voided != null) 'voided': voided,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PayrollPaymentsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? employeeId,
    Value<String>? month,
    Value<int>? grossCents,
    Value<int>? netCents,
    Value<int>? employerSsCents,
    Value<String?>? paymentMethodId,
    Value<bool>? voided,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return PayrollPaymentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      employeeId: employeeId ?? this.employeeId,
      month: month ?? this.month,
      grossCents: grossCents ?? this.grossCents,
      netCents: netCents ?? this.netCents,
      employerSsCents: employerSsCents ?? this.employerSsCents,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      voided: voided ?? this.voided,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (employeeId.present) {
      map['employee_id'] = Variable<String>(employeeId.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (grossCents.present) {
      map['gross_cents'] = Variable<int>(grossCents.value);
    }
    if (netCents.present) {
      map['net_cents'] = Variable<int>(netCents.value);
    }
    if (employerSsCents.present) {
      map['employer_ss_cents'] = Variable<int>(employerSsCents.value);
    }
    if (paymentMethodId.present) {
      map['payment_method_id'] = Variable<String>(paymentMethodId.value);
    }
    if (voided.present) {
      map['voided'] = Variable<bool>(voided.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PayrollPaymentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('employeeId: $employeeId, ')
          ..write('month: $month, ')
          ..write('grossCents: $grossCents, ')
          ..write('netCents: $netCents, ')
          ..write('employerSsCents: $employerSsCents, ')
          ..write('paymentMethodId: $paymentMethodId, ')
          ..write('voided: $voided, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WithdrawalTypesTable extends WithdrawalTypes
    with TableInfo<$WithdrawalTypesTable, WithdrawalTypeData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WithdrawalTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    code,
    name,
    sortOrder,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tipo_retirada';
  @override
  VerificationContext validateIntegrity(
    Insertable<WithdrawalTypeData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WithdrawalTypeData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WithdrawalTypeData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $WithdrawalTypesTable createAlias(String alias) {
    return $WithdrawalTypesTable(attachedDatabase, alias);
  }
}

class WithdrawalTypeData extends DataClass
    implements Insertable<WithdrawalTypeData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String? code;
  final String name;
  final int sortOrder;
  final bool active;
  const WithdrawalTypeData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    this.code,
    required this.name,
    required this.sortOrder,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['name'] = Variable<String>(name);
    map['sort_order'] = Variable<int>(sortOrder);
    map['active'] = Variable<bool>(active);
    return map;
  }

  WithdrawalTypesCompanion toCompanion(bool nullToAbsent) {
    return WithdrawalTypesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      name: Value(name),
      sortOrder: Value(sortOrder),
      active: Value(active),
    );
  }

  factory WithdrawalTypeData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WithdrawalTypeData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      code: serializer.fromJson<String?>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'code': serializer.toJson<String?>(code),
      'name': serializer.toJson<String>(name),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'active': serializer.toJson<bool>(active),
    };
  }

  WithdrawalTypeData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    Value<String?> code = const Value.absent(),
    String? name,
    int? sortOrder,
    bool? active,
  }) => WithdrawalTypeData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    code: code.present ? code.value : this.code,
    name: name ?? this.name,
    sortOrder: sortOrder ?? this.sortOrder,
    active: active ?? this.active,
  );
  WithdrawalTypeData copyWithCompanion(WithdrawalTypesCompanion data) {
    return WithdrawalTypeData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WithdrawalTypeData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    code,
    name,
    sortOrder,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WithdrawalTypeData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.code == this.code &&
          other.name == this.name &&
          other.sortOrder == this.sortOrder &&
          other.active == this.active);
}

class WithdrawalTypesCompanion extends UpdateCompanion<WithdrawalTypeData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String?> code;
  final Value<String> name;
  final Value<int> sortOrder;
  final Value<bool> active;
  final Value<int> rowid;
  const WithdrawalTypesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WithdrawalTypesCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    this.code = const Value.absent(),
    required String name,
    required int sortOrder,
    this.active = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       sortOrder = Value(sortOrder);
  static Insertable<WithdrawalTypeData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? code,
    Expression<String>? name,
    Expression<int>? sortOrder,
    Expression<bool>? active,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (active != null) 'active': active,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WithdrawalTypesCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String?>? code,
    Value<String>? name,
    Value<int>? sortOrder,
    Value<bool>? active,
    Value<int>? rowid,
  }) {
    return WithdrawalTypesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      code: code ?? this.code,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      active: active ?? this.active,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WithdrawalTypesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('active: $active, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WithdrawalsTable extends Withdrawals
    with TableInfo<$WithdrawalsTable, WithdrawalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WithdrawalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _dayIdMeta = const VerificationMeta('dayId');
  @override
  late final GeneratedColumn<String> dayId = GeneratedColumn<String>(
    'day_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES dia_caja (id)',
    ),
  );
  static const VerificationMeta _amountCentsMeta = const VerificationMeta(
    'amountCents',
  );
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
    'amount_cents',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _withdrawalTypeIdMeta = const VerificationMeta(
    'withdrawalTypeId',
  );
  @override
  late final GeneratedColumn<String> withdrawalTypeId = GeneratedColumn<String>(
    'withdrawal_type_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tipo_retirada (id)',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedMeta = const VerificationMeta('voided');
  @override
  late final GeneratedColumn<bool> voided = GeneratedColumn<bool>(
    'voided',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("voided" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _voidReasonMeta = const VerificationMeta(
    'voidReason',
  );
  @override
  late final GeneratedColumn<String> voidReason = GeneratedColumn<String>(
    'void_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    dayId,
    amountCents,
    withdrawalTypeId,
    note,
    voided,
    voidReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'retirada';
  @override
  VerificationContext validateIntegrity(
    Insertable<WithdrawalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('day_id')) {
      context.handle(
        _dayIdMeta,
        dayId.isAcceptableOrUnknown(data['day_id']!, _dayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dayIdMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
        _amountCentsMeta,
        amountCents.isAcceptableOrUnknown(
          data['amount_cents']!,
          _amountCentsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('withdrawal_type_id')) {
      context.handle(
        _withdrawalTypeIdMeta,
        withdrawalTypeId.isAcceptableOrUnknown(
          data['withdrawal_type_id']!,
          _withdrawalTypeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_withdrawalTypeIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('voided')) {
      context.handle(
        _voidedMeta,
        voided.isAcceptableOrUnknown(data['voided']!, _voidedMeta),
      );
    }
    if (data.containsKey('void_reason')) {
      context.handle(
        _voidReasonMeta,
        voidReason.isAcceptableOrUnknown(data['void_reason']!, _voidReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WithdrawalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WithdrawalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      dayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_id'],
      )!,
      amountCents: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_cents'],
      )!,
      withdrawalTypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}withdrawal_type_id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      voided: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}voided'],
      )!,
      voidReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}void_reason'],
      ),
    );
  }

  @override
  $WithdrawalsTable createAlias(String alias) {
    return $WithdrawalsTable(attachedDatabase, alias);
  }
}

class WithdrawalData extends DataClass implements Insertable<WithdrawalData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String dayId;
  final int amountCents;
  final String withdrawalTypeId;
  final String? note;
  final bool voided;
  final String? voidReason;
  const WithdrawalData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.dayId,
    required this.amountCents,
    required this.withdrawalTypeId,
    this.note,
    required this.voided,
    this.voidReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['day_id'] = Variable<String>(dayId);
    map['amount_cents'] = Variable<int>(amountCents);
    map['withdrawal_type_id'] = Variable<String>(withdrawalTypeId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['voided'] = Variable<bool>(voided);
    if (!nullToAbsent || voidReason != null) {
      map['void_reason'] = Variable<String>(voidReason);
    }
    return map;
  }

  WithdrawalsCompanion toCompanion(bool nullToAbsent) {
    return WithdrawalsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      dayId: Value(dayId),
      amountCents: Value(amountCents),
      withdrawalTypeId: Value(withdrawalTypeId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      voided: Value(voided),
      voidReason: voidReason == null && nullToAbsent
          ? const Value.absent()
          : Value(voidReason),
    );
  }

  factory WithdrawalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WithdrawalData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      dayId: serializer.fromJson<String>(json['dayId']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      withdrawalTypeId: serializer.fromJson<String>(json['withdrawalTypeId']),
      note: serializer.fromJson<String?>(json['note']),
      voided: serializer.fromJson<bool>(json['voided']),
      voidReason: serializer.fromJson<String?>(json['voidReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'dayId': serializer.toJson<String>(dayId),
      'amountCents': serializer.toJson<int>(amountCents),
      'withdrawalTypeId': serializer.toJson<String>(withdrawalTypeId),
      'note': serializer.toJson<String?>(note),
      'voided': serializer.toJson<bool>(voided),
      'voidReason': serializer.toJson<String?>(voidReason),
    };
  }

  WithdrawalData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? dayId,
    int? amountCents,
    String? withdrawalTypeId,
    Value<String?> note = const Value.absent(),
    bool? voided,
    Value<String?> voidReason = const Value.absent(),
  }) => WithdrawalData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    dayId: dayId ?? this.dayId,
    amountCents: amountCents ?? this.amountCents,
    withdrawalTypeId: withdrawalTypeId ?? this.withdrawalTypeId,
    note: note.present ? note.value : this.note,
    voided: voided ?? this.voided,
    voidReason: voidReason.present ? voidReason.value : this.voidReason,
  );
  WithdrawalData copyWithCompanion(WithdrawalsCompanion data) {
    return WithdrawalData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      dayId: data.dayId.present ? data.dayId.value : this.dayId,
      amountCents: data.amountCents.present
          ? data.amountCents.value
          : this.amountCents,
      withdrawalTypeId: data.withdrawalTypeId.present
          ? data.withdrawalTypeId.value
          : this.withdrawalTypeId,
      note: data.note.present ? data.note.value : this.note,
      voided: data.voided.present ? data.voided.value : this.voided,
      voidReason: data.voidReason.present
          ? data.voidReason.value
          : this.voidReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WithdrawalData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('dayId: $dayId, ')
          ..write('amountCents: $amountCents, ')
          ..write('withdrawalTypeId: $withdrawalTypeId, ')
          ..write('note: $note, ')
          ..write('voided: $voided, ')
          ..write('voidReason: $voidReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    author,
    dayId,
    amountCents,
    withdrawalTypeId,
    note,
    voided,
    voidReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WithdrawalData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.dayId == this.dayId &&
          other.amountCents == this.amountCents &&
          other.withdrawalTypeId == this.withdrawalTypeId &&
          other.note == this.note &&
          other.voided == this.voided &&
          other.voidReason == this.voidReason);
}

class WithdrawalsCompanion extends UpdateCompanion<WithdrawalData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> dayId;
  final Value<int> amountCents;
  final Value<String> withdrawalTypeId;
  final Value<String?> note;
  final Value<bool> voided;
  final Value<String?> voidReason;
  final Value<int> rowid;
  const WithdrawalsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.dayId = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.withdrawalTypeId = const Value.absent(),
    this.note = const Value.absent(),
    this.voided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WithdrawalsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String dayId,
    required int amountCents,
    required String withdrawalTypeId,
    this.note = const Value.absent(),
    this.voided = const Value.absent(),
    this.voidReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       dayId = Value(dayId),
       amountCents = Value(amountCents),
       withdrawalTypeId = Value(withdrawalTypeId);
  static Insertable<WithdrawalData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? dayId,
    Expression<int>? amountCents,
    Expression<String>? withdrawalTypeId,
    Expression<String>? note,
    Expression<bool>? voided,
    Expression<String>? voidReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (dayId != null) 'day_id': dayId,
      if (amountCents != null) 'amount_cents': amountCents,
      if (withdrawalTypeId != null) 'withdrawal_type_id': withdrawalTypeId,
      if (note != null) 'note': note,
      if (voided != null) 'voided': voided,
      if (voidReason != null) 'void_reason': voidReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WithdrawalsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? dayId,
    Value<int>? amountCents,
    Value<String>? withdrawalTypeId,
    Value<String?>? note,
    Value<bool>? voided,
    Value<String?>? voidReason,
    Value<int>? rowid,
  }) {
    return WithdrawalsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      dayId: dayId ?? this.dayId,
      amountCents: amountCents ?? this.amountCents,
      withdrawalTypeId: withdrawalTypeId ?? this.withdrawalTypeId,
      note: note ?? this.note,
      voided: voided ?? this.voided,
      voidReason: voidReason ?? this.voidReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (dayId.present) {
      map['day_id'] = Variable<String>(dayId.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (withdrawalTypeId.present) {
      map['withdrawal_type_id'] = Variable<String>(withdrawalTypeId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (voided.present) {
      map['voided'] = Variable<bool>(voided.value);
    }
    if (voidReason.present) {
      map['void_reason'] = Variable<String>(voidReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WithdrawalsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('dayId: $dayId, ')
          ..write('amountCents: $amountCents, ')
          ..write('withdrawalTypeId: $withdrawalTypeId, ')
          ..write('note: $note, ')
          ..write('voided: $voided, ')
          ..write('voidReason: $voidReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeriodsTable extends Periods with TableInfo<$PeriodsTable, PeriodData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeriodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('owner'),
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<PeriodStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PeriodStatus>($PeriodsTable.$converterstatus);
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<String> closedAt = GeneratedColumn<String>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    author,
    month,
    status,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'periodo';
  @override
  VerificationContext validateIntegrity(
    Insertable<PeriodData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PeriodData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PeriodData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      status: $PeriodsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $PeriodsTable createAlias(String alias) {
    return $PeriodsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PeriodStatus, String, String> $converterstatus =
      const EnumNameConverter<PeriodStatus>(PeriodStatus.values);
}

class PeriodData extends DataClass implements Insertable<PeriodData> {
  final String id;
  final String createdAt;
  final String updatedAt;
  final String author;
  final String month;
  final PeriodStatus status;
  final String? closedAt;
  const PeriodData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.month,
    required this.status,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    map['author'] = Variable<String>(author);
    map['month'] = Variable<String>(month);
    {
      map['status'] = Variable<String>(
        $PeriodsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<String>(closedAt);
    }
    return map;
  }

  PeriodsCompanion toCompanion(bool nullToAbsent) {
    return PeriodsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      author: Value(author),
      month: Value(month),
      status: Value(status),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory PeriodData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PeriodData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      author: serializer.fromJson<String>(json['author']),
      month: serializer.fromJson<String>(json['month']),
      status: $PeriodsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      closedAt: serializer.fromJson<String?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'author': serializer.toJson<String>(author),
      'month': serializer.toJson<String>(month),
      'status': serializer.toJson<String>(
        $PeriodsTable.$converterstatus.toJson(status),
      ),
      'closedAt': serializer.toJson<String?>(closedAt),
    };
  }

  PeriodData copyWith({
    String? id,
    String? createdAt,
    String? updatedAt,
    String? author,
    String? month,
    PeriodStatus? status,
    Value<String?> closedAt = const Value.absent(),
  }) => PeriodData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    author: author ?? this.author,
    month: month ?? this.month,
    status: status ?? this.status,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  PeriodData copyWithCompanion(PeriodsCompanion data) {
    return PeriodData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      author: data.author.present ? data.author.value : this.author,
      month: data.month.present ? data.month.value : this.month,
      status: data.status.present ? data.status.value : this.status,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PeriodData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('month: $month, ')
          ..write('status: $status, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, author, month, status, closedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PeriodData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.author == this.author &&
          other.month == this.month &&
          other.status == this.status &&
          other.closedAt == this.closedAt);
}

class PeriodsCompanion extends UpdateCompanion<PeriodData> {
  final Value<String> id;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String> author;
  final Value<String> month;
  final Value<PeriodStatus> status;
  final Value<String?> closedAt;
  final Value<int> rowid;
  const PeriodsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.author = const Value.absent(),
    this.month = const Value.absent(),
    this.status = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeriodsCompanion.insert({
    required String id,
    required String createdAt,
    required String updatedAt,
    this.author = const Value.absent(),
    required String month,
    required PeriodStatus status,
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       month = Value(month),
       status = Value(status);
  static Insertable<PeriodData> custom({
    Expression<String>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? author,
    Expression<String>? month,
    Expression<String>? status,
    Expression<String>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (author != null) 'author': author,
      if (month != null) 'month': month,
      if (status != null) 'status': status,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeriodsCompanion copyWith({
    Value<String>? id,
    Value<String>? createdAt,
    Value<String>? updatedAt,
    Value<String>? author,
    Value<String>? month,
    Value<PeriodStatus>? status,
    Value<String?>? closedAt,
    Value<int>? rowid,
  }) {
    return PeriodsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      month: month ?? this.month,
      status: status ?? this.status,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $PeriodsTable.$converterstatus.toSql(status.value),
      );
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<String>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeriodsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('author: $author, ')
          ..write('month: $month, ')
          ..write('status: $status, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChangeLogTable extends ChangeLog
    with TableInfo<$ChangeLogTable, ChangeLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChangeLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<String> at = GeneratedColumn<String>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldValueMeta = const VerificationMeta(
    'oldValue',
  );
  @override
  late final GeneratedColumn<String> oldValue = GeneratedColumn<String>(
    'old_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _prevHashMeta = const VerificationMeta(
    'prevHash',
  );
  @override
  late final GeneratedColumn<String> prevHash = GeneratedColumn<String>(
    'prev_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    at,
    entity,
    recordId,
    field,
    oldValue,
    newValue,
    reason,
    author,
    prevHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'historial_cambio';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChangeLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('old_value')) {
      context.handle(
        _oldValueMeta,
        oldValue.isAcceptableOrUnknown(data['old_value']!, _oldValueMeta),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    } else if (isInserting) {
      context.missing(_authorMeta);
    }
    if (data.containsKey('prev_hash')) {
      context.handle(
        _prevHashMeta,
        prevHash.isAcceptableOrUnknown(data['prev_hash']!, _prevHashMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChangeLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChangeLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}at'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      oldValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      prevHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prev_hash'],
      ),
    );
  }

  @override
  $ChangeLogTable createAlias(String alias) {
    return $ChangeLogTable(attachedDatabase, alias);
  }
}

class ChangeLogData extends DataClass implements Insertable<ChangeLogData> {
  final String id;
  final String at;
  final String entity;
  final String recordId;
  final String field;
  final String? oldValue;
  final String? newValue;
  final String? reason;
  final String author;
  final String? prevHash;
  const ChangeLogData({
    required this.id,
    required this.at,
    required this.entity,
    required this.recordId,
    required this.field,
    this.oldValue,
    this.newValue,
    this.reason,
    required this.author,
    this.prevHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['at'] = Variable<String>(at);
    map['entity'] = Variable<String>(entity);
    map['record_id'] = Variable<String>(recordId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || oldValue != null) {
      map['old_value'] = Variable<String>(oldValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    map['author'] = Variable<String>(author);
    if (!nullToAbsent || prevHash != null) {
      map['prev_hash'] = Variable<String>(prevHash);
    }
    return map;
  }

  ChangeLogCompanion toCompanion(bool nullToAbsent) {
    return ChangeLogCompanion(
      id: Value(id),
      at: Value(at),
      entity: Value(entity),
      recordId: Value(recordId),
      field: Value(field),
      oldValue: oldValue == null && nullToAbsent
          ? const Value.absent()
          : Value(oldValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      author: Value(author),
      prevHash: prevHash == null && nullToAbsent
          ? const Value.absent()
          : Value(prevHash),
    );
  }

  factory ChangeLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChangeLogData(
      id: serializer.fromJson<String>(json['id']),
      at: serializer.fromJson<String>(json['at']),
      entity: serializer.fromJson<String>(json['entity']),
      recordId: serializer.fromJson<String>(json['recordId']),
      field: serializer.fromJson<String>(json['field']),
      oldValue: serializer.fromJson<String?>(json['oldValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      reason: serializer.fromJson<String?>(json['reason']),
      author: serializer.fromJson<String>(json['author']),
      prevHash: serializer.fromJson<String?>(json['prevHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'at': serializer.toJson<String>(at),
      'entity': serializer.toJson<String>(entity),
      'recordId': serializer.toJson<String>(recordId),
      'field': serializer.toJson<String>(field),
      'oldValue': serializer.toJson<String?>(oldValue),
      'newValue': serializer.toJson<String?>(newValue),
      'reason': serializer.toJson<String?>(reason),
      'author': serializer.toJson<String>(author),
      'prevHash': serializer.toJson<String?>(prevHash),
    };
  }

  ChangeLogData copyWith({
    String? id,
    String? at,
    String? entity,
    String? recordId,
    String? field,
    Value<String?> oldValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    String? author,
    Value<String?> prevHash = const Value.absent(),
  }) => ChangeLogData(
    id: id ?? this.id,
    at: at ?? this.at,
    entity: entity ?? this.entity,
    recordId: recordId ?? this.recordId,
    field: field ?? this.field,
    oldValue: oldValue.present ? oldValue.value : this.oldValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    reason: reason.present ? reason.value : this.reason,
    author: author ?? this.author,
    prevHash: prevHash.present ? prevHash.value : this.prevHash,
  );
  ChangeLogData copyWithCompanion(ChangeLogCompanion data) {
    return ChangeLogData(
      id: data.id.present ? data.id.value : this.id,
      at: data.at.present ? data.at.value : this.at,
      entity: data.entity.present ? data.entity.value : this.entity,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      field: data.field.present ? data.field.value : this.field,
      oldValue: data.oldValue.present ? data.oldValue.value : this.oldValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      reason: data.reason.present ? data.reason.value : this.reason,
      author: data.author.present ? data.author.value : this.author,
      prevHash: data.prevHash.present ? data.prevHash.value : this.prevHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogData(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('reason: $reason, ')
          ..write('author: $author, ')
          ..write('prevHash: $prevHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    at,
    entity,
    recordId,
    field,
    oldValue,
    newValue,
    reason,
    author,
    prevHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChangeLogData &&
          other.id == this.id &&
          other.at == this.at &&
          other.entity == this.entity &&
          other.recordId == this.recordId &&
          other.field == this.field &&
          other.oldValue == this.oldValue &&
          other.newValue == this.newValue &&
          other.reason == this.reason &&
          other.author == this.author &&
          other.prevHash == this.prevHash);
}

class ChangeLogCompanion extends UpdateCompanion<ChangeLogData> {
  final Value<String> id;
  final Value<String> at;
  final Value<String> entity;
  final Value<String> recordId;
  final Value<String> field;
  final Value<String?> oldValue;
  final Value<String?> newValue;
  final Value<String?> reason;
  final Value<String> author;
  final Value<String?> prevHash;
  final Value<int> rowid;
  const ChangeLogCompanion({
    this.id = const Value.absent(),
    this.at = const Value.absent(),
    this.entity = const Value.absent(),
    this.recordId = const Value.absent(),
    this.field = const Value.absent(),
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.reason = const Value.absent(),
    this.author = const Value.absent(),
    this.prevHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChangeLogCompanion.insert({
    required String id,
    required String at,
    required String entity,
    required String recordId,
    required String field,
    this.oldValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.reason = const Value.absent(),
    required String author,
    this.prevHash = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       at = Value(at),
       entity = Value(entity),
       recordId = Value(recordId),
       field = Value(field),
       author = Value(author);
  static Insertable<ChangeLogData> custom({
    Expression<String>? id,
    Expression<String>? at,
    Expression<String>? entity,
    Expression<String>? recordId,
    Expression<String>? field,
    Expression<String>? oldValue,
    Expression<String>? newValue,
    Expression<String>? reason,
    Expression<String>? author,
    Expression<String>? prevHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (at != null) 'at': at,
      if (entity != null) 'entity': entity,
      if (recordId != null) 'record_id': recordId,
      if (field != null) 'field': field,
      if (oldValue != null) 'old_value': oldValue,
      if (newValue != null) 'new_value': newValue,
      if (reason != null) 'reason': reason,
      if (author != null) 'author': author,
      if (prevHash != null) 'prev_hash': prevHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChangeLogCompanion copyWith({
    Value<String>? id,
    Value<String>? at,
    Value<String>? entity,
    Value<String>? recordId,
    Value<String>? field,
    Value<String?>? oldValue,
    Value<String?>? newValue,
    Value<String?>? reason,
    Value<String>? author,
    Value<String?>? prevHash,
    Value<int>? rowid,
  }) {
    return ChangeLogCompanion(
      id: id ?? this.id,
      at: at ?? this.at,
      entity: entity ?? this.entity,
      recordId: recordId ?? this.recordId,
      field: field ?? this.field,
      oldValue: oldValue ?? this.oldValue,
      newValue: newValue ?? this.newValue,
      reason: reason ?? this.reason,
      author: author ?? this.author,
      prevHash: prevHash ?? this.prevHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (at.present) {
      map['at'] = Variable<String>(at.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (oldValue.present) {
      map['old_value'] = Variable<String>(oldValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (prevHash.present) {
      map['prev_hash'] = Variable<String>(prevHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChangeLogCompanion(')
          ..write('id: $id, ')
          ..write('at: $at, ')
          ..write('entity: $entity, ')
          ..write('recordId: $recordId, ')
          ..write('field: $field, ')
          ..write('oldValue: $oldValue, ')
          ..write('newValue: $newValue, ')
          ..write('reason: $reason, ')
          ..write('author: $author, ')
          ..write('prevHash: $prevHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ajustes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String key;
  final String? value;
  const SettingData({required this.key, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value: value == null && nullToAbsent
          ? const Value.absent()
          : Value(value),
    );
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
    };
  }

  SettingData copyWith({
    String? key,
    Value<String?> value = const Value.absent(),
  }) => SettingData(
    key: key ?? this.key,
    value: value.present ? value.value : this.value,
  );
  SettingData copyWithCompanion(SettingsTableCompanion data) {
    return SettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String?>? value,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DaysTable days = $DaysTable(this);
  late final $PaymentMethodsTable paymentMethods = $PaymentMethodsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $CoversTable covers = $CoversTable(this);
  late final $ExpenseCategoriesTable expenseCategories =
      $ExpenseCategoriesTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $FixedCostsTable fixedCosts = $FixedCostsTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $EmployeesTable employees = $EmployeesTable(this);
  late final $PayrollPaymentsTable payrollPayments = $PayrollPaymentsTable(
    this,
  );
  late final $WithdrawalTypesTable withdrawalTypes = $WithdrawalTypesTable(
    this,
  );
  late final $WithdrawalsTable withdrawals = $WithdrawalsTable(this);
  late final $PeriodsTable periods = $PeriodsTable(this);
  late final $ChangeLogTable changeLog = $ChangeLogTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    days,
    paymentMethods,
    sales,
    covers,
    expenseCategories,
    suppliers,
    fixedCosts,
    expenses,
    receipts,
    employees,
    payrollPayments,
    withdrawalTypes,
    withdrawals,
    periods,
    changeLog,
    settingsTable,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$DaysTableCreateCompanionBuilder = DaysCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String date,
  required DayStatus status,
  required int openingFloatCents,
  Value<int?> countedCashCents,
  Value<String?> denominationCounts,
  Value<int?> terminalTotalCents,
  Value<int> cashTipsCents,
  Value<int> cardTipsCents,
  Value<int?> cashDiffCents,
  Value<int?> cardDiffCents,
  Value<String?> comment,
  Value<String?> closedAt,
  Value<int> rowid,
});
typedef $$DaysTableUpdateCompanionBuilder = DaysCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> date,
  Value<DayStatus> status,
  Value<int> openingFloatCents,
  Value<int?> countedCashCents,
  Value<String?> denominationCounts,
  Value<int?> terminalTotalCents,
  Value<int> cashTipsCents,
  Value<int> cardTipsCents,
  Value<int?> cashDiffCents,
  Value<int?> cardDiffCents,
  Value<String?> comment,
  Value<String?> closedAt,
  Value<int> rowid,
});

final class $$DaysTableReferences
    extends BaseReferences<_$AppDatabase, $DaysTable, DayData> {
  $$DaysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<SaleData>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: 'dia_caja__id__venta__day_id',
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager(
      $_db,
      $_db.sales,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CoversTable, List<CoverData>> _coversRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.covers,
    aliasName: 'dia_caja__id__comensales__day_id',
  );

  $$CoversTableProcessedTableManager get coversRefs {
    final manager = $$CoversTableTableManager(
      $_db,
      $_db.covers,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_coversRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseData>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'dia_caja__id__gasto__paid_in_cash_day_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.paidInCashDayId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WithdrawalsTable, List<WithdrawalData>>
  _withdrawalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.withdrawals,
    aliasName: 'dia_caja__id__retirada__day_id',
  );

  $$WithdrawalsTableProcessedTableManager get withdrawalsRefs {
    final manager = $$WithdrawalsTableTableManager(
      $_db,
      $_db.withdrawals,
    ).filter((f) => f.dayId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_withdrawalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DaysTableFilterComposer extends Composer<_$AppDatabase, $DaysTable> {
  $$DaysTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DayStatus, DayStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get openingFloatCents => $composableBuilder(
    column: $table.openingFloatCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get countedCashCents => $composableBuilder(
    column: $table.countedCashCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get denominationCounts => $composableBuilder(
    column: $table.denominationCounts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get terminalTotalCents => $composableBuilder(
    column: $table.terminalTotalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashTipsCents => $composableBuilder(
    column: $table.cashTipsCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardTipsCents => $composableBuilder(
    column: $table.cardTipsCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cashDiffCents => $composableBuilder(
    column: $table.cashDiffCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardDiffCents => $composableBuilder(
    column: $table.cardDiffCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> coversRefs(
    Expression<bool> Function($$CoversTableFilterComposer f) f,
  ) {
    final $$CoversTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.covers,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoversTableFilterComposer(
            $db: $db,
            $table: $db.covers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paidInCashDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> withdrawalsRefs(
    Expression<bool> Function($$WithdrawalsTableFilterComposer f) f,
  ) {
    final $$WithdrawalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.withdrawals,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalsTableFilterComposer(
            $db: $db,
            $table: $db.withdrawals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DaysTableOrderingComposer extends Composer<_$AppDatabase, $DaysTable> {
  $$DaysTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingFloatCents => $composableBuilder(
    column: $table.openingFloatCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get countedCashCents => $composableBuilder(
    column: $table.countedCashCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get denominationCounts => $composableBuilder(
    column: $table.denominationCounts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get terminalTotalCents => $composableBuilder(
    column: $table.terminalTotalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashTipsCents => $composableBuilder(
    column: $table.cashTipsCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardTipsCents => $composableBuilder(
    column: $table.cardTipsCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cashDiffCents => $composableBuilder(
    column: $table.cashDiffCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardDiffCents => $composableBuilder(
    column: $table.cardDiffCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DaysTableAnnotationComposer
    extends Composer<_$AppDatabase, $DaysTable> {
  $$DaysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DayStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get openingFloatCents => $composableBuilder(
    column: $table.openingFloatCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get countedCashCents => $composableBuilder(
    column: $table.countedCashCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get denominationCounts => $composableBuilder(
    column: $table.denominationCounts,
    builder: (column) => column,
  );

  GeneratedColumn<int> get terminalTotalCents => $composableBuilder(
    column: $table.terminalTotalCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cashTipsCents => $composableBuilder(
    column: $table.cashTipsCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardTipsCents => $composableBuilder(
    column: $table.cardTipsCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cashDiffCents => $composableBuilder(
    column: $table.cashDiffCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardDiffCents => $composableBuilder(
    column: $table.cardDiffCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> coversRefs<T extends Object>(
    Expression<T> Function($$CoversTableAnnotationComposer a) f,
  ) {
    final $$CoversTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.covers,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoversTableAnnotationComposer(
            $db: $db,
            $table: $db.covers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paidInCashDayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> withdrawalsRefs<T extends Object>(
    Expression<T> Function($$WithdrawalsTableAnnotationComposer a) f,
  ) {
    final $$WithdrawalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.withdrawals,
      getReferencedColumn: (t) => t.dayId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalsTableAnnotationComposer(
            $db: $db,
            $table: $db.withdrawals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DaysTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DaysTable,
          DayData,
          $$DaysTableFilterComposer,
          $$DaysTableOrderingComposer,
          $$DaysTableAnnotationComposer,
          $$DaysTableCreateCompanionBuilder,
          $$DaysTableUpdateCompanionBuilder,
          (DayData, $$DaysTableReferences),
          DayData,
          PrefetchHooks Function({
            bool salesRefs,
            bool coversRefs,
            bool expensesRefs,
            bool withdrawalsRefs,
          })
        > {
  $$DaysTableTableManager(_$AppDatabase db, $DaysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DaysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DaysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DaysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<DayStatus> status = const Value.absent(),
                Value<int> openingFloatCents = const Value.absent(),
                Value<int?> countedCashCents = const Value.absent(),
                Value<String?> denominationCounts = const Value.absent(),
                Value<int?> terminalTotalCents = const Value.absent(),
                Value<int> cashTipsCents = const Value.absent(),
                Value<int> cardTipsCents = const Value.absent(),
                Value<int?> cashDiffCents = const Value.absent(),
                Value<int?> cardDiffCents = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaysCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                date: date,
                status: status,
                openingFloatCents: openingFloatCents,
                countedCashCents: countedCashCents,
                denominationCounts: denominationCounts,
                terminalTotalCents: terminalTotalCents,
                cashTipsCents: cashTipsCents,
                cardTipsCents: cardTipsCents,
                cashDiffCents: cashDiffCents,
                cardDiffCents: cardDiffCents,
                comment: comment,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String date,
                required DayStatus status,
                required int openingFloatCents,
                Value<int?> countedCashCents = const Value.absent(),
                Value<String?> denominationCounts = const Value.absent(),
                Value<int?> terminalTotalCents = const Value.absent(),
                Value<int> cashTipsCents = const Value.absent(),
                Value<int> cardTipsCents = const Value.absent(),
                Value<int?> cashDiffCents = const Value.absent(),
                Value<int?> cardDiffCents = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DaysCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                date: date,
                status: status,
                openingFloatCents: openingFloatCents,
                countedCashCents: countedCashCents,
                denominationCounts: denominationCounts,
                terminalTotalCents: terminalTotalCents,
                cashTipsCents: cashTipsCents,
                cardTipsCents: cardTipsCents,
                cashDiffCents: cashDiffCents,
                cardDiffCents: cardDiffCents,
                comment: comment,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DaysTable, DayData>(table),
                  $$DaysTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                salesRefs = false,
                coversRefs = false,
                expensesRefs = false,
                withdrawalsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (salesRefs) db.sales,
                    if (coversRefs) db.covers,
                    if (expensesRefs) db.expenses,
                    if (withdrawalsRefs) db.withdrawals,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (salesRefs)
                        await $_getPrefetchedDataByColumns<
                          DayData,
                          $DaysTable,
                          SaleData,
                          $SalesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DaysTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DaysTableReferences(db, table, p0).salesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'day_id',
                          typedResults: items,
                        ),
                      if (coversRefs)
                        await $_getPrefetchedDataByColumns<
                          DayData,
                          $DaysTable,
                          CoverData,
                          $CoversTable
                        >(
                          currentTable: table,
                          referencedTable: $$DaysTableReferences
                              ._coversRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DaysTableReferences(db, table, p0).coversRefs,
                          currentColumn: 'id',
                          referencedColumn: 'day_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          DayData,
                          $DaysTable,
                          ExpenseData,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DaysTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DaysTableReferences(db, table, p0).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'paid_in_cash_day_id',
                          typedResults: items,
                        ),
                      if (withdrawalsRefs)
                        await $_getPrefetchedDataByColumns<
                          DayData,
                          $DaysTable,
                          WithdrawalData,
                          $WithdrawalsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DaysTableReferences
                              ._withdrawalsRefsTable(db),
                          managerFromTypedResult: (p0) => $$DaysTableReferences(
                            db,
                            table,
                            p0,
                          ).withdrawalsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'day_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DaysTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DaysTable,
      DayData,
      $$DaysTableFilterComposer,
      $$DaysTableOrderingComposer,
      $$DaysTableAnnotationComposer,
      $$DaysTableCreateCompanionBuilder,
      $$DaysTableUpdateCompanionBuilder,
      (DayData, $$DaysTableReferences),
      DayData,
      PrefetchHooks Function({
        bool salesRefs,
        bool coversRefs,
        bool expensesRefs,
        bool withdrawalsRefs,
      })
    >;
typedef $$PaymentMethodsTableCreateCompanionBuilder =
    PaymentMethodsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String> author,
      Value<String?> code,
      required String name,
      required PaymentKind kind,
      required int sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$PaymentMethodsTableUpdateCompanionBuilder =
    PaymentMethodsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> author,
      Value<String?> code,
      Value<String> name,
      Value<PaymentKind> kind,
      Value<int> sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$PaymentMethodsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PaymentMethodsTable, PaymentMethodData> {
  $$PaymentMethodsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SalesTable, List<SaleData>> _salesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sales,
    aliasName: 'forma_pago__id__venta__payment_method_id',
  );

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager($_db, $_db.sales).filter(
      (f) => f.paymentMethodId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseData>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'forma_pago__id__gasto__payment_method_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses).filter(
      (f) => f.paymentMethodId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PayrollPaymentsTable, List<PayrollPaymentData>>
  _payrollPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollPayments,
    aliasName: 'forma_pago__id__pago_nomina__payment_method_id',
  );

  $$PayrollPaymentsTableProcessedTableManager get payrollPaymentsRefs {
    final manager =
        $$PayrollPaymentsTableTableManager($_db, $_db.payrollPayments).filter(
          (f) => f.paymentMethodId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _payrollPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PaymentMethodsTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentKind, PaymentKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> salesRefs(
    Expression<bool> Function($$SalesTableFilterComposer f) f,
  ) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableFilterComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> payrollPaymentsRefs(
    Expression<bool> Function($$PayrollPaymentsTableFilterComposer f) f,
  ) {
    final $$PayrollPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollPayments,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payrollPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentMethodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentMethodsTable> {
  $$PaymentMethodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PaymentKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
    Expression<T> Function($$SalesTableAnnotationComposer a) f,
  ) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sales,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SalesTableAnnotationComposer(
            $db: $db,
            $table: $db.sales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> payrollPaymentsRefs<T extends Object>(
    Expression<T> Function($$PayrollPaymentsTableAnnotationComposer a) f,
  ) {
    final $$PayrollPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollPayments,
      getReferencedColumn: (t) => t.paymentMethodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PaymentMethodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentMethodsTable,
          PaymentMethodData,
          $$PaymentMethodsTableFilterComposer,
          $$PaymentMethodsTableOrderingComposer,
          $$PaymentMethodsTableAnnotationComposer,
          $$PaymentMethodsTableCreateCompanionBuilder,
          $$PaymentMethodsTableUpdateCompanionBuilder,
          (PaymentMethodData, $$PaymentMethodsTableReferences),
          PaymentMethodData,
          PrefetchHooks Function({
            bool salesRefs,
            bool expensesRefs,
            bool payrollPaymentsRefs,
          })
        > {
  $$PaymentMethodsTableTableManager(
    _$AppDatabase db,
    $PaymentMethodsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentMethodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentMethodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentMethodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<PaymentKind> kind = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                code: code,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required String name,
                required PaymentKind kind,
                required int sortOrder,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentMethodsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                code: code,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PaymentMethodsTable, PaymentMethodData>(table),
                  $$PaymentMethodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                salesRefs = false,
                expensesRefs = false,
                payrollPaymentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (salesRefs) db.sales,
                    if (expensesRefs) db.expenses,
                    if (payrollPaymentsRefs) db.payrollPayments,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (salesRefs)
                        await $_getPrefetchedDataByColumns<
                          PaymentMethodData,
                          $PaymentMethodsTable,
                          SaleData,
                          $SalesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentMethodsTableReferences
                              ._salesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentMethodsTableReferences(
                                db,
                                table,
                                p0,
                              ).salesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'payment_method_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          PaymentMethodData,
                          $PaymentMethodsTable,
                          ExpenseData,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentMethodsTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentMethodsTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'payment_method_id',
                          typedResults: items,
                        ),
                      if (payrollPaymentsRefs)
                        await $_getPrefetchedDataByColumns<
                          PaymentMethodData,
                          $PaymentMethodsTable,
                          PayrollPaymentData,
                          $PayrollPaymentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PaymentMethodsTableReferences
                              ._payrollPaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PaymentMethodsTableReferences(
                                db,
                                table,
                                p0,
                              ).payrollPaymentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'payment_method_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PaymentMethodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentMethodsTable,
      PaymentMethodData,
      $$PaymentMethodsTableFilterComposer,
      $$PaymentMethodsTableOrderingComposer,
      $$PaymentMethodsTableAnnotationComposer,
      $$PaymentMethodsTableCreateCompanionBuilder,
      $$PaymentMethodsTableUpdateCompanionBuilder,
      (PaymentMethodData, $$PaymentMethodsTableReferences),
      PaymentMethodData,
      PrefetchHooks Function({
        bool salesRefs,
        bool expensesRefs,
        bool payrollPaymentsRefs,
      })
    >;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String dayId,
  required Shift shift,
  required String paymentMethodId,
  required int amountCents,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> dayId,
  Value<Shift> shift,
  Value<String> paymentMethodId,
  Value<int> amountCents,
  Value<int> rowid,
});

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, SaleData> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DaysTable _dayIdTable(_$AppDatabase db) =>
      db.days.createAlias('venta__day_id__dia_caja__id');

  $$DaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<String>('day_id')!;

    final manager = $$DaysTableTableManager(
      $_db,
      $_db.days,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentMethodsTable _paymentMethodIdTable(_$AppDatabase db) =>
      db.paymentMethods.createAlias('venta__payment_method_id__forma_pago__id');

  $$PaymentMethodsTableProcessedTableManager get paymentMethodId {
    final $_column = $_itemColumn<String>('payment_method_id')!;

    final manager = $$PaymentMethodsTableTableManager(
      $_db,
      $_db.paymentMethods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Shift, Shift, String> get shift =>
      $composableBuilder(
        column: $table.shift,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  $$DaysTableFilterComposer get dayId {
    final $$DaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableFilterComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableFilterComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  $$DaysTableOrderingComposer get dayId {
    final $$DaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableOrderingComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableOrderingComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Shift, String> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  $$DaysTableAnnotationComposer get dayId {
    final $$DaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableAnnotationComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SalesTable,
          SaleData,
          $$SalesTableFilterComposer,
          $$SalesTableOrderingComposer,
          $$SalesTableAnnotationComposer,
          $$SalesTableCreateCompanionBuilder,
          $$SalesTableUpdateCompanionBuilder,
          (SaleData, $$SalesTableReferences),
          SaleData,
          PrefetchHooks Function({bool dayId, bool paymentMethodId})
        > {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<Shift> shift = const Value.absent(),
                Value<String> paymentMethodId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                dayId: dayId,
                shift: shift,
                paymentMethodId: paymentMethodId,
                amountCents: amountCents,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String dayId,
                required Shift shift,
                required String paymentMethodId,
                required int amountCents,
                Value<int> rowid = const Value.absent(),
              }) => SalesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                dayId: dayId,
                shift: shift,
                paymentMethodId: paymentMethodId,
                amountCents: amountCents,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SalesTable, SaleData>(table),
                  $$SalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false, paymentMethodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dayId,
                        referencedTable: $$SalesTableReferences._dayIdTable(db),
                        referencedColumn: $$SalesTableReferences
                            ._dayIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (paymentMethodId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.paymentMethodId,
                        referencedTable: $$SalesTableReferences
                            ._paymentMethodIdTable(db),
                        referencedColumn: $$SalesTableReferences
                            ._paymentMethodIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SalesTable,
      SaleData,
      $$SalesTableFilterComposer,
      $$SalesTableOrderingComposer,
      $$SalesTableAnnotationComposer,
      $$SalesTableCreateCompanionBuilder,
      $$SalesTableUpdateCompanionBuilder,
      (SaleData, $$SalesTableReferences),
      SaleData,
      PrefetchHooks Function({bool dayId, bool paymentMethodId})
    >;
typedef $$CoversTableCreateCompanionBuilder = CoversCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String dayId,
  required Shift shift,
  required int count,
  Value<int> rowid,
});
typedef $$CoversTableUpdateCompanionBuilder = CoversCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> dayId,
  Value<Shift> shift,
  Value<int> count,
  Value<int> rowid,
});

final class $$CoversTableReferences
    extends BaseReferences<_$AppDatabase, $CoversTable, CoverData> {
  $$CoversTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DaysTable _dayIdTable(_$AppDatabase db) =>
      db.days.createAlias('comensales__day_id__dia_caja__id');

  $$DaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<String>('day_id')!;

    final manager = $$DaysTableTableManager(
      $_db,
      $_db.days,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CoversTableFilterComposer
    extends Composer<_$AppDatabase, $CoversTable> {
  $$CoversTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Shift, Shift, String> get shift =>
      $composableBuilder(
        column: $table.shift,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnFilters(column),
  );

  $$DaysTableFilterComposer get dayId {
    final $$DaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableFilterComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoversTableOrderingComposer
    extends Composer<_$AppDatabase, $CoversTable> {
  $$CoversTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shift => $composableBuilder(
    column: $table.shift,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get count => $composableBuilder(
    column: $table.count,
    builder: (column) => ColumnOrderings(column),
  );

  $$DaysTableOrderingComposer get dayId {
    final $$DaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableOrderingComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoversTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoversTable> {
  $$CoversTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Shift, String> get shift =>
      $composableBuilder(column: $table.shift, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  $$DaysTableAnnotationComposer get dayId {
    final $$DaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableAnnotationComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoversTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoversTable,
          CoverData,
          $$CoversTableFilterComposer,
          $$CoversTableOrderingComposer,
          $$CoversTableAnnotationComposer,
          $$CoversTableCreateCompanionBuilder,
          $$CoversTableUpdateCompanionBuilder,
          (CoverData, $$CoversTableReferences),
          CoverData,
          PrefetchHooks Function({bool dayId})
        > {
  $$CoversTableTableManager(_$AppDatabase db, $CoversTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoversTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoversTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoversTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<Shift> shift = const Value.absent(),
                Value<int> count = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoversCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                dayId: dayId,
                shift: shift,
                count: count,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String dayId,
                required Shift shift,
                required int count,
                Value<int> rowid = const Value.absent(),
              }) => CoversCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                dayId: dayId,
                shift: shift,
                count: count,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoversTable, CoverData>(table),
                  $$CoversTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dayId,
                        referencedTable: $$CoversTableReferences._dayIdTable(
                          db,
                        ),
                        referencedColumn: $$CoversTableReferences
                            ._dayIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CoversTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoversTable,
      CoverData,
      $$CoversTableFilterComposer,
      $$CoversTableOrderingComposer,
      $$CoversTableAnnotationComposer,
      $$CoversTableCreateCompanionBuilder,
      $$CoversTableUpdateCompanionBuilder,
      (CoverData, $$CoversTableReferences),
      CoverData,
      PrefetchHooks Function({bool dayId})
    >;
typedef $$ExpenseCategoriesTableCreateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String> author,
      Value<String?> code,
      required String name,
      required CategoryKind kind,
      required int sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$ExpenseCategoriesTableUpdateCompanionBuilder =
    ExpenseCategoriesCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> author,
      Value<String?> code,
      Value<String> name,
      Value<CategoryKind> kind,
      Value<int> sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$ExpenseCategoriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategoryData
        > {
  $$ExpenseCategoriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SuppliersTable, List<SupplierData>>
  _suppliersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.suppliers,
    aliasName: 'categoria_gasto__id__proveedor__category_id',
  );

  $$SuppliersTableProcessedTableManager get suppliersRefs {
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_suppliersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FixedCostsTable, List<FixedCostData>>
  _fixedCostsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fixedCosts,
    aliasName: 'categoria_gasto__id__gasto_fijo__category_id',
  );

  $$FixedCostsTableProcessedTableManager get fixedCostsRefs {
    final manager = $$FixedCostsTableTableManager(
      $_db,
      $_db.fixedCosts,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_fixedCostsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseData>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'categoria_gasto__id__gasto__category_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpenseCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CategoryKind, CategoryKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> suppliersRefs(
    Expression<bool> Function($$SuppliersTableFilterComposer f) f,
  ) {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fixedCostsRefs(
    Expression<bool> Function($$FixedCostsTableFilterComposer f) f,
  ) {
    final $$FixedCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableFilterComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpenseCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseCategoriesTable> {
  $$ExpenseCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CategoryKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> suppliersRefs<T extends Object>(
    Expression<T> Function($$SuppliersTableAnnotationComposer a) f,
  ) {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fixedCostsRefs<T extends Object>(
    Expression<T> Function($$FixedCostsTableAnnotationComposer a) f,
  ) {
    final $$FixedCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpenseCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpenseCategoriesTable,
          ExpenseCategoryData,
          $$ExpenseCategoriesTableFilterComposer,
          $$ExpenseCategoriesTableOrderingComposer,
          $$ExpenseCategoriesTableAnnotationComposer,
          $$ExpenseCategoriesTableCreateCompanionBuilder,
          $$ExpenseCategoriesTableUpdateCompanionBuilder,
          (ExpenseCategoryData, $$ExpenseCategoriesTableReferences),
          ExpenseCategoryData,
          PrefetchHooks Function({
            bool suppliersRefs,
            bool fixedCostsRefs,
            bool expensesRefs,
          })
        > {
  $$ExpenseCategoriesTableTableManager(
    _$AppDatabase db,
    $ExpenseCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<CategoryKind> kind = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                code: code,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required String name,
                required CategoryKind kind,
                required int sortOrder,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpenseCategoriesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                code: code,
                name: name,
                kind: kind,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpenseCategoriesTable, ExpenseCategoryData>(
                    table,
                  ),
                  $$ExpenseCategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                suppliersRefs = false,
                fixedCostsRefs = false,
                expensesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (suppliersRefs) db.suppliers,
                    if (fixedCostsRefs) db.fixedCosts,
                    if (expensesRefs) db.expenses,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (suppliersRefs)
                        await $_getPrefetchedDataByColumns<
                          ExpenseCategoryData,
                          $ExpenseCategoriesTable,
                          SupplierData,
                          $SuppliersTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExpenseCategoriesTableReferences
                              ._suppliersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpenseCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).suppliersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (fixedCostsRefs)
                        await $_getPrefetchedDataByColumns<
                          ExpenseCategoryData,
                          $ExpenseCategoriesTable,
                          FixedCostData,
                          $FixedCostsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExpenseCategoriesTableReferences
                              ._fixedCostsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpenseCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).fixedCostsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (expensesRefs)
                        await $_getPrefetchedDataByColumns<
                          ExpenseCategoryData,
                          $ExpenseCategoriesTable,
                          ExpenseData,
                          $ExpensesTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExpenseCategoriesTableReferences
                              ._expensesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpenseCategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).expensesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExpenseCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpenseCategoriesTable,
      ExpenseCategoryData,
      $$ExpenseCategoriesTableFilterComposer,
      $$ExpenseCategoriesTableOrderingComposer,
      $$ExpenseCategoriesTableAnnotationComposer,
      $$ExpenseCategoriesTableCreateCompanionBuilder,
      $$ExpenseCategoriesTableUpdateCompanionBuilder,
      (ExpenseCategoryData, $$ExpenseCategoriesTableReferences),
      ExpenseCategoryData,
      PrefetchHooks Function({
        bool suppliersRefs,
        bool fixedCostsRefs,
        bool expensesRefs,
      })
    >;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String name,
  Value<String?> taxId,
  Value<String?> phone,
  Value<String?> categoryId,
  Value<int> rowid,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> name,
  Value<String?> taxId,
  Value<String?> phone,
  Value<String?> categoryId,
  Value<int> rowid,
});

final class $$SuppliersTableReferences
    extends BaseReferences<_$AppDatabase, $SuppliersTable, SupplierData> {
  $$SuppliersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExpenseCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('proveedor__category_id__categoria_gasto__id');

  $$ExpenseCategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseData>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'proveedor__id__gasto__supplier_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.supplierId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpenseCategoriesTableFilterComposer get categoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taxId => $composableBuilder(
    column: $table.taxId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpenseCategoriesTableOrderingComposer get categoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get taxId =>
      $composableBuilder(column: $table.taxId, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  $$ExpenseCategoriesTableAnnotationComposer get categoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.supplierId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SuppliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTable,
          SupplierData,
          $$SuppliersTableFilterComposer,
          $$SuppliersTableOrderingComposer,
          $$SuppliersTableAnnotationComposer,
          $$SuppliersTableCreateCompanionBuilder,
          $$SuppliersTableUpdateCompanionBuilder,
          (SupplierData, $$SuppliersTableReferences),
          SupplierData,
          PrefetchHooks Function({bool categoryId, bool expensesRefs})
        > {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> taxId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                name: name,
                taxId: taxId,
                phone: phone,
                categoryId: categoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String name,
                Value<String?> taxId = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                name: name,
                taxId: taxId,
                phone: phone,
                categoryId: categoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SuppliersTable, SupplierData>(table),
                  $$SuppliersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$SuppliersTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$SuppliersTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedDataByColumns<
                      SupplierData,
                      $SuppliersTable,
                      ExpenseData,
                      $ExpensesTable
                    >(
                      currentTable: table,
                      referencedTable: $$SuppliersTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$SuppliersTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'supplier_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SuppliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTable,
      SupplierData,
      $$SuppliersTableFilterComposer,
      $$SuppliersTableOrderingComposer,
      $$SuppliersTableAnnotationComposer,
      $$SuppliersTableCreateCompanionBuilder,
      $$SuppliersTableUpdateCompanionBuilder,
      (SupplierData, $$SuppliersTableReferences),
      SupplierData,
      PrefetchHooks Function({bool categoryId, bool expensesRefs})
    >;
typedef $$FixedCostsTableCreateCompanionBuilder = FixedCostsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String concept,
  required String categoryId,
  required int plannedAmountCents,
  Value<int> vatPct,
  required Periodicity periodicity,
  required int chargeDay,
  required String startMonth,
  Value<bool> active,
  Value<int> rowid,
});
typedef $$FixedCostsTableUpdateCompanionBuilder = FixedCostsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> concept,
  Value<String> categoryId,
  Value<int> plannedAmountCents,
  Value<int> vatPct,
  Value<Periodicity> periodicity,
  Value<int> chargeDay,
  Value<String> startMonth,
  Value<bool> active,
  Value<int> rowid,
});

final class $$FixedCostsTableReferences
    extends BaseReferences<_$AppDatabase, $FixedCostsTable, FixedCostData> {
  $$FixedCostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExpenseCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('gasto_fijo__category_id__categoria_gasto__id');

  $$ExpenseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseData>>
  _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.expenses,
    aliasName: 'gasto_fijo__id__gasto__fixed_cost_id',
  );

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.fixedCostId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FixedCostsTableFilterComposer
    extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedAmountCents => $composableBuilder(
    column: $table.plannedAmountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vatPct => $composableBuilder(
    column: $table.vatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Periodicity, Periodicity, String>
  get periodicity => $composableBuilder(
    column: $table.periodicity,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get chargeDay => $composableBuilder(
    column: $table.chargeDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpenseCategoriesTableFilterComposer get categoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> expensesRefs(
    Expression<bool> Function($$ExpensesTableFilterComposer f) f,
  ) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.fixedCostId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixedCostsTableOrderingComposer
    extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get concept => $composableBuilder(
    column: $table.concept,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedAmountCents => $composableBuilder(
    column: $table.plannedAmountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vatPct => $composableBuilder(
    column: $table.vatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodicity => $composableBuilder(
    column: $table.periodicity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chargeDay => $composableBuilder(
    column: $table.chargeDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpenseCategoriesTableOrderingComposer get categoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FixedCostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FixedCostsTable> {
  $$FixedCostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get concept =>
      $composableBuilder(column: $table.concept, builder: (column) => column);

  GeneratedColumn<int> get plannedAmountCents => $composableBuilder(
    column: $table.plannedAmountCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vatPct =>
      $composableBuilder(column: $table.vatPct, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Periodicity, String> get periodicity =>
      $composableBuilder(
        column: $table.periodicity,
        builder: (column) => column,
      );

  GeneratedColumn<int> get chargeDay =>
      $composableBuilder(column: $table.chargeDay, builder: (column) => column);

  GeneratedColumn<String> get startMonth => $composableBuilder(
    column: $table.startMonth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  $$ExpenseCategoriesTableAnnotationComposer get categoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> expensesRefs<T extends Object>(
    Expression<T> Function($$ExpensesTableAnnotationComposer a) f,
  ) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.fixedCostId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FixedCostsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FixedCostsTable,
          FixedCostData,
          $$FixedCostsTableFilterComposer,
          $$FixedCostsTableOrderingComposer,
          $$FixedCostsTableAnnotationComposer,
          $$FixedCostsTableCreateCompanionBuilder,
          $$FixedCostsTableUpdateCompanionBuilder,
          (FixedCostData, $$FixedCostsTableReferences),
          FixedCostData,
          PrefetchHooks Function({bool categoryId, bool expensesRefs})
        > {
  $$FixedCostsTableTableManager(_$AppDatabase db, $FixedCostsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FixedCostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FixedCostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FixedCostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> concept = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<int> plannedAmountCents = const Value.absent(),
                Value<int> vatPct = const Value.absent(),
                Value<Periodicity> periodicity = const Value.absent(),
                Value<int> chargeDay = const Value.absent(),
                Value<String> startMonth = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixedCostsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                concept: concept,
                categoryId: categoryId,
                plannedAmountCents: plannedAmountCents,
                vatPct: vatPct,
                periodicity: periodicity,
                chargeDay: chargeDay,
                startMonth: startMonth,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String concept,
                required String categoryId,
                required int plannedAmountCents,
                Value<int> vatPct = const Value.absent(),
                required Periodicity periodicity,
                required int chargeDay,
                required String startMonth,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FixedCostsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                concept: concept,
                categoryId: categoryId,
                plannedAmountCents: plannedAmountCents,
                vatPct: vatPct,
                periodicity: periodicity,
                chargeDay: chargeDay,
                startMonth: startMonth,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FixedCostsTable, FixedCostData>(table),
                  $$FixedCostsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false, expensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (expensesRefs) db.expenses],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (categoryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.categoryId,
                        referencedTable: $$FixedCostsTableReferences
                            ._categoryIdTable(db),
                        referencedColumn: $$FixedCostsTableReferences
                            ._categoryIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedDataByColumns<
                      FixedCostData,
                      $FixedCostsTable,
                      ExpenseData,
                      $ExpensesTable
                    >(
                      currentTable: table,
                      referencedTable: $$FixedCostsTableReferences
                          ._expensesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$FixedCostsTableReferences(
                            db,
                            table,
                            p0,
                          ).expensesRefs,
                      currentColumn: 'id',
                      referencedColumn: 'fixed_cost_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$FixedCostsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FixedCostsTable,
      FixedCostData,
      $$FixedCostsTableFilterComposer,
      $$FixedCostsTableOrderingComposer,
      $$FixedCostsTableAnnotationComposer,
      $$FixedCostsTableCreateCompanionBuilder,
      $$FixedCostsTableUpdateCompanionBuilder,
      (FixedCostData, $$FixedCostsTableReferences),
      FixedCostData,
      PrefetchHooks Function({bool categoryId, bool expensesRefs})
    >;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String date,
  Value<String?> supplierId,
  required String categoryId,
  Value<String?> invoiceNumber,
  required int baseCents,
  Value<int> vatPct,
  Value<int> vatCents,
  required int totalCents,
  Value<String?> paymentMethodId,
  Value<String?> paidInCashDayId,
  required PaymentStatus paymentStatus,
  Value<String?> dueDate,
  required ExpenseOrigin origin,
  Value<String?> fixedCostId,
  Value<FixedStatus?> fixedStatus,
  Value<bool> voided,
  Value<String?> voidReason,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> date,
  Value<String?> supplierId,
  Value<String> categoryId,
  Value<String?> invoiceNumber,
  Value<int> baseCents,
  Value<int> vatPct,
  Value<int> vatCents,
  Value<int> totalCents,
  Value<String?> paymentMethodId,
  Value<String?> paidInCashDayId,
  Value<PaymentStatus> paymentStatus,
  Value<String?> dueDate,
  Value<ExpenseOrigin> origin,
  Value<String?> fixedCostId,
  Value<FixedStatus?> fixedStatus,
  Value<bool> voided,
  Value<String?> voidReason,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseData> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SuppliersTable _supplierIdTable(_$AppDatabase db) =>
      db.suppliers.createAlias('gasto__supplier_id__proveedor__id');

  $$SuppliersTableProcessedTableManager? get supplierId {
    final $_column = $_itemColumn<String>('supplier_id');
    if ($_column == null) return null;
    final manager = $$SuppliersTableTableManager(
      $_db,
      $_db.suppliers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_supplierIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExpenseCategoriesTable _categoryIdTable(_$AppDatabase db) => db
      .expenseCategories
      .createAlias('gasto__category_id__categoria_gasto__id');

  $$ExpenseCategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$ExpenseCategoriesTableTableManager(
      $_db,
      $_db.expenseCategories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentMethodsTable _paymentMethodIdTable(_$AppDatabase db) =>
      db.paymentMethods.createAlias('gasto__payment_method_id__forma_pago__id');

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    final $_column = $_itemColumn<String>('payment_method_id');
    if ($_column == null) return null;
    final manager = $$PaymentMethodsTableTableManager(
      $_db,
      $_db.paymentMethods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DaysTable _paidInCashDayIdTable(_$AppDatabase db) =>
      db.days.createAlias('gasto__paid_in_cash_day_id__dia_caja__id');

  $$DaysTableProcessedTableManager? get paidInCashDayId {
    final $_column = $_itemColumn<String>('paid_in_cash_day_id');
    if ($_column == null) return null;
    final manager = $$DaysTableTableManager(
      $_db,
      $_db.days,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paidInCashDayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FixedCostsTable _fixedCostIdTable(_$AppDatabase db) =>
      db.fixedCosts.createAlias('gasto__fixed_cost_id__gasto_fijo__id');

  $$FixedCostsTableProcessedTableManager? get fixedCostId {
    final $_column = $_itemColumn<String>('fixed_cost_id');
    if ($_column == null) return null;
    final manager = $$FixedCostsTableTableManager(
      $_db,
      $_db.fixedCosts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fixedCostIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReceiptsTable, List<ReceiptData>>
  _receiptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receipts,
    aliasName: 'gasto__id__justificante__expense_id',
  );

  $$ReceiptsTableProcessedTableManager get receiptsRefs {
    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.expenseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseCents => $composableBuilder(
    column: $table.baseCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vatPct => $composableBuilder(
    column: $table.vatPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vatCents => $composableBuilder(
    column: $table.vatCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PaymentStatus, PaymentStatus, String>
  get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ExpenseOrigin, ExpenseOrigin, String>
  get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<FixedStatus?, FixedStatus, String>
  get fixedStatus => $composableBuilder(
    column: $table.fixedStatus,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$SuppliersTableFilterComposer get supplierId {
    final $$SuppliersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableFilterComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableFilterComposer get categoryId {
    final $$ExpenseCategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableFilterComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableFilterComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DaysTableFilterComposer get paidInCashDayId {
    final $$DaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidInCashDayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableFilterComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixedCostsTableFilterComposer get fixedCostId {
    final $$FixedCostsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixedCostId,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableFilterComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> receiptsRefs(
    Expression<bool> Function($$ReceiptsTableFilterComposer f) f,
  ) {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseCents => $composableBuilder(
    column: $table.baseCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vatPct => $composableBuilder(
    column: $table.vatPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vatCents => $composableBuilder(
    column: $table.vatCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origin => $composableBuilder(
    column: $table.origin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixedStatus => $composableBuilder(
    column: $table.fixedStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$SuppliersTableOrderingComposer get supplierId {
    final $$SuppliersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableOrderingComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableOrderingComposer get categoryId {
    final $$ExpenseCategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.expenseCategories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpenseCategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.expenseCategories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableOrderingComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DaysTableOrderingComposer get paidInCashDayId {
    final $$DaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidInCashDayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableOrderingComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixedCostsTableOrderingComposer get fixedCostId {
    final $$FixedCostsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixedCostId,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableOrderingComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseCents =>
      $composableBuilder(column: $table.baseCents, builder: (column) => column);

  GeneratedColumn<int> get vatPct =>
      $composableBuilder(column: $table.vatPct, builder: (column) => column);

  GeneratedColumn<int> get vatCents =>
      $composableBuilder(column: $table.vatCents, builder: (column) => column);

  GeneratedColumn<int> get totalCents => $composableBuilder(
    column: $table.totalCents,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<PaymentStatus, String> get paymentStatus =>
      $composableBuilder(
        column: $table.paymentStatus,
        builder: (column) => column,
      );

  GeneratedColumn<String> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExpenseOrigin, String> get origin =>
      $composableBuilder(column: $table.origin, builder: (column) => column);

  GeneratedColumnWithTypeConverter<FixedStatus?, String> get fixedStatus =>
      $composableBuilder(
        column: $table.fixedStatus,
        builder: (column) => column,
      );

  GeneratedColumn<bool> get voided =>
      $composableBuilder(column: $table.voided, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$SuppliersTableAnnotationComposer get supplierId {
    final $$SuppliersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.supplierId,
      referencedTable: $db.suppliers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SuppliersTableAnnotationComposer(
            $db: $db,
            $table: $db.suppliers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExpenseCategoriesTableAnnotationComposer get categoryId {
    final $$ExpenseCategoriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.categoryId,
          referencedTable: $db.expenseCategories,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ExpenseCategoriesTableAnnotationComposer(
                $db: $db,
                $table: $db.expenseCategories,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DaysTableAnnotationComposer get paidInCashDayId {
    final $$DaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paidInCashDayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableAnnotationComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FixedCostsTableAnnotationComposer get fixedCostId {
    final $$FixedCostsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fixedCostId,
      referencedTable: $db.fixedCosts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FixedCostsTableAnnotationComposer(
            $db: $db,
            $table: $db.fixedCosts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> receiptsRefs<T extends Object>(
    Expression<T> Function($$ReceiptsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.expenseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExpensesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTable,
          ExpenseData,
          $$ExpensesTableFilterComposer,
          $$ExpensesTableOrderingComposer,
          $$ExpensesTableAnnotationComposer,
          $$ExpensesTableCreateCompanionBuilder,
          $$ExpensesTableUpdateCompanionBuilder,
          (ExpenseData, $$ExpensesTableReferences),
          ExpenseData,
          PrefetchHooks Function({
            bool supplierId,
            bool categoryId,
            bool paymentMethodId,
            bool paidInCashDayId,
            bool fixedCostId,
            bool receiptsRefs,
          })
        > {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String?> invoiceNumber = const Value.absent(),
                Value<int> baseCents = const Value.absent(),
                Value<int> vatPct = const Value.absent(),
                Value<int> vatCents = const Value.absent(),
                Value<int> totalCents = const Value.absent(),
                Value<String?> paymentMethodId = const Value.absent(),
                Value<String?> paidInCashDayId = const Value.absent(),
                Value<PaymentStatus> paymentStatus = const Value.absent(),
                Value<String?> dueDate = const Value.absent(),
                Value<ExpenseOrigin> origin = const Value.absent(),
                Value<String?> fixedCostId = const Value.absent(),
                Value<FixedStatus?> fixedStatus = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                date: date,
                supplierId: supplierId,
                categoryId: categoryId,
                invoiceNumber: invoiceNumber,
                baseCents: baseCents,
                vatPct: vatPct,
                vatCents: vatCents,
                totalCents: totalCents,
                paymentMethodId: paymentMethodId,
                paidInCashDayId: paidInCashDayId,
                paymentStatus: paymentStatus,
                dueDate: dueDate,
                origin: origin,
                fixedCostId: fixedCostId,
                fixedStatus: fixedStatus,
                voided: voided,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String date,
                Value<String?> supplierId = const Value.absent(),
                required String categoryId,
                Value<String?> invoiceNumber = const Value.absent(),
                required int baseCents,
                Value<int> vatPct = const Value.absent(),
                Value<int> vatCents = const Value.absent(),
                required int totalCents,
                Value<String?> paymentMethodId = const Value.absent(),
                Value<String?> paidInCashDayId = const Value.absent(),
                required PaymentStatus paymentStatus,
                Value<String?> dueDate = const Value.absent(),
                required ExpenseOrigin origin,
                Value<String?> fixedCostId = const Value.absent(),
                Value<FixedStatus?> fixedStatus = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                date: date,
                supplierId: supplierId,
                categoryId: categoryId,
                invoiceNumber: invoiceNumber,
                baseCents: baseCents,
                vatPct: vatPct,
                vatCents: vatCents,
                totalCents: totalCents,
                paymentMethodId: paymentMethodId,
                paidInCashDayId: paidInCashDayId,
                paymentStatus: paymentStatus,
                dueDate: dueDate,
                origin: origin,
                fixedCostId: fixedCostId,
                fixedStatus: fixedStatus,
                voided: voided,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExpensesTable, ExpenseData>(table),
                  $$ExpensesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                supplierId = false,
                categoryId = false,
                paymentMethodId = false,
                paidInCashDayId = false,
                fixedCostId = false,
                receiptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (receiptsRefs) db.receipts],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (supplierId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.supplierId,
                            referencedTable: $$ExpensesTableReferences
                                ._supplierIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._supplierIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$ExpensesTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paymentMethodId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paymentMethodId,
                            referencedTable: $$ExpensesTableReferences
                                ._paymentMethodIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._paymentMethodIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paidInCashDayId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paidInCashDayId,
                            referencedTable: $$ExpensesTableReferences
                                ._paidInCashDayIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._paidInCashDayIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (fixedCostId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.fixedCostId,
                            referencedTable: $$ExpensesTableReferences
                                ._fixedCostIdTable(db),
                            referencedColumn: $$ExpensesTableReferences
                                ._fixedCostIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptsRefs)
                        await $_getPrefetchedDataByColumns<
                          ExpenseData,
                          $ExpensesTable,
                          ReceiptData,
                          $ReceiptsTable
                        >(
                          currentTable: table,
                          referencedTable: $$ExpensesTableReferences
                              ._receiptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExpensesTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'expense_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExpensesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTable,
      ExpenseData,
      $$ExpensesTableFilterComposer,
      $$ExpensesTableOrderingComposer,
      $$ExpensesTableAnnotationComposer,
      $$ExpensesTableCreateCompanionBuilder,
      $$ExpensesTableUpdateCompanionBuilder,
      (ExpenseData, $$ExpensesTableReferences),
      ExpenseData,
      PrefetchHooks Function({
        bool supplierId,
        bool categoryId,
        bool paymentMethodId,
        bool paidInCashDayId,
        bool fixedCostId,
        bool receiptsRefs,
      })
    >;
typedef $$ReceiptsTableCreateCompanionBuilder = ReceiptsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String expenseId,
  required String relativePath,
  required ReceiptKind kind,
  required int sizeBytes,
  Value<int> rowid,
});
typedef $$ReceiptsTableUpdateCompanionBuilder = ReceiptsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> expenseId,
  Value<String> relativePath,
  Value<ReceiptKind> kind,
  Value<int> sizeBytes,
  Value<int> rowid,
});

final class $$ReceiptsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptsTable, ReceiptData> {
  $$ReceiptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExpensesTable _expenseIdTable(_$AppDatabase db) =>
      db.expenses.createAlias('justificante__expense_id__gasto__id');

  $$ExpensesTableProcessedTableManager get expenseId {
    final $_column = $_itemColumn<String>('expense_id')!;

    final manager = $$ExpensesTableTableManager(
      $_db,
      $_db.expenses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_expenseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ReceiptKind, ReceiptKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  $$ExpensesTableFilterComposer get expenseId {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableFilterComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExpensesTableOrderingComposer get expenseId {
    final $$ExpensesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableOrderingComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get relativePath => $composableBuilder(
    column: $table.relativePath,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ReceiptKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  $$ExpensesTableAnnotationComposer get expenseId {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.expenseId,
      referencedTable: $db.expenses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExpensesTableAnnotationComposer(
            $db: $db,
            $table: $db.expenses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          ReceiptData,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (ReceiptData, $$ReceiptsTableReferences),
          ReceiptData,
          PrefetchHooks Function({bool expenseId})
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String> relativePath = const Value.absent(),
                Value<ReceiptKind> kind = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                expenseId: expenseId,
                relativePath: relativePath,
                kind: kind,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String expenseId,
                required String relativePath,
                required ReceiptKind kind,
                required int sizeBytes,
                Value<int> rowid = const Value.absent(),
              }) => ReceiptsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                expenseId: expenseId,
                relativePath: relativePath,
                kind: kind,
                sizeBytes: sizeBytes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceiptsTable, ReceiptData>(table),
                  $$ReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({expenseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (expenseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.expenseId,
                        referencedTable: $$ReceiptsTableReferences
                            ._expenseIdTable(db),
                        referencedColumn: $$ReceiptsTableReferences
                            ._expenseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      ReceiptData,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (ReceiptData, $$ReceiptsTableReferences),
      ReceiptData,
      PrefetchHooks Function({bool expenseId})
    >;
typedef $$EmployeesTableCreateCompanionBuilder = EmployeesCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String name,
  Value<String?> position,
  Value<String?> hireDate,
  Value<String?> terminationDate,
  Value<int> rowid,
});
typedef $$EmployeesTableUpdateCompanionBuilder = EmployeesCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> name,
  Value<String?> position,
  Value<String?> hireDate,
  Value<String?> terminationDate,
  Value<int> rowid,
});

final class $$EmployeesTableReferences
    extends BaseReferences<_$AppDatabase, $EmployeesTable, EmployeeData> {
  $$EmployeesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PayrollPaymentsTable, List<PayrollPaymentData>>
  _payrollPaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.payrollPayments,
    aliasName: 'empleado__id__pago_nomina__employee_id',
  );

  $$PayrollPaymentsTableProcessedTableManager get payrollPaymentsRefs {
    final manager = $$PayrollPaymentsTableTableManager(
      $_db,
      $_db.payrollPayments,
    ).filter((f) => f.employeeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _payrollPaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EmployeesTableFilterComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hireDate => $composableBuilder(
    column: $table.hireDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terminationDate => $composableBuilder(
    column: $table.terminationDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> payrollPaymentsRefs(
    Expression<bool> Function($$PayrollPaymentsTableFilterComposer f) f,
  ) {
    final $$PayrollPaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollPayments,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollPaymentsTableFilterComposer(
            $db: $db,
            $table: $db.payrollPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableOrderingComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hireDate => $composableBuilder(
    column: $table.hireDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terminationDate => $composableBuilder(
    column: $table.terminationDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EmployeesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EmployeesTable> {
  $$EmployeesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get hireDate =>
      $composableBuilder(column: $table.hireDate, builder: (column) => column);

  GeneratedColumn<String> get terminationDate => $composableBuilder(
    column: $table.terminationDate,
    builder: (column) => column,
  );

  Expression<T> payrollPaymentsRefs<T extends Object>(
    Expression<T> Function($$PayrollPaymentsTableAnnotationComposer a) f,
  ) {
    final $$PayrollPaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.payrollPayments,
      getReferencedColumn: (t) => t.employeeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PayrollPaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.payrollPayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EmployeesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EmployeesTable,
          EmployeeData,
          $$EmployeesTableFilterComposer,
          $$EmployeesTableOrderingComposer,
          $$EmployeesTableAnnotationComposer,
          $$EmployeesTableCreateCompanionBuilder,
          $$EmployeesTableUpdateCompanionBuilder,
          (EmployeeData, $$EmployeesTableReferences),
          EmployeeData,
          PrefetchHooks Function({bool payrollPaymentsRefs})
        > {
  $$EmployeesTableTableManager(_$AppDatabase db, $EmployeesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EmployeesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EmployeesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EmployeesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<String?> hireDate = const Value.absent(),
                Value<String?> terminationDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                name: name,
                position: position,
                hireDate: hireDate,
                terminationDate: terminationDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String name,
                Value<String?> position = const Value.absent(),
                Value<String?> hireDate = const Value.absent(),
                Value<String?> terminationDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EmployeesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                name: name,
                position: position,
                hireDate: hireDate,
                terminationDate: terminationDate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EmployeesTable, EmployeeData>(table),
                  $$EmployeesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({payrollPaymentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (payrollPaymentsRefs) db.payrollPayments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (payrollPaymentsRefs)
                    await $_getPrefetchedDataByColumns<
                      EmployeeData,
                      $EmployeesTable,
                      PayrollPaymentData,
                      $PayrollPaymentsTable
                    >(
                      currentTable: table,
                      referencedTable: $$EmployeesTableReferences
                          ._payrollPaymentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EmployeesTableReferences(
                            db,
                            table,
                            p0,
                          ).payrollPaymentsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'employee_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EmployeesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EmployeesTable,
      EmployeeData,
      $$EmployeesTableFilterComposer,
      $$EmployeesTableOrderingComposer,
      $$EmployeesTableAnnotationComposer,
      $$EmployeesTableCreateCompanionBuilder,
      $$EmployeesTableUpdateCompanionBuilder,
      (EmployeeData, $$EmployeesTableReferences),
      EmployeeData,
      PrefetchHooks Function({bool payrollPaymentsRefs})
    >;
typedef $$PayrollPaymentsTableCreateCompanionBuilder =
    PayrollPaymentsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String> author,
      required String employeeId,
      required String month,
      required int grossCents,
      required int netCents,
      required int employerSsCents,
      Value<String?> paymentMethodId,
      Value<bool> voided,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$PayrollPaymentsTableUpdateCompanionBuilder =
    PayrollPaymentsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> author,
      Value<String> employeeId,
      Value<String> month,
      Value<int> grossCents,
      Value<int> netCents,
      Value<int> employerSsCents,
      Value<String?> paymentMethodId,
      Value<bool> voided,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$PayrollPaymentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PayrollPaymentsTable,
          PayrollPaymentData
        > {
  $$PayrollPaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EmployeesTable _employeeIdTable(_$AppDatabase db) =>
      db.employees.createAlias('pago_nomina__employee_id__empleado__id');

  $$EmployeesTableProcessedTableManager get employeeId {
    final $_column = $_itemColumn<String>('employee_id')!;

    final manager = $$EmployeesTableTableManager(
      $_db,
      $_db.employees,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_employeeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PaymentMethodsTable _paymentMethodIdTable(_$AppDatabase db) => db
      .paymentMethods
      .createAlias('pago_nomina__payment_method_id__forma_pago__id');

  $$PaymentMethodsTableProcessedTableManager? get paymentMethodId {
    final $_column = $_itemColumn<String>('payment_method_id');
    if ($_column == null) return null;
    final manager = $$PaymentMethodsTableTableManager(
      $_db,
      $_db.paymentMethods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_paymentMethodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PayrollPaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $PayrollPaymentsTable> {
  $$PayrollPaymentsTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get employerSsCents => $composableBuilder(
    column: $table.employerSsCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$EmployeesTableFilterComposer get employeeId {
    final $$EmployeesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableFilterComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableFilterComposer get paymentMethodId {
    final $$PaymentMethodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableFilterComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollPaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PayrollPaymentsTable> {
  $$PayrollPaymentsTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get netCents => $composableBuilder(
    column: $table.netCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get employerSsCents => $composableBuilder(
    column: $table.employerSsCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$EmployeesTableOrderingComposer get employeeId {
    final $$EmployeesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableOrderingComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableOrderingComposer get paymentMethodId {
    final $$PaymentMethodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableOrderingComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollPaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PayrollPaymentsTable> {
  $$PayrollPaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<int> get grossCents => $composableBuilder(
    column: $table.grossCents,
    builder: (column) => column,
  );

  GeneratedColumn<int> get netCents =>
      $composableBuilder(column: $table.netCents, builder: (column) => column);

  GeneratedColumn<int> get employerSsCents => $composableBuilder(
    column: $table.employerSsCents,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get voided =>
      $composableBuilder(column: $table.voided, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$EmployeesTableAnnotationComposer get employeeId {
    final $$EmployeesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.employeeId,
      referencedTable: $db.employees,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EmployeesTableAnnotationComposer(
            $db: $db,
            $table: $db.employees,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PaymentMethodsTableAnnotationComposer get paymentMethodId {
    final $$PaymentMethodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.paymentMethodId,
      referencedTable: $db.paymentMethods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentMethodsTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentMethods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PayrollPaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PayrollPaymentsTable,
          PayrollPaymentData,
          $$PayrollPaymentsTableFilterComposer,
          $$PayrollPaymentsTableOrderingComposer,
          $$PayrollPaymentsTableAnnotationComposer,
          $$PayrollPaymentsTableCreateCompanionBuilder,
          $$PayrollPaymentsTableUpdateCompanionBuilder,
          (PayrollPaymentData, $$PayrollPaymentsTableReferences),
          PayrollPaymentData,
          PrefetchHooks Function({bool employeeId, bool paymentMethodId})
        > {
  $$PayrollPaymentsTableTableManager(
    _$AppDatabase db,
    $PayrollPaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PayrollPaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PayrollPaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PayrollPaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> employeeId = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<int> grossCents = const Value.absent(),
                Value<int> netCents = const Value.absent(),
                Value<int> employerSsCents = const Value.absent(),
                Value<String?> paymentMethodId = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayrollPaymentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                employeeId: employeeId,
                month: month,
                grossCents: grossCents,
                netCents: netCents,
                employerSsCents: employerSsCents,
                paymentMethodId: paymentMethodId,
                voided: voided,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String employeeId,
                required String month,
                required int grossCents,
                required int netCents,
                required int employerSsCents,
                Value<String?> paymentMethodId = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PayrollPaymentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                employeeId: employeeId,
                month: month,
                grossCents: grossCents,
                netCents: netCents,
                employerSsCents: employerSsCents,
                paymentMethodId: paymentMethodId,
                voided: voided,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PayrollPaymentsTable, PayrollPaymentData>(table),
                  $$PayrollPaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({employeeId = false, paymentMethodId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (employeeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.employeeId,
                            referencedTable: $$PayrollPaymentsTableReferences
                                ._employeeIdTable(db),
                            referencedColumn: $$PayrollPaymentsTableReferences
                                ._employeeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (paymentMethodId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.paymentMethodId,
                            referencedTable: $$PayrollPaymentsTableReferences
                                ._paymentMethodIdTable(db),
                            referencedColumn: $$PayrollPaymentsTableReferences
                                ._paymentMethodIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$PayrollPaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PayrollPaymentsTable,
      PayrollPaymentData,
      $$PayrollPaymentsTableFilterComposer,
      $$PayrollPaymentsTableOrderingComposer,
      $$PayrollPaymentsTableAnnotationComposer,
      $$PayrollPaymentsTableCreateCompanionBuilder,
      $$PayrollPaymentsTableUpdateCompanionBuilder,
      (PayrollPaymentData, $$PayrollPaymentsTableReferences),
      PayrollPaymentData,
      PrefetchHooks Function({bool employeeId, bool paymentMethodId})
    >;
typedef $$WithdrawalTypesTableCreateCompanionBuilder =
    WithdrawalTypesCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String> author,
      Value<String?> code,
      required String name,
      required int sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });
typedef $$WithdrawalTypesTableUpdateCompanionBuilder =
    WithdrawalTypesCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> author,
      Value<String?> code,
      Value<String> name,
      Value<int> sortOrder,
      Value<bool> active,
      Value<int> rowid,
    });

final class $$WithdrawalTypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WithdrawalTypesTable,
          WithdrawalTypeData
        > {
  $$WithdrawalTypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$WithdrawalsTable, List<WithdrawalData>>
  _withdrawalsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.withdrawals,
    aliasName: 'tipo_retirada__id__retirada__withdrawal_type_id',
  );

  $$WithdrawalsTableProcessedTableManager get withdrawalsRefs {
    final manager = $$WithdrawalsTableTableManager($_db, $_db.withdrawals)
        .filter(
          (f) => f.withdrawalTypeId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(_withdrawalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WithdrawalTypesTableFilterComposer
    extends Composer<_$AppDatabase, $WithdrawalTypesTable> {
  $$WithdrawalTypesTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> withdrawalsRefs(
    Expression<bool> Function($$WithdrawalsTableFilterComposer f) f,
  ) {
    final $$WithdrawalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.withdrawals,
      getReferencedColumn: (t) => t.withdrawalTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalsTableFilterComposer(
            $db: $db,
            $table: $db.withdrawals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WithdrawalTypesTableOrderingComposer
    extends Composer<_$AppDatabase, $WithdrawalTypesTable> {
  $$WithdrawalTypesTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WithdrawalTypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WithdrawalTypesTable> {
  $$WithdrawalTypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  Expression<T> withdrawalsRefs<T extends Object>(
    Expression<T> Function($$WithdrawalsTableAnnotationComposer a) f,
  ) {
    final $$WithdrawalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.withdrawals,
      getReferencedColumn: (t) => t.withdrawalTypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalsTableAnnotationComposer(
            $db: $db,
            $table: $db.withdrawals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WithdrawalTypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WithdrawalTypesTable,
          WithdrawalTypeData,
          $$WithdrawalTypesTableFilterComposer,
          $$WithdrawalTypesTableOrderingComposer,
          $$WithdrawalTypesTableAnnotationComposer,
          $$WithdrawalTypesTableCreateCompanionBuilder,
          $$WithdrawalTypesTableUpdateCompanionBuilder,
          (WithdrawalTypeData, $$WithdrawalTypesTableReferences),
          WithdrawalTypeData,
          PrefetchHooks Function({bool withdrawalsRefs})
        > {
  $$WithdrawalTypesTableTableManager(
    _$AppDatabase db,
    $WithdrawalTypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WithdrawalTypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WithdrawalTypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WithdrawalTypesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WithdrawalTypesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                code: code,
                name: name,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                Value<String?> code = const Value.absent(),
                required String name,
                required int sortOrder,
                Value<bool> active = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WithdrawalTypesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                code: code,
                name: name,
                sortOrder: sortOrder,
                active: active,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WithdrawalTypesTable, WithdrawalTypeData>(table),
                  $$WithdrawalTypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({withdrawalsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (withdrawalsRefs) db.withdrawals],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (withdrawalsRefs)
                    await $_getPrefetchedDataByColumns<
                      WithdrawalTypeData,
                      $WithdrawalTypesTable,
                      WithdrawalData,
                      $WithdrawalsTable
                    >(
                      currentTable: table,
                      referencedTable: $$WithdrawalTypesTableReferences
                          ._withdrawalsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WithdrawalTypesTableReferences(
                            db,
                            table,
                            p0,
                          ).withdrawalsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'withdrawal_type_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WithdrawalTypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WithdrawalTypesTable,
      WithdrawalTypeData,
      $$WithdrawalTypesTableFilterComposer,
      $$WithdrawalTypesTableOrderingComposer,
      $$WithdrawalTypesTableAnnotationComposer,
      $$WithdrawalTypesTableCreateCompanionBuilder,
      $$WithdrawalTypesTableUpdateCompanionBuilder,
      (WithdrawalTypeData, $$WithdrawalTypesTableReferences),
      WithdrawalTypeData,
      PrefetchHooks Function({bool withdrawalsRefs})
    >;
typedef $$WithdrawalsTableCreateCompanionBuilder =
    WithdrawalsCompanion Function({
      required String id,
      required String createdAt,
      required String updatedAt,
      Value<String> author,
      required String dayId,
      required int amountCents,
      required String withdrawalTypeId,
      Value<String?> note,
      Value<bool> voided,
      Value<String?> voidReason,
      Value<int> rowid,
    });
typedef $$WithdrawalsTableUpdateCompanionBuilder =
    WithdrawalsCompanion Function({
      Value<String> id,
      Value<String> createdAt,
      Value<String> updatedAt,
      Value<String> author,
      Value<String> dayId,
      Value<int> amountCents,
      Value<String> withdrawalTypeId,
      Value<String?> note,
      Value<bool> voided,
      Value<String?> voidReason,
      Value<int> rowid,
    });

final class $$WithdrawalsTableReferences
    extends BaseReferences<_$AppDatabase, $WithdrawalsTable, WithdrawalData> {
  $$WithdrawalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DaysTable _dayIdTable(_$AppDatabase db) =>
      db.days.createAlias('retirada__day_id__dia_caja__id');

  $$DaysTableProcessedTableManager get dayId {
    final $_column = $_itemColumn<String>('day_id')!;

    final manager = $$DaysTableTableManager(
      $_db,
      $_db.days,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_dayIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $WithdrawalTypesTable _withdrawalTypeIdTable(_$AppDatabase db) => db
      .withdrawalTypes
      .createAlias('retirada__withdrawal_type_id__tipo_retirada__id');

  $$WithdrawalTypesTableProcessedTableManager get withdrawalTypeId {
    final $_column = $_itemColumn<String>('withdrawal_type_id')!;

    final manager = $$WithdrawalTypesTableTableManager(
      $_db,
      $_db.withdrawalTypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_withdrawalTypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WithdrawalsTableFilterComposer
    extends Composer<_$AppDatabase, $WithdrawalsTable> {
  $$WithdrawalsTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnFilters(column),
  );

  $$DaysTableFilterComposer get dayId {
    final $$DaysTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableFilterComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WithdrawalTypesTableFilterComposer get withdrawalTypeId {
    final $$WithdrawalTypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.withdrawalTypeId,
      referencedTable: $db.withdrawalTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalTypesTableFilterComposer(
            $db: $db,
            $table: $db.withdrawalTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WithdrawalsTableOrderingComposer
    extends Composer<_$AppDatabase, $WithdrawalsTable> {
  $$WithdrawalsTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get voided => $composableBuilder(
    column: $table.voided,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => ColumnOrderings(column),
  );

  $$DaysTableOrderingComposer get dayId {
    final $$DaysTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableOrderingComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WithdrawalTypesTableOrderingComposer get withdrawalTypeId {
    final $$WithdrawalTypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.withdrawalTypeId,
      referencedTable: $db.withdrawalTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalTypesTableOrderingComposer(
            $db: $db,
            $table: $db.withdrawalTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WithdrawalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WithdrawalsTable> {
  $$WithdrawalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
    column: $table.amountCents,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get voided =>
      $composableBuilder(column: $table.voided, builder: (column) => column);

  GeneratedColumn<String> get voidReason => $composableBuilder(
    column: $table.voidReason,
    builder: (column) => column,
  );

  $$DaysTableAnnotationComposer get dayId {
    final $$DaysTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.dayId,
      referencedTable: $db.days,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DaysTableAnnotationComposer(
            $db: $db,
            $table: $db.days,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$WithdrawalTypesTableAnnotationComposer get withdrawalTypeId {
    final $$WithdrawalTypesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.withdrawalTypeId,
      referencedTable: $db.withdrawalTypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WithdrawalTypesTableAnnotationComposer(
            $db: $db,
            $table: $db.withdrawalTypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WithdrawalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WithdrawalsTable,
          WithdrawalData,
          $$WithdrawalsTableFilterComposer,
          $$WithdrawalsTableOrderingComposer,
          $$WithdrawalsTableAnnotationComposer,
          $$WithdrawalsTableCreateCompanionBuilder,
          $$WithdrawalsTableUpdateCompanionBuilder,
          (WithdrawalData, $$WithdrawalsTableReferences),
          WithdrawalData,
          PrefetchHooks Function({bool dayId, bool withdrawalTypeId})
        > {
  $$WithdrawalsTableTableManager(_$AppDatabase db, $WithdrawalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WithdrawalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WithdrawalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WithdrawalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> dayId = const Value.absent(),
                Value<int> amountCents = const Value.absent(),
                Value<String> withdrawalTypeId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WithdrawalsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                dayId: dayId,
                amountCents: amountCents,
                withdrawalTypeId: withdrawalTypeId,
                note: note,
                voided: voided,
                voidReason: voidReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String dayId,
                required int amountCents,
                required String withdrawalTypeId,
                Value<String?> note = const Value.absent(),
                Value<bool> voided = const Value.absent(),
                Value<String?> voidReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WithdrawalsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                dayId: dayId,
                amountCents: amountCents,
                withdrawalTypeId: withdrawalTypeId,
                note: note,
                voided: voided,
                voidReason: voidReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WithdrawalsTable, WithdrawalData>(table),
                  $$WithdrawalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({dayId = false, withdrawalTypeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (dayId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.dayId,
                        referencedTable: $$WithdrawalsTableReferences
                            ._dayIdTable(db),
                        referencedColumn: $$WithdrawalsTableReferences
                            ._dayIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (withdrawalTypeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.withdrawalTypeId,
                        referencedTable: $$WithdrawalsTableReferences
                            ._withdrawalTypeIdTable(db),
                        referencedColumn: $$WithdrawalsTableReferences
                            ._withdrawalTypeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WithdrawalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WithdrawalsTable,
      WithdrawalData,
      $$WithdrawalsTableFilterComposer,
      $$WithdrawalsTableOrderingComposer,
      $$WithdrawalsTableAnnotationComposer,
      $$WithdrawalsTableCreateCompanionBuilder,
      $$WithdrawalsTableUpdateCompanionBuilder,
      (WithdrawalData, $$WithdrawalsTableReferences),
      WithdrawalData,
      PrefetchHooks Function({bool dayId, bool withdrawalTypeId})
    >;
typedef $$PeriodsTableCreateCompanionBuilder = PeriodsCompanion Function({
  required String id,
  required String createdAt,
  required String updatedAt,
  Value<String> author,
  required String month,
  required PeriodStatus status,
  Value<String?> closedAt,
  Value<int> rowid,
});
typedef $$PeriodsTableUpdateCompanionBuilder = PeriodsCompanion Function({
  Value<String> id,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String> author,
  Value<String> month,
  Value<PeriodStatus> status,
  Value<String?> closedAt,
  Value<int> rowid,
});

class $$PeriodsTableFilterComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableFilterComposer({
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

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PeriodStatus, PeriodStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeriodsTableOrderingComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableOrderingComposer({
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

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeriodsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeriodsTable> {
  $$PeriodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PeriodStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$PeriodsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeriodsTable,
          PeriodData,
          $$PeriodsTableFilterComposer,
          $$PeriodsTableOrderingComposer,
          $$PeriodsTableAnnotationComposer,
          $$PeriodsTableCreateCompanionBuilder,
          $$PeriodsTableUpdateCompanionBuilder,
          (
            PeriodData,
            BaseReferences<_$AppDatabase, $PeriodsTable, PeriodData>,
          ),
          PeriodData,
          PrefetchHooks Function()
        > {
  $$PeriodsTableTableManager(_$AppDatabase db, $PeriodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeriodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeriodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeriodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String> updatedAt = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> month = const Value.absent(),
                Value<PeriodStatus> status = const Value.absent(),
                Value<String?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeriodsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                month: month,
                status: status,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String createdAt,
                required String updatedAt,
                Value<String> author = const Value.absent(),
                required String month,
                required PeriodStatus status,
                Value<String?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeriodsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                author: author,
                month: month,
                status: status,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeriodsTable, PeriodData>(table),
                  BaseReferences<_$AppDatabase, $PeriodsTable, PeriodData>(
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

typedef $$PeriodsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeriodsTable,
      PeriodData,
      $$PeriodsTableFilterComposer,
      $$PeriodsTableOrderingComposer,
      $$PeriodsTableAnnotationComposer,
      $$PeriodsTableCreateCompanionBuilder,
      $$PeriodsTableUpdateCompanionBuilder,
      (PeriodData, BaseReferences<_$AppDatabase, $PeriodsTable, PeriodData>),
      PeriodData,
      PrefetchHooks Function()
    >;
typedef $$ChangeLogTableCreateCompanionBuilder = ChangeLogCompanion Function({
  required String id,
  required String at,
  required String entity,
  required String recordId,
  required String field,
  Value<String?> oldValue,
  Value<String?> newValue,
  Value<String?> reason,
  required String author,
  Value<String?> prevHash,
  Value<int> rowid,
});
typedef $$ChangeLogTableUpdateCompanionBuilder = ChangeLogCompanion Function({
  Value<String> id,
  Value<String> at,
  Value<String> entity,
  Value<String> recordId,
  Value<String> field,
  Value<String?> oldValue,
  Value<String?> newValue,
  Value<String?> reason,
  Value<String> author,
  Value<String?> prevHash,
  Value<int> rowid,
});

class $$ChangeLogTableFilterComposer
    extends Composer<_$AppDatabase, $ChangeLogTable> {
  $$ChangeLogTableFilterComposer({
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

  ColumnFilters<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChangeLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ChangeLogTable> {
  $$ChangeLogTableOrderingComposer({
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

  ColumnOrderings<String> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldValue => $composableBuilder(
    column: $table.oldValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prevHash => $composableBuilder(
    column: $table.prevHash,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChangeLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChangeLogTable> {
  $$ChangeLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get oldValue =>
      $composableBuilder(column: $table.oldValue, builder: (column) => column);

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get prevHash =>
      $composableBuilder(column: $table.prevHash, builder: (column) => column);
}

class $$ChangeLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChangeLogTable,
          ChangeLogData,
          $$ChangeLogTableFilterComposer,
          $$ChangeLogTableOrderingComposer,
          $$ChangeLogTableAnnotationComposer,
          $$ChangeLogTableCreateCompanionBuilder,
          $$ChangeLogTableUpdateCompanionBuilder,
          (
            ChangeLogData,
            BaseReferences<_$AppDatabase, $ChangeLogTable, ChangeLogData>,
          ),
          ChangeLogData,
          PrefetchHooks Function()
        > {
  $$ChangeLogTableTableManager(_$AppDatabase db, $ChangeLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChangeLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChangeLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChangeLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> at = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String?> prevHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChangeLogCompanion(
                id: id,
                at: at,
                entity: entity,
                recordId: recordId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                reason: reason,
                author: author,
                prevHash: prevHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String at,
                required String entity,
                required String recordId,
                required String field,
                Value<String?> oldValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                required String author,
                Value<String?> prevHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChangeLogCompanion.insert(
                id: id,
                at: at,
                entity: entity,
                recordId: recordId,
                field: field,
                oldValue: oldValue,
                newValue: newValue,
                reason: reason,
                author: author,
                prevHash: prevHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChangeLogTable, ChangeLogData>(table),
                  BaseReferences<_$AppDatabase, $ChangeLogTable, ChangeLogData>(
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

typedef $$ChangeLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChangeLogTable,
      ChangeLogData,
      $$ChangeLogTableFilterComposer,
      $$ChangeLogTableOrderingComposer,
      $$ChangeLogTableAnnotationComposer,
      $$ChangeLogTableCreateCompanionBuilder,
      $$ChangeLogTableUpdateCompanionBuilder,
      (
        ChangeLogData,
        BaseReferences<_$AppDatabase, $ChangeLogTable, ChangeLogData>,
      ),
      ChangeLogData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      Value<String?> value,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String?> value,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingData,
            BaseReferences<_$AppDatabase, $SettingsTableTable, SettingData>,
          ),
          SettingData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                Value<String?> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTableTable, SettingData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsTableTable,
                    SettingData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingData>,
      ),
      SettingData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DaysTableTableManager get days => $$DaysTableTableManager(_db, _db.days);
  $$PaymentMethodsTableTableManager get paymentMethods =>
      $$PaymentMethodsTableTableManager(_db, _db.paymentMethods);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$CoversTableTableManager get covers =>
      $$CoversTableTableManager(_db, _db.covers);
  $$ExpenseCategoriesTableTableManager get expenseCategories =>
      $$ExpenseCategoriesTableTableManager(_db, _db.expenseCategories);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$FixedCostsTableTableManager get fixedCosts =>
      $$FixedCostsTableTableManager(_db, _db.fixedCosts);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$EmployeesTableTableManager get employees =>
      $$EmployeesTableTableManager(_db, _db.employees);
  $$PayrollPaymentsTableTableManager get payrollPayments =>
      $$PayrollPaymentsTableTableManager(_db, _db.payrollPayments);
  $$WithdrawalTypesTableTableManager get withdrawalTypes =>
      $$WithdrawalTypesTableTableManager(_db, _db.withdrawalTypes);
  $$WithdrawalsTableTableManager get withdrawals =>
      $$WithdrawalsTableTableManager(_db, _db.withdrawals);
  $$PeriodsTableTableManager get periods =>
      $$PeriodsTableTableManager(_db, _db.periods);
  $$ChangeLogTableTableManager get changeLog =>
      $$ChangeLogTableTableManager(_db, _db.changeLog);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
}

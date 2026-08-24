// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_models.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetOutboxEntryCollection on Isar {
  IsarCollection<OutboxEntry> get outboxEntrys => this.collection();
}

const OutboxEntrySchema = CollectionSchema(
  name: r'OutboxEntry',
  id: 147409428666453047,
  properties: {
    r'attempts': PropertySchema(
      id: 0,
      name: r'attempts',
      type: IsarType.long,
    ),
    r'entity': PropertySchema(
      id: 1,
      name: r'entity',
      type: IsarType.string,
    ),
    r'entityId': PropertySchema(
      id: 2,
      name: r'entityId',
      type: IsarType.string,
    ),
    r'lastError': PropertySchema(
      id: 3,
      name: r'lastError',
      type: IsarType.string,
    ),
    r'nextAttemptAt': PropertySchema(
      id: 4,
      name: r'nextAttemptAt',
      type: IsarType.dateTime,
    ),
    r'op': PropertySchema(
      id: 5,
      name: r'op',
      type: IsarType.byte,
      enumMap: _OutboxEntryopEnumValueMap,
    ),
    r'payloadJson': PropertySchema(
      id: 6,
      name: r'payloadJson',
      type: IsarType.string,
    ),
    r'queuedAt': PropertySchema(
      id: 7,
      name: r'queuedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _outboxEntryEstimateSize,
  serialize: _outboxEntrySerialize,
  deserialize: _outboxEntryDeserialize,
  deserializeProp: _outboxEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'entity_queuedAt': IndexSchema(
      id: -1758313893400856400,
      name: r'entity_queuedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'entity',
          type: IndexType.hash,
          caseSensitive: true,
        ),
        IndexPropertySchema(
          name: r'queuedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _outboxEntryGetId,
  getLinks: _outboxEntryGetLinks,
  attach: _outboxEntryAttach,
  version: '3.3.2',
);

int _outboxEntryEstimateSize(
  OutboxEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entity.length * 3;
  bytesCount += 3 + object.entityId.length * 3;
  {
    final value = object.lastError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.payloadJson.length * 3;
  return bytesCount;
}

void _outboxEntrySerialize(
  OutboxEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.attempts);
  writer.writeString(offsets[1], object.entity);
  writer.writeString(offsets[2], object.entityId);
  writer.writeString(offsets[3], object.lastError);
  writer.writeDateTime(offsets[4], object.nextAttemptAt);
  writer.writeByte(offsets[5], object.op.index);
  writer.writeString(offsets[6], object.payloadJson);
  writer.writeDateTime(offsets[7], object.queuedAt);
}

OutboxEntry _outboxEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = OutboxEntry();
  object.attempts = reader.readLong(offsets[0]);
  object.entity = reader.readString(offsets[1]);
  object.entityId = reader.readString(offsets[2]);
  object.id = id;
  object.lastError = reader.readStringOrNull(offsets[3]);
  object.nextAttemptAt = reader.readDateTimeOrNull(offsets[4]);
  object.op = _OutboxEntryopValueEnumMap[reader.readByteOrNull(offsets[5])] ??
      OutboxOp.insert;
  object.payloadJson = reader.readString(offsets[6]);
  object.queuedAt = reader.readDateTime(offsets[7]);
  return object;
}

P _outboxEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (_OutboxEntryopValueEnumMap[reader.readByteOrNull(offset)] ??
          OutboxOp.insert) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _OutboxEntryopEnumValueMap = {
  'insert': 0,
  'update': 1,
  'delete': 2,
};
const _OutboxEntryopValueEnumMap = {
  0: OutboxOp.insert,
  1: OutboxOp.update,
  2: OutboxOp.delete,
};

Id _outboxEntryGetId(OutboxEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _outboxEntryGetLinks(OutboxEntry object) {
  return [];
}

void _outboxEntryAttach(
    IsarCollection<dynamic> col, Id id, OutboxEntry object) {
  object.id = id;
}

extension OutboxEntryQueryWhereSort
    on QueryBuilder<OutboxEntry, OutboxEntry, QWhere> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension OutboxEntryQueryWhere
    on QueryBuilder<OutboxEntry, OutboxEntry, QWhereClause> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityEqualToAnyQueuedAt(String entity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entity_queuedAt',
        value: [entity],
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityNotEqualToAnyQueuedAt(String entity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [],
              upper: [entity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [entity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [entity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [],
              upper: [entity],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityQueuedAtEqualTo(String entity, DateTime queuedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entity_queuedAt',
        value: [entity, queuedAt],
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityEqualToQueuedAtNotEqualTo(String entity, DateTime queuedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [entity],
              upper: [entity, queuedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [entity, queuedAt],
              includeLower: false,
              upper: [entity],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [entity, queuedAt],
              includeLower: false,
              upper: [entity],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity_queuedAt',
              lower: [entity],
              upper: [entity, queuedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityEqualToQueuedAtGreaterThan(
    String entity,
    DateTime queuedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'entity_queuedAt',
        lower: [entity, queuedAt],
        includeLower: include,
        upper: [entity],
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityEqualToQueuedAtLessThan(
    String entity,
    DateTime queuedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'entity_queuedAt',
        lower: [entity],
        upper: [entity, queuedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterWhereClause>
      entityEqualToQueuedAtBetween(
    String entity,
    DateTime lowerQueuedAt,
    DateTime upperQueuedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'entity_queuedAt',
        lower: [entity, lowerQueuedAt],
        includeLower: includeLower,
        upper: [entity, upperQueuedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension OutboxEntryQueryFilter
    on QueryBuilder<OutboxEntry, OutboxEntry, QFilterCondition> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> attemptsEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'attempts',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      attemptsGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'attempts',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      attemptsLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'attempts',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> attemptsBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'attempts',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entity',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entity',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entityId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entityId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> entityIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entityId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      entityIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entityId',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastError',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      lastErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastError',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      nextAttemptAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'nextAttemptAt',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      nextAttemptAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'nextAttemptAt',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      nextAttemptAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nextAttemptAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      nextAttemptAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nextAttemptAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      nextAttemptAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nextAttemptAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      nextAttemptAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nextAttemptAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> opEqualTo(
      OutboxOp value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'op',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> opGreaterThan(
    OutboxOp value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'op',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> opLessThan(
    OutboxOp value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'op',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> opBetween(
    OutboxOp lower,
    OutboxOp upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'op',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'payloadJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'payloadJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'payloadJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'payloadJson',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      payloadJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'payloadJson',
        value: '',
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> queuedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'queuedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      queuedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'queuedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition>
      queuedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'queuedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterFilterCondition> queuedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'queuedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension OutboxEntryQueryObject
    on QueryBuilder<OutboxEntry, OutboxEntry, QFilterCondition> {}

extension OutboxEntryQueryLinks
    on QueryBuilder<OutboxEntry, OutboxEntry, QFilterCondition> {}

extension OutboxEntryQuerySortBy
    on QueryBuilder<OutboxEntry, OutboxEntry, QSortBy> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByNextAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAttemptAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy>
      sortByNextAttemptAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAttemptAt', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByOpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> sortByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.desc);
    });
  }
}

extension OutboxEntryQuerySortThenBy
    on QueryBuilder<OutboxEntry, OutboxEntry, QSortThenBy> {
  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByAttemptsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'attempts', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByEntityId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByEntityIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entityId', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByLastError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByLastErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastError', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByNextAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAttemptAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy>
      thenByNextAttemptAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nextAttemptAt', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByOpDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'op', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByPayloadJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByPayloadJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'payloadJson', Sort.desc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.asc);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QAfterSortBy> thenByQueuedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'queuedAt', Sort.desc);
    });
  }
}

extension OutboxEntryQueryWhereDistinct
    on QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> {
  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByAttempts() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'attempts');
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByEntity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByEntityId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entityId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByLastError(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastError', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByNextAttemptAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nextAttemptAt');
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByOp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'op');
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByPayloadJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'payloadJson', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<OutboxEntry, OutboxEntry, QDistinct> distinctByQueuedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'queuedAt');
    });
  }
}

extension OutboxEntryQueryProperty
    on QueryBuilder<OutboxEntry, OutboxEntry, QQueryProperty> {
  QueryBuilder<OutboxEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<OutboxEntry, int, QQueryOperations> attemptsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'attempts');
    });
  }

  QueryBuilder<OutboxEntry, String, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<OutboxEntry, String, QQueryOperations> entityIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entityId');
    });
  }

  QueryBuilder<OutboxEntry, String?, QQueryOperations> lastErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastError');
    });
  }

  QueryBuilder<OutboxEntry, DateTime?, QQueryOperations>
      nextAttemptAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nextAttemptAt');
    });
  }

  QueryBuilder<OutboxEntry, OutboxOp, QQueryOperations> opProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'op');
    });
  }

  QueryBuilder<OutboxEntry, String, QQueryOperations> payloadJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'payloadJson');
    });
  }

  QueryBuilder<OutboxEntry, DateTime, QQueryOperations> queuedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'queuedAt');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSyncCursorCollection on Isar {
  IsarCollection<SyncCursor> get syncCursors => this.collection();
}

const SyncCursorSchema = CollectionSchema(
  name: r'SyncCursor',
  id: 355982195539933157,
  properties: {
    r'entity': PropertySchema(
      id: 0,
      name: r'entity',
      type: IsarType.string,
    ),
    r'pulledThrough': PropertySchema(
      id: 1,
      name: r'pulledThrough',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _syncCursorEstimateSize,
  serialize: _syncCursorSerialize,
  deserialize: _syncCursorDeserialize,
  deserializeProp: _syncCursorDeserializeProp,
  idName: r'id',
  indexes: {
    r'entity': IndexSchema(
      id: -5285054254130720380,
      name: r'entity',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'entity',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _syncCursorGetId,
  getLinks: _syncCursorGetLinks,
  attach: _syncCursorAttach,
  version: '3.3.2',
);

int _syncCursorEstimateSize(
  SyncCursor object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entity.length * 3;
  return bytesCount;
}

void _syncCursorSerialize(
  SyncCursor object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.entity);
  writer.writeDateTime(offsets[1], object.pulledThrough);
}

SyncCursor _syncCursorDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SyncCursor();
  object.entity = reader.readString(offsets[0]);
  object.id = id;
  object.pulledThrough = reader.readDateTimeOrNull(offsets[1]);
  return object;
}

P _syncCursorDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _syncCursorGetId(SyncCursor object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _syncCursorGetLinks(SyncCursor object) {
  return [];
}

void _syncCursorAttach(IsarCollection<dynamic> col, Id id, SyncCursor object) {
  object.id = id;
}

extension SyncCursorByIndex on IsarCollection<SyncCursor> {
  Future<SyncCursor?> getByEntity(String entity) {
    return getByIndex(r'entity', [entity]);
  }

  SyncCursor? getByEntitySync(String entity) {
    return getByIndexSync(r'entity', [entity]);
  }

  Future<bool> deleteByEntity(String entity) {
    return deleteByIndex(r'entity', [entity]);
  }

  bool deleteByEntitySync(String entity) {
    return deleteByIndexSync(r'entity', [entity]);
  }

  Future<List<SyncCursor?>> getAllByEntity(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return getAllByIndex(r'entity', values);
  }

  List<SyncCursor?> getAllByEntitySync(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'entity', values);
  }

  Future<int> deleteAllByEntity(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'entity', values);
  }

  int deleteAllByEntitySync(List<String> entityValues) {
    final values = entityValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'entity', values);
  }

  Future<Id> putByEntity(SyncCursor object) {
    return putByIndex(r'entity', object);
  }

  Id putByEntitySync(SyncCursor object, {bool saveLinks = true}) {
    return putByIndexSync(r'entity', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByEntity(List<SyncCursor> objects) {
    return putAllByIndex(r'entity', objects);
  }

  List<Id> putAllByEntitySync(List<SyncCursor> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'entity', objects, saveLinks: saveLinks);
  }
}

extension SyncCursorQueryWhereSort
    on QueryBuilder<SyncCursor, SyncCursor, QWhere> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SyncCursorQueryWhere
    on QueryBuilder<SyncCursor, SyncCursor, QWhereClause> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> entityEqualTo(
      String entity) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'entity',
        value: [entity],
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterWhereClause> entityNotEqualTo(
      String entity) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [],
              upper: [entity],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [entity],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [entity],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'entity',
              lower: [],
              upper: [entity],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SyncCursorQueryFilter
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'entity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'entity',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'entity',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> entityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'entity',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      entityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'entity',
        value: '',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      pulledThroughIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'pulledThrough',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      pulledThroughIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'pulledThrough',
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      pulledThroughEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pulledThrough',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      pulledThroughGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pulledThrough',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      pulledThroughLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pulledThrough',
        value: value,
      ));
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterFilterCondition>
      pulledThroughBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pulledThrough',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SyncCursorQueryObject
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {}

extension SyncCursorQueryLinks
    on QueryBuilder<SyncCursor, SyncCursor, QFilterCondition> {}

extension SyncCursorQuerySortBy
    on QueryBuilder<SyncCursor, SyncCursor, QSortBy> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByPulledThrough() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledThrough', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> sortByPulledThroughDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledThrough', Sort.desc);
    });
  }
}

extension SyncCursorQuerySortThenBy
    on QueryBuilder<SyncCursor, SyncCursor, QSortThenBy> {
  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByEntity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByEntityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'entity', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByPulledThrough() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledThrough', Sort.asc);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QAfterSortBy> thenByPulledThroughDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pulledThrough', Sort.desc);
    });
  }
}

extension SyncCursorQueryWhereDistinct
    on QueryBuilder<SyncCursor, SyncCursor, QDistinct> {
  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByEntity(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'entity', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SyncCursor, SyncCursor, QDistinct> distinctByPulledThrough() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pulledThrough');
    });
  }
}

extension SyncCursorQueryProperty
    on QueryBuilder<SyncCursor, SyncCursor, QQueryProperty> {
  QueryBuilder<SyncCursor, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SyncCursor, String, QQueryOperations> entityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'entity');
    });
  }

  QueryBuilder<SyncCursor, DateTime?, QQueryOperations>
      pulledThroughProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pulledThrough');
    });
  }
}

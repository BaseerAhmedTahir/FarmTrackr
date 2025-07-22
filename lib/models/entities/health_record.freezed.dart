// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'health_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HealthRecord _$HealthRecordFromJson(Map<String, dynamic> json) {
  return _HealthRecord.fromJson(json);
}

/// @nodoc
mixin _$HealthRecord {
  String get id => throw _privateConstructorUsedError;
  String get goatId => throw _privateConstructorUsedError;
  HealthRecordType get recordType => throw _privateConstructorUsedError;
  DateTime get recordDate => throw _privateConstructorUsedError;
  String? get diagnosis => throw _privateConstructorUsedError;
  String? get treatment => throw _privateConstructorUsedError;
  String? get medicine => throw _privateConstructorUsedError;
  String? get dosage => throw _privateConstructorUsedError;
  DateTime? get nextDueDate => throw _privateConstructorUsedError;
  String? get vetName => throw _privateConstructorUsedError;
  String? get vetContact => throw _privateConstructorUsedError;
  HealthStatus get status => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<String> get attachments => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this HealthRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HealthRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HealthRecordCopyWith<HealthRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HealthRecordCopyWith<$Res> {
  factory $HealthRecordCopyWith(
          HealthRecord value, $Res Function(HealthRecord) then) =
      _$HealthRecordCopyWithImpl<$Res, HealthRecord>;
  @useResult
  $Res call(
      {String id,
      String goatId,
      HealthRecordType recordType,
      DateTime recordDate,
      String? diagnosis,
      String? treatment,
      String? medicine,
      String? dosage,
      DateTime? nextDueDate,
      String? vetName,
      String? vetContact,
      HealthStatus status,
      String? notes,
      List<String> attachments,
      DateTime createdAt,
      String userId});
}

/// @nodoc
class _$HealthRecordCopyWithImpl<$Res, $Val extends HealthRecord>
    implements $HealthRecordCopyWith<$Res> {
  _$HealthRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HealthRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goatId = null,
    Object? recordType = null,
    Object? recordDate = null,
    Object? diagnosis = freezed,
    Object? treatment = freezed,
    Object? medicine = freezed,
    Object? dosage = freezed,
    Object? nextDueDate = freezed,
    Object? vetName = freezed,
    Object? vetContact = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? attachments = null,
    Object? createdAt = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goatId: null == goatId
          ? _value.goatId
          : goatId // ignore: cast_nullable_to_non_nullable
              as String,
      recordType: null == recordType
          ? _value.recordType
          : recordType // ignore: cast_nullable_to_non_nullable
              as HealthRecordType,
      recordDate: null == recordDate
          ? _value.recordDate
          : recordDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      diagnosis: freezed == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String?,
      treatment: freezed == treatment
          ? _value.treatment
          : treatment // ignore: cast_nullable_to_non_nullable
              as String?,
      medicine: freezed == medicine
          ? _value.medicine
          : medicine // ignore: cast_nullable_to_non_nullable
              as String?,
      dosage: freezed == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vetName: freezed == vetName
          ? _value.vetName
          : vetName // ignore: cast_nullable_to_non_nullable
              as String?,
      vetContact: freezed == vetContact
          ? _value.vetContact
          : vetContact // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HealthStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value.attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HealthRecordImplCopyWith<$Res>
    implements $HealthRecordCopyWith<$Res> {
  factory _$$HealthRecordImplCopyWith(
          _$HealthRecordImpl value, $Res Function(_$HealthRecordImpl) then) =
      __$$HealthRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String goatId,
      HealthRecordType recordType,
      DateTime recordDate,
      String? diagnosis,
      String? treatment,
      String? medicine,
      String? dosage,
      DateTime? nextDueDate,
      String? vetName,
      String? vetContact,
      HealthStatus status,
      String? notes,
      List<String> attachments,
      DateTime createdAt,
      String userId});
}

/// @nodoc
class __$$HealthRecordImplCopyWithImpl<$Res>
    extends _$HealthRecordCopyWithImpl<$Res, _$HealthRecordImpl>
    implements _$$HealthRecordImplCopyWith<$Res> {
  __$$HealthRecordImplCopyWithImpl(
      _$HealthRecordImpl _value, $Res Function(_$HealthRecordImpl) _then)
      : super(_value, _then);

  /// Create a copy of HealthRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goatId = null,
    Object? recordType = null,
    Object? recordDate = null,
    Object? diagnosis = freezed,
    Object? treatment = freezed,
    Object? medicine = freezed,
    Object? dosage = freezed,
    Object? nextDueDate = freezed,
    Object? vetName = freezed,
    Object? vetContact = freezed,
    Object? status = null,
    Object? notes = freezed,
    Object? attachments = null,
    Object? createdAt = null,
    Object? userId = null,
  }) {
    return _then(_$HealthRecordImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goatId: null == goatId
          ? _value.goatId
          : goatId // ignore: cast_nullable_to_non_nullable
              as String,
      recordType: null == recordType
          ? _value.recordType
          : recordType // ignore: cast_nullable_to_non_nullable
              as HealthRecordType,
      recordDate: null == recordDate
          ? _value.recordDate
          : recordDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      diagnosis: freezed == diagnosis
          ? _value.diagnosis
          : diagnosis // ignore: cast_nullable_to_non_nullable
              as String?,
      treatment: freezed == treatment
          ? _value.treatment
          : treatment // ignore: cast_nullable_to_non_nullable
              as String?,
      medicine: freezed == medicine
          ? _value.medicine
          : medicine // ignore: cast_nullable_to_non_nullable
              as String?,
      dosage: freezed == dosage
          ? _value.dosage
          : dosage // ignore: cast_nullable_to_non_nullable
              as String?,
      nextDueDate: freezed == nextDueDate
          ? _value.nextDueDate
          : nextDueDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      vetName: freezed == vetName
          ? _value.vetName
          : vetName // ignore: cast_nullable_to_non_nullable
              as String?,
      vetContact: freezed == vetContact
          ? _value.vetContact
          : vetContact // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as HealthStatus,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      attachments: null == attachments
          ? _value._attachments
          : attachments // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HealthRecordImpl implements _HealthRecord {
  const _$HealthRecordImpl(
      {required this.id,
      required this.goatId,
      required this.recordType,
      required this.recordDate,
      this.diagnosis,
      this.treatment,
      this.medicine,
      this.dosage,
      this.nextDueDate,
      this.vetName,
      this.vetContact,
      this.status = HealthStatus.healthy,
      this.notes,
      final List<String> attachments = const [],
      required this.createdAt,
      required this.userId})
      : _attachments = attachments;

  factory _$HealthRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$HealthRecordImplFromJson(json);

  @override
  final String id;
  @override
  final String goatId;
  @override
  final HealthRecordType recordType;
  @override
  final DateTime recordDate;
  @override
  final String? diagnosis;
  @override
  final String? treatment;
  @override
  final String? medicine;
  @override
  final String? dosage;
  @override
  final DateTime? nextDueDate;
  @override
  final String? vetName;
  @override
  final String? vetContact;
  @override
  @JsonKey()
  final HealthStatus status;
  @override
  final String? notes;
  final List<String> _attachments;
  @override
  @JsonKey()
  List<String> get attachments {
    if (_attachments is EqualUnmodifiableListView) return _attachments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_attachments);
  }

  @override
  final DateTime createdAt;
  @override
  final String userId;

  @override
  String toString() {
    return 'HealthRecord(id: $id, goatId: $goatId, recordType: $recordType, recordDate: $recordDate, diagnosis: $diagnosis, treatment: $treatment, medicine: $medicine, dosage: $dosage, nextDueDate: $nextDueDate, vetName: $vetName, vetContact: $vetContact, status: $status, notes: $notes, attachments: $attachments, createdAt: $createdAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HealthRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goatId, goatId) || other.goatId == goatId) &&
            (identical(other.recordType, recordType) ||
                other.recordType == recordType) &&
            (identical(other.recordDate, recordDate) ||
                other.recordDate == recordDate) &&
            (identical(other.diagnosis, diagnosis) ||
                other.diagnosis == diagnosis) &&
            (identical(other.treatment, treatment) ||
                other.treatment == treatment) &&
            (identical(other.medicine, medicine) ||
                other.medicine == medicine) &&
            (identical(other.dosage, dosage) || other.dosage == dosage) &&
            (identical(other.nextDueDate, nextDueDate) ||
                other.nextDueDate == nextDueDate) &&
            (identical(other.vetName, vetName) || other.vetName == vetName) &&
            (identical(other.vetContact, vetContact) ||
                other.vetContact == vetContact) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._attachments, _attachments) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      goatId,
      recordType,
      recordDate,
      diagnosis,
      treatment,
      medicine,
      dosage,
      nextDueDate,
      vetName,
      vetContact,
      status,
      notes,
      const DeepCollectionEquality().hash(_attachments),
      createdAt,
      userId);

  /// Create a copy of HealthRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HealthRecordImplCopyWith<_$HealthRecordImpl> get copyWith =>
      __$$HealthRecordImplCopyWithImpl<_$HealthRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HealthRecordImplToJson(
      this,
    );
  }
}

abstract class _HealthRecord implements HealthRecord {
  const factory _HealthRecord(
      {required final String id,
      required final String goatId,
      required final HealthRecordType recordType,
      required final DateTime recordDate,
      final String? diagnosis,
      final String? treatment,
      final String? medicine,
      final String? dosage,
      final DateTime? nextDueDate,
      final String? vetName,
      final String? vetContact,
      final HealthStatus status,
      final String? notes,
      final List<String> attachments,
      required final DateTime createdAt,
      required final String userId}) = _$HealthRecordImpl;

  factory _HealthRecord.fromJson(Map<String, dynamic> json) =
      _$HealthRecordImpl.fromJson;

  @override
  String get id;
  @override
  String get goatId;
  @override
  HealthRecordType get recordType;
  @override
  DateTime get recordDate;
  @override
  String? get diagnosis;
  @override
  String? get treatment;
  @override
  String? get medicine;
  @override
  String? get dosage;
  @override
  DateTime? get nextDueDate;
  @override
  String? get vetName;
  @override
  String? get vetContact;
  @override
  HealthStatus get status;
  @override
  String? get notes;
  @override
  List<String> get attachments;
  @override
  DateTime get createdAt;
  @override
  String get userId;

  /// Create a copy of HealthRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HealthRecordImplCopyWith<_$HealthRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

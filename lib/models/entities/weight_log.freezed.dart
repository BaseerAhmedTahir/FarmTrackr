// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WeightLog _$WeightLogFromJson(Map<String, dynamic> json) {
  return _WeightLog.fromJson(json);
}

/// @nodoc
mixin _$WeightLog {
  String get id => throw _privateConstructorUsedError;
  String get goatId => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  DateTime get measuredAt => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this WeightLog to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightLogCopyWith<WeightLog> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightLogCopyWith<$Res> {
  factory $WeightLogCopyWith(WeightLog value, $Res Function(WeightLog) then) =
      _$WeightLogCopyWithImpl<$Res, WeightLog>;
  @useResult
  $Res call(
      {String id,
      String goatId,
      double weightKg,
      DateTime measuredAt,
      String? notes,
      DateTime createdAt,
      String userId});
}

/// @nodoc
class _$WeightLogCopyWithImpl<$Res, $Val extends WeightLog>
    implements $WeightLogCopyWith<$Res> {
  _$WeightLogCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goatId = null,
    Object? weightKg = null,
    Object? measuredAt = null,
    Object? notes = freezed,
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
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      measuredAt: null == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
abstract class _$$WeightLogImplCopyWith<$Res>
    implements $WeightLogCopyWith<$Res> {
  factory _$$WeightLogImplCopyWith(
          _$WeightLogImpl value, $Res Function(_$WeightLogImpl) then) =
      __$$WeightLogImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String goatId,
      double weightKg,
      DateTime measuredAt,
      String? notes,
      DateTime createdAt,
      String userId});
}

/// @nodoc
class __$$WeightLogImplCopyWithImpl<$Res>
    extends _$WeightLogCopyWithImpl<$Res, _$WeightLogImpl>
    implements _$$WeightLogImplCopyWith<$Res> {
  __$$WeightLogImplCopyWithImpl(
      _$WeightLogImpl _value, $Res Function(_$WeightLogImpl) _then)
      : super(_value, _then);

  /// Create a copy of WeightLog
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? goatId = null,
    Object? weightKg = null,
    Object? measuredAt = null,
    Object? notes = freezed,
    Object? createdAt = null,
    Object? userId = null,
  }) {
    return _then(_$WeightLogImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      goatId: null == goatId
          ? _value.goatId
          : goatId // ignore: cast_nullable_to_non_nullable
              as String,
      weightKg: null == weightKg
          ? _value.weightKg
          : weightKg // ignore: cast_nullable_to_non_nullable
              as double,
      measuredAt: null == measuredAt
          ? _value.measuredAt
          : measuredAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
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
class _$WeightLogImpl implements _WeightLog {
  const _$WeightLogImpl(
      {required this.id,
      required this.goatId,
      required this.weightKg,
      required this.measuredAt,
      this.notes,
      required this.createdAt,
      required this.userId});

  factory _$WeightLogImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightLogImplFromJson(json);

  @override
  final String id;
  @override
  final String goatId;
  @override
  final double weightKg;
  @override
  final DateTime measuredAt;
  @override
  final String? notes;
  @override
  final DateTime createdAt;
  @override
  final String userId;

  @override
  String toString() {
    return 'WeightLog(id: $id, goatId: $goatId, weightKg: $weightKg, measuredAt: $measuredAt, notes: $notes, createdAt: $createdAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightLogImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.goatId, goatId) || other.goatId == goatId) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.measuredAt, measuredAt) ||
                other.measuredAt == measuredAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, goatId, weightKg, measuredAt, notes, createdAt, userId);

  /// Create a copy of WeightLog
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightLogImplCopyWith<_$WeightLogImpl> get copyWith =>
      __$$WeightLogImplCopyWithImpl<_$WeightLogImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightLogImplToJson(
      this,
    );
  }
}

abstract class _WeightLog implements WeightLog {
  const factory _WeightLog(
      {required final String id,
      required final String goatId,
      required final double weightKg,
      required final DateTime measuredAt,
      final String? notes,
      required final DateTime createdAt,
      required final String userId}) = _$WeightLogImpl;

  factory _WeightLog.fromJson(Map<String, dynamic> json) =
      _$WeightLogImpl.fromJson;

  @override
  String get id;
  @override
  String get goatId;
  @override
  double get weightKg;
  @override
  DateTime get measuredAt;
  @override
  String? get notes;
  @override
  DateTime get createdAt;
  @override
  String get userId;

  /// Create a copy of WeightLog
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightLogImplCopyWith<_$WeightLogImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

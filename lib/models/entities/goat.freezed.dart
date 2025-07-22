// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'goat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Goat _$GoatFromJson(Map<String, dynamic> json) {
  return _Goat.fromJson(json);
}

/// @nodoc
mixin _$Goat {
  String get id => throw _privateConstructorUsedError;
  String get tagNumber => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get breed => throw _privateConstructorUsedError;
  String get gender => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String? get markings => throw _privateConstructorUsedError;
  String? get photoUrl => throw _privateConstructorUsedError;
  String? get qrCode => throw _privateConstructorUsedError;
  GoatStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;

  /// Serializes this Goat to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Goat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GoatCopyWith<Goat> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GoatCopyWith<$Res> {
  factory $GoatCopyWith(Goat value, $Res Function(Goat) then) =
      _$GoatCopyWithImpl<$Res, Goat>;
  @useResult
  $Res call(
      {String id,
      String tagNumber,
      String name,
      String? breed,
      String gender,
      DateTime birthDate,
      String? color,
      String? markings,
      String? photoUrl,
      String? qrCode,
      GoatStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String userId});
}

/// @nodoc
class _$GoatCopyWithImpl<$Res, $Val extends Goat>
    implements $GoatCopyWith<$Res> {
  _$GoatCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Goat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tagNumber = null,
    Object? name = null,
    Object? breed = freezed,
    Object? gender = null,
    Object? birthDate = null,
    Object? color = freezed,
    Object? markings = freezed,
    Object? photoUrl = freezed,
    Object? qrCode = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userId = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tagNumber: null == tagNumber
          ? _value.tagNumber
          : tagNumber // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      breed: freezed == breed
          ? _value.breed
          : breed // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      markings: freezed == markings
          ? _value.markings
          : markings // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCode: freezed == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GoatStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$GoatImplCopyWith<$Res> implements $GoatCopyWith<$Res> {
  factory _$$GoatImplCopyWith(
          _$GoatImpl value, $Res Function(_$GoatImpl) then) =
      __$$GoatImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String tagNumber,
      String name,
      String? breed,
      String gender,
      DateTime birthDate,
      String? color,
      String? markings,
      String? photoUrl,
      String? qrCode,
      GoatStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      String userId});
}

/// @nodoc
class __$$GoatImplCopyWithImpl<$Res>
    extends _$GoatCopyWithImpl<$Res, _$GoatImpl>
    implements _$$GoatImplCopyWith<$Res> {
  __$$GoatImplCopyWithImpl(_$GoatImpl _value, $Res Function(_$GoatImpl) _then)
      : super(_value, _then);

  /// Create a copy of Goat
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? tagNumber = null,
    Object? name = null,
    Object? breed = freezed,
    Object? gender = null,
    Object? birthDate = null,
    Object? color = freezed,
    Object? markings = freezed,
    Object? photoUrl = freezed,
    Object? qrCode = freezed,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? userId = null,
  }) {
    return _then(_$GoatImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      tagNumber: null == tagNumber
          ? _value.tagNumber
          : tagNumber // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      breed: freezed == breed
          ? _value.breed
          : breed // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String,
      birthDate: null == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      markings: freezed == markings
          ? _value.markings
          : markings // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrl: freezed == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      qrCode: freezed == qrCode
          ? _value.qrCode
          : qrCode // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as GoatStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
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
class _$GoatImpl implements _Goat {
  const _$GoatImpl(
      {required this.id,
      required this.tagNumber,
      required this.name,
      this.breed,
      required this.gender,
      required this.birthDate,
      this.color,
      this.markings,
      this.photoUrl,
      this.qrCode,
      this.status = GoatStatus.active,
      required this.createdAt,
      required this.updatedAt,
      required this.userId});

  factory _$GoatImpl.fromJson(Map<String, dynamic> json) =>
      _$$GoatImplFromJson(json);

  @override
  final String id;
  @override
  final String tagNumber;
  @override
  final String name;
  @override
  final String? breed;
  @override
  final String gender;
  @override
  final DateTime birthDate;
  @override
  final String? color;
  @override
  final String? markings;
  @override
  final String? photoUrl;
  @override
  final String? qrCode;
  @override
  @JsonKey()
  final GoatStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final String userId;

  @override
  String toString() {
    return 'Goat(id: $id, tagNumber: $tagNumber, name: $name, breed: $breed, gender: $gender, birthDate: $birthDate, color: $color, markings: $markings, photoUrl: $photoUrl, qrCode: $qrCode, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GoatImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.tagNumber, tagNumber) ||
                other.tagNumber == tagNumber) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.breed, breed) || other.breed == breed) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.markings, markings) ||
                other.markings == markings) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.qrCode, qrCode) || other.qrCode == qrCode) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.userId, userId) || other.userId == userId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      tagNumber,
      name,
      breed,
      gender,
      birthDate,
      color,
      markings,
      photoUrl,
      qrCode,
      status,
      createdAt,
      updatedAt,
      userId);

  /// Create a copy of Goat
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GoatImplCopyWith<_$GoatImpl> get copyWith =>
      __$$GoatImplCopyWithImpl<_$GoatImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GoatImplToJson(
      this,
    );
  }
}

abstract class _Goat implements Goat {
  const factory _Goat(
      {required final String id,
      required final String tagNumber,
      required final String name,
      final String? breed,
      required final String gender,
      required final DateTime birthDate,
      final String? color,
      final String? markings,
      final String? photoUrl,
      final String? qrCode,
      final GoatStatus status,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      required final String userId}) = _$GoatImpl;

  factory _Goat.fromJson(Map<String, dynamic> json) = _$GoatImpl.fromJson;

  @override
  String get id;
  @override
  String get tagNumber;
  @override
  String get name;
  @override
  String? get breed;
  @override
  String get gender;
  @override
  DateTime get birthDate;
  @override
  String? get color;
  @override
  String? get markings;
  @override
  String? get photoUrl;
  @override
  String? get qrCode;
  @override
  GoatStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  String get userId;

  /// Create a copy of Goat
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GoatImplCopyWith<_$GoatImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

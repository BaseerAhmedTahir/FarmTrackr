// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goat.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GoatImpl _$$GoatImplFromJson(Map<String, dynamic> json) => _$GoatImpl(
      id: json['id'] as String,
      tagNumber: json['tagNumber'] as String,
      name: json['name'] as String,
      breed: json['breed'] as String?,
      gender: json['gender'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      color: json['color'] as String?,
      markings: json['markings'] as String?,
      photoUrl: json['photoUrl'] as String?,
      qrCode: json['qrCode'] as String?,
      status: $enumDecodeNullable(_$GoatStatusEnumMap, json['status']) ??
          GoatStatus.active,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$GoatImplToJson(_$GoatImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tagNumber': instance.tagNumber,
      'name': instance.name,
      'breed': instance.breed,
      'gender': instance.gender,
      'birthDate': instance.birthDate.toIso8601String(),
      'color': instance.color,
      'markings': instance.markings,
      'photoUrl': instance.photoUrl,
      'qrCode': instance.qrCode,
      'status': _$GoatStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'userId': instance.userId,
    };

const _$GoatStatusEnumMap = {
  GoatStatus.active: 'active',
  GoatStatus.sold: 'sold',
  GoatStatus.dead: 'dead',
};

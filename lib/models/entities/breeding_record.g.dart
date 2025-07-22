// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breeding_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BreedingRecordImpl _$$BreedingRecordImplFromJson(Map<String, dynamic> json) =>
    _$BreedingRecordImpl(
      id: json['id'] as String,
      damId: json['damId'] as String,
      sireId: json['sireId'] as String?,
      matingDate: json['matingDate'] == null
          ? null
          : DateTime.parse(json['matingDate'] as String),
      expectedBirthDate: json['expectedBirthDate'] == null
          ? null
          : DateTime.parse(json['expectedBirthDate'] as String),
      actualBirthDate: json['actualBirthDate'] == null
          ? null
          : DateTime.parse(json['actualBirthDate'] as String),
      numberOfKids: (json['numberOfKids'] as num?)?.toInt(),
      kidsDetail: json['kidsDetail'] as Map<String, dynamic>?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$BreedingRecordImplToJson(
        _$BreedingRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'damId': instance.damId,
      'sireId': instance.sireId,
      'matingDate': instance.matingDate?.toIso8601String(),
      'expectedBirthDate': instance.expectedBirthDate?.toIso8601String(),
      'actualBirthDate': instance.actualBirthDate?.toIso8601String(),
      'numberOfKids': instance.numberOfKids,
      'kidsDetail': instance.kidsDetail,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };

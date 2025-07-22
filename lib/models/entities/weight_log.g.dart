// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeightLogImpl _$$WeightLogImplFromJson(Map<String, dynamic> json) =>
    _$WeightLogImpl(
      id: json['id'] as String,
      goatId: json['goatId'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$WeightLogImplToJson(_$WeightLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goatId': instance.goatId,
      'weightKg': instance.weightKg,
      'measuredAt': instance.measuredAt.toIso8601String(),
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };

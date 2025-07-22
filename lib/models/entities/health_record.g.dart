// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HealthRecordImpl _$$HealthRecordImplFromJson(Map<String, dynamic> json) =>
    _$HealthRecordImpl(
      id: json['id'] as String,
      goatId: json['goatId'] as String,
      recordType: $enumDecode(_$HealthRecordTypeEnumMap, json['recordType']),
      recordDate: DateTime.parse(json['recordDate'] as String),
      diagnosis: json['diagnosis'] as String?,
      treatment: json['treatment'] as String?,
      medicine: json['medicine'] as String?,
      dosage: json['dosage'] as String?,
      nextDueDate: json['nextDueDate'] == null
          ? null
          : DateTime.parse(json['nextDueDate'] as String),
      vetName: json['vetName'] as String?,
      vetContact: json['vetContact'] as String?,
      status: $enumDecodeNullable(_$HealthStatusEnumMap, json['status']) ??
          HealthStatus.healthy,
      notes: json['notes'] as String?,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$HealthRecordImplToJson(_$HealthRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goatId': instance.goatId,
      'recordType': _$HealthRecordTypeEnumMap[instance.recordType]!,
      'recordDate': instance.recordDate.toIso8601String(),
      'diagnosis': instance.diagnosis,
      'treatment': instance.treatment,
      'medicine': instance.medicine,
      'dosage': instance.dosage,
      'nextDueDate': instance.nextDueDate?.toIso8601String(),
      'vetName': instance.vetName,
      'vetContact': instance.vetContact,
      'status': _$HealthStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'attachments': instance.attachments,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };

const _$HealthRecordTypeEnumMap = {
  HealthRecordType.vaccination: 'vaccination',
  HealthRecordType.illness: 'illness',
  HealthRecordType.injury: 'injury',
  HealthRecordType.deworming: 'deworming',
  HealthRecordType.other: 'other',
};

const _$HealthStatusEnumMap = {
  HealthStatus.healthy: 'healthy',
  HealthStatus.under_treatment: 'under_treatment',
  HealthStatus.recovered: 'recovered',
  HealthStatus.deceased: 'deceased',
};

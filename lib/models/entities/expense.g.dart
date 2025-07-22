// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseImpl _$$ExpenseImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseImpl(
      id: json['id'] as String,
      goatId: json['goatId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: $enumDecode(_$ExpenseTypeEnumMap, json['type']),
      notes: json['notes'] as String?,
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$ExpenseImplToJson(_$ExpenseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goatId': instance.goatId,
      'amount': instance.amount,
      'type': _$ExpenseTypeEnumMap[instance.type]!,
      'notes': instance.notes,
      'expenseDate': instance.expenseDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };

const _$ExpenseTypeEnumMap = {
  ExpenseType.feed: 'feed',
  ExpenseType.medicine: 'medicine',
  ExpenseType.transport: 'transport',
  ExpenseType.other: 'other',
};

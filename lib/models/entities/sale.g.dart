// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SaleImpl _$$SaleImplFromJson(Map<String, dynamic> json) => _$SaleImpl(
      id: json['id'] as String,
      goatId: json['goatId'] as String,
      saleDate: DateTime.parse(json['saleDate'] as String),
      salePrice: (json['salePrice'] as num).toDouble(),
      buyerName: json['buyerName'] as String?,
      buyerContact: json['buyerContact'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$SaleImplToJson(_$SaleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goatId': instance.goatId,
      'saleDate': instance.saleDate.toIso8601String(),
      'salePrice': instance.salePrice,
      'buyerName': instance.buyerName,
      'buyerContact': instance.buyerContact,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };

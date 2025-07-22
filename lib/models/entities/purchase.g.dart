// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PurchaseImpl _$$PurchaseImplFromJson(Map<String, dynamic> json) =>
    _$PurchaseImpl(
      id: json['id'] as String,
      goatId: json['goatId'] as String,
      purchaseDate: DateTime.parse(json['purchaseDate'] as String),
      purchasePrice: (json['purchasePrice'] as num).toDouble(),
      vendorName: json['vendorName'] as String?,
      vendorContact: json['vendorContact'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userId: json['userId'] as String,
    );

Map<String, dynamic> _$$PurchaseImplToJson(_$PurchaseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'goatId': instance.goatId,
      'purchaseDate': instance.purchaseDate.toIso8601String(),
      'purchasePrice': instance.purchasePrice,
      'vendorName': instance.vendorName,
      'vendorContact': instance.vendorContact,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'userId': instance.userId,
    };

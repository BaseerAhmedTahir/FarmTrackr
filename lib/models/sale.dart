import 'package:flutter/foundation.dart';

@immutable
class Sale {
  final String id;
  final String goatId;
  final String userId;
  final double salePrice;
  final String? buyerName;
  final String? buyerContact;
  final DateTime saleDate;
  final String? notes;
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.goatId,
    required this.userId,
    required this.salePrice,
    this.buyerName,
    this.buyerContact,
    required this.saleDate,
    this.notes,
    required this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      goatId: json['goat_id'] as String,
      userId: json['user_id'] as String,
      salePrice: (json['sale_price'] as num).toDouble(),
      buyerName: json['buyer_name'] as String?,
      buyerContact: json['buyer_contact'] as String?,
      saleDate: DateTime.parse(json['sale_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goat_id': goatId,
    'user_id': userId,
    'sale_price': salePrice,
    'buyer_name': buyerName,
    'buyer_contact': buyerContact,
    'sale_date': saleDate.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  Sale copyWith({
    String? id,
    String? goatId,
    String? userId,
    double? salePrice,
    String? buyerName,
    String? buyerContact,
    DateTime? saleDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      userId: userId ?? this.userId,
      salePrice: salePrice ?? this.salePrice,
      buyerName: buyerName ?? this.buyerName,
      buyerContact: buyerContact ?? this.buyerContact,
      saleDate: saleDate ?? this.saleDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

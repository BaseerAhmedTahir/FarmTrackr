import 'package:flutter/foundation.dart';

@immutable
class Sale {
  final String id;
  final String goatId;
  final double salePrice;
  final String? buyerName;
  final String paymentMode; // cash, bank, upi
  final DateTime saleDate;
  final String? notes;
  final DateTime createdAt;

  const Sale({
    required this.id,
    required this.goatId,
    required this.salePrice,
    this.buyerName,
    required this.paymentMode,
    required this.saleDate,
    this.notes,
    required this.createdAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'] as String,
      goatId: json['goat_id'] as String,
      salePrice: (json['sale_price'] as num).toDouble(),
      buyerName: json['buyer_name'] as String?,
      paymentMode: json['payment_mode'] as String,
      saleDate: DateTime.parse(json['sale_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goat_id': goatId,
    'sale_price': salePrice,
    'buyer_name': buyerName,
    'payment_mode': paymentMode,
    'sale_date': saleDate.toIso8601String(),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  Sale copyWith({
    String? id,
    String? goatId,
    double? salePrice,
    String? buyerName,
    String? paymentMode,
    DateTime? saleDate,
    String? notes,
    DateTime? createdAt,
  }) {
    return Sale(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      salePrice: salePrice ?? this.salePrice,
      buyerName: buyerName ?? this.buyerName,
      paymentMode: paymentMode ?? this.paymentMode,
      saleDate: saleDate ?? this.saleDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

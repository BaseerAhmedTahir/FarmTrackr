import 'package:flutter/foundation.dart';

@immutable
class Caretaker {
  final String id;
  final String name;
  final String? phone;
  final String? location;
  final String userId;
  final String paymentType; // 'fixed' or 'share'
  final double? profitSharePct;
  final double? monthlyFee;
  final String? notes;
  final DateTime createdAt;

  const Caretaker({
    required this.id,
    required this.name,
    this.phone,
    this.location,
    required this.userId,
    required this.paymentType,
    this.profitSharePct,
    this.monthlyFee,
    this.notes,
    required this.createdAt,
  });

  factory Caretaker.fromJson(Map<String, dynamic> json) {
    return Caretaker(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      userId: json['user_id'] as String,
      paymentType: json['payment_type'] as String,
      profitSharePct: json['profit_share_pct'] == null ? null : (json['profit_share_pct'] as num).toDouble(),
      monthlyFee: json['monthly_fee'] == null ? null : (json['monthly_fee'] as num).toDouble(),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'location': location,
    'user_id': userId,
    'payment_type': paymentType,
    'profit_share_pct': profitSharePct,
    'monthly_fee': monthlyFee,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  Caretaker copyWith({
    String? id,
    String? name,
    String? phone,
    String? location,
    String? userId,
    String? paymentType,
    double? profitSharePct,
    double? monthlyFee,
    String? notes,
    DateTime? createdAt,
  }) {
    return Caretaker(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      userId: userId ?? this.userId,
      paymentType: paymentType ?? this.paymentType,
      profitSharePct: profitSharePct ?? this.profitSharePct,
      monthlyFee: monthlyFee ?? this.monthlyFee,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

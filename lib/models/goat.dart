import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'weight_record.dart';

enum GoatStatus {
  active,
  sold,
  dead
}

enum GoatGender {
  male,
  female,
  unknown
}

class Goat {
  final String id;
  final String tagNumber;
  final double price;
  final DateTime birthDate;
  final String photoUrl;
  final String caretakerId;
  final String userId;
  final String name;
  final GoatGender gender;
  final GoatStatus status;
  final DateTime createdAt;
  final double? salePrice;
  final DateTime? saleDate;
  final String? buyerInfo;
  final double? totalExpense;
  final double? profit;
  final String breed;
  final List<WeightRecord> weightHistory;

  const Goat({
    required this.id,
    required this.tagNumber,
    required this.price,
    required this.birthDate,
    required this.photoUrl,
    required this.caretakerId,
    required this.userId,
    required this.name,
    this.gender = GoatGender.unknown,
    this.status = GoatStatus.active,
    required this.createdAt,
    this.salePrice,
    this.saleDate,
    this.buyerInfo,
    this.totalExpense,
    this.profit,
    required this.breed,
    this.weightHistory = const [],
  });

  factory Goat.fromJson(Map<String, dynamic> json) {
    return Goat(
      id: json['id'] as String,
      tagNumber: json['tag_number'] as String,
      price: (json['price'] as num).toDouble(),
      birthDate: DateTime.parse(json['birth_date'] as String),
      photoUrl: json['photo_url'] as String? ?? '',
      caretakerId: json['caretaker_id'] as String? ?? '',
      userId: json['user_id'] as String,
      name: json['name'] as String,
      gender: GoatGender.values.firstWhere(
        (e) => e.name.toLowerCase() == ((json['gender'] as String?)?.toLowerCase() ?? 'unknown'),
        orElse: () => GoatGender.unknown,
      ),
      status: GoatStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == ((json['status'] as String?)?.toLowerCase() ?? 'active'),
        orElse: () => GoatStatus.active,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      salePrice: json['sale_price'] == null ? null : (json['sale_price'] as num).toDouble(),
      saleDate: json['sale_date'] == null ? null : DateTime.parse(json['sale_date'] as String),
      buyerInfo: json['buyer_info'] as String?,
      totalExpense: json['total_expense'] == null ? null : (json['total_expense'] as num).toDouble(),
      profit: json['profit'] == null ? null : (json['profit'] as num).toDouble(),
      breed: json['breed'] as String? ?? 'Unknown',
      weightHistory: (json['weight_history'] as List?)
          ?.map((e) => WeightRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'tag_number': tagNumber,
    'price': price,
    'birth_date': birthDate.toIso8601String(),
    'photo_url': photoUrl,
    'caretaker_id': caretakerId,
    'user_id': userId,
    'name': name,
    'gender': gender.name,
    'status': status.name,
    'created_at': createdAt.toIso8601String(),
    'sale_price': salePrice,
    'sale_date': saleDate?.toIso8601String(),
    'buyer_info': buyerInfo,
    'total_expense': totalExpense,
    'profit': profit,
    'breed': breed,
    'weight_history': weightHistory.map((e) => e.toJson()).toList(),
  };
}

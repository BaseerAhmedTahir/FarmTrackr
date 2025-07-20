import 'package:flutter/foundation.dart';

@immutable
class WeightLog {
  final String id;
  final String goatId;
  final double weightKg;
  final DateTime measurementDate;
  final String? notes;
  final String userId;
  final DateTime createdAt;

  const WeightLog({
    required this.id,
    required this.goatId,
    required this.weightKg,
    required this.measurementDate,
    this.notes,
    required this.userId,
    required this.createdAt,
  });

  factory WeightLog.fromJson(Map<String, dynamic> json) {
    return WeightLog(
      id: json['id'] as String,
      goatId: json['goat_id'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      measurementDate: DateTime.parse(json['measurement_date'] as String),
      notes: json['notes'] as String?,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goat_id': goatId,
      'weight_kg': weightKg,
      'measurement_date': measurementDate.toIso8601String(),
      'notes': notes,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WeightLog copyWith({
    String? id,
    String? goatId,
    double? weightKg,
    DateTime? measurementDate,
    String? notes,
    String? userId,
    DateTime? createdAt,
  }) {
    return WeightLog(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      weightKg: weightKg ?? this.weightKg,
      measurementDate: measurementDate ?? this.measurementDate,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

import 'package:flutter/foundation.dart';

@immutable
class Weight {
  final String id;
  final String goatId;
  final double weightKg;
  final DateTime recordedAt;

  const Weight({
    required this.id,
    required this.goatId,
    required this.weightKg,
    required this.recordedAt,
  });

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      id: json['id'] as String,
      goatId: json['goat_id'] as String,
      weightKg: (json['weight_kg'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'goat_id': goatId,
    'weight_kg': weightKg,
    'recorded_at': recordedAt.toIso8601String(),
  };

  Weight copyWith({
    String? id,
    String? goatId,
    double? weightKg,
    DateTime? recordedAt,
  }) {
    return Weight(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      weightKg: weightKg ?? this.weightKg,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}

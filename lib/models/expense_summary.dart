import 'package:flutter/foundation.dart';

@immutable
class ExpenseSummary {
  final double totalAmount;
  final Map<String, double> byType;
  final DateTime startDate;
  final DateTime endDate;
  
  const ExpenseSummary({
    required this.totalAmount,
    required this.byType,
    required this.startDate,
    required this.endDate,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      totalAmount: (json['total_amount'] as num).toDouble(),
      byType: Map<String, double>.from(json['by_type'] as Map),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'total_amount': totalAmount,
    'by_type': byType,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
  };

  ExpenseSummary copyWith({
    double? totalAmount,
    Map<String, double>? byType,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ExpenseSummary(
      totalAmount: totalAmount ?? this.totalAmount,
      byType: byType ?? this.byType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

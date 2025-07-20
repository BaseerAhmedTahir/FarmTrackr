import 'package:flutter/foundation.dart';

@immutable
class FinancialSummary {
  final int activeGoats;
  final int soldGoats;
  final int deadGoats;
  final double totalInvestment;
  final double totalSales;
  final double totalProfit;

  const FinancialSummary({
    required this.activeGoats,
    required this.soldGoats,
    required this.deadGoats,
    required this.totalInvestment,
    required this.totalSales,
    required this.totalProfit,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      activeGoats: _parseIntSafely(json['active_goats']),
      soldGoats: _parseIntSafely(json['sold_goats']),
      deadGoats: _parseIntSafely(json['dead_goats']),
      totalInvestment: _parseDoubleSafely(json['total_investment']),
      totalSales: _parseDoubleSafely(json['total_sales']),
      totalProfit: _parseDoubleSafely(json['total_profit']),
    );
  }

  // Default empty summary
  factory FinancialSummary.empty() {
    return const FinancialSummary(
      activeGoats: 0,
      soldGoats: 0,
      deadGoats: 0,
      totalInvestment: 0,
      totalSales: 0,
      totalProfit: 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'active_goats': activeGoats,
    'sold_goats': soldGoats,
    'dead_goats': deadGoats,
    'total_investment': totalInvestment,
    'total_sales': totalSales,
    'total_profit': totalProfit,
  };

  int get totalGoats => activeGoats + soldGoats + deadGoats;

  static int _parseIntSafely(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  static double _parseDoubleSafely(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }
}

import 'expense_type.dart';

class Expense {
  final String id;
  final String? goatId; // null means general expense
  final String userId;
  final ExpenseType type;
  final double amount;
  final String? notes;
  final DateTime expenseDate;
  final DateTime createdAt;

  const Expense({
    required this.id,
    this.goatId,
    required this.userId,
    required this.type,
    required this.amount,
    this.notes,
    required this.expenseDate,
    required this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      goatId: json['goat_id'] as String?,
      userId: json['user_id'] as String,
      type: ExpenseType.values.firstWhere(
        (e) => e.name == (json['type'] as String),
        orElse: () => ExpenseType.other,
      ),
      amount: (json['amount'] as num).toDouble(),
      notes: json['notes'] as String?,
      expenseDate: DateTime.parse(json['expense_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  factory Expense.create({
    required String userId,
    required ExpenseType type,
    required double amount,
    String? goatId,
    String? notes,
    DateTime? expenseDate,
  }) {
    final now = DateTime.now();
    return Expense(
      id: '', // Will be set by the database
      userId: userId,
      type: type,
      amount: amount,
      goatId: goatId,
      notes: notes,
      expenseDate: expenseDate ?? now,
      createdAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'user_id': userId,
      'type': type.name,
      'amount': amount,
      'notes': notes,
      'expense_date': expenseDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };

    // Only include non-empty ID and goatId
    if (id.isNotEmpty) json['id'] = id;
    if (goatId != null && goatId!.isNotEmpty) json['goat_id'] = goatId;

    return json;
  }

  Expense copyWith({
    String? id,
    String? goatId,
    String? userId,
    ExpenseType? type,
    double? amount,
    String? notes,
    DateTime? expenseDate,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      goatId: goatId ?? this.goatId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      expenseDate: expenseDate ?? this.expenseDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

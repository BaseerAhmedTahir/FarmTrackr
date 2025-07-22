import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import 'enums.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

@freezed
class Expense with _$Expense {
  const factory Expense({
    required String id,
    String? goatId,
    required double amount,
    required ExpenseType type,
    String? notes,
    required DateTime expenseDate,
    required DateTime createdAt,
    required String userId,
  }) = _Expense;

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  factory Expense.create({
    String? goatId,
    required double amount,
    required ExpenseType type,
    String? notes,
    DateTime? expenseDate,
    required String userId,
  }) {
    final now = DateTime.now();
    return Expense(
      id: const Uuid().v4(),
      goatId: goatId,
      amount: amount,
      type: type,
      notes: notes,
      expenseDate: expenseDate ?? now,
      createdAt: now,
      userId: userId,
    );
  }
}

import 'package:goat_tracker/models/expense.dart';
import 'package:goat_tracker/models/expense_type.dart';
import 'package:goat_tracker/services/base_service.dart';

class ExpenseService extends BaseService {
  static const String _tableName = 'expenses';

  Stream<List<Expense>> watchExpenses() {
    return supabase
        .from(_tableName)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((response) => response
            .map((json) => Expense.fromJson(json))
            .toList());
  }

  Future<List<Expense>> getAllExpenses() async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      
      return (response as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    }, 'fetching all expenses');
  }

  Future<Expense> getExpenseById(String id) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();
      
      return Expense.fromJson(response);
    }, 'fetching expense by ID');
  }

  Future<List<Expense>> getGoatExpenses(String goatId) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .eq('goat_id', goatId)
          .order('expense_date', ascending: false);
      
      return (response as List)
          .map((json) => Expense.fromJson(json))
          .toList();
    }, 'fetching goat expenses');
  }

  Future<Expense> createExpense({
    required String userId,
    required ExpenseType type,
    required double amount,
    String? goatId,
    String? notes,
    DateTime? expenseDate,
  }) async {
    return handleResponse(() async {
      final expense = Expense.create(
        userId: userId,
        type: type,
        amount: amount,
        goatId: goatId,
        notes: notes,
        expenseDate: expenseDate,
      );

      final response = await supabase
          .from(_tableName)
          .insert(expense.toJson())
          .select()
          .single();
      
      // If this is a goat-specific expense, update the goat's total expense
      if (goatId != null) {
        await _updateGoatTotalExpense(goatId);
      }
      
      return Expense.fromJson(response);
    }, 'creating expense');
  }

  Future<Expense> updateExpense(Expense expense) async {
    return handleResponse(() async {
      final oldExpense = await getExpenseById(expense.id);
      
      final response = await supabase
          .from(_tableName)
          .update(expense.toJson())
          .eq('id', expense.id)
          .select()
          .single();
      
      // If the goat ID changed or amount changed, update both old and new goat's total expenses
      if (oldExpense.goatId != null) {
        await _updateGoatTotalExpense(oldExpense.goatId!);
      }
      if (expense.goatId != null && expense.goatId != oldExpense.goatId) {
        await _updateGoatTotalExpense(expense.goatId!);
      }
      
      return Expense.fromJson(response);
    }, 'updating expense');
  }

  Future<void> deleteExpense(String id) async {
    return handleResponse(() async {
      final expense = await getExpenseById(id);
      
      await supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
      
      // If this was a goat-specific expense, update the goat's total expense
      if (expense.goatId != null) {
        await _updateGoatTotalExpense(expense.goatId!);
      }
    }, 'deleting expense');
  }

  // Alias for createExpense
  Future<Expense> addExpense(Expense expense) => createExpense(
        userId: expense.userId,
        type: expense.type,
        amount: expense.amount,
        goatId: expense.goatId,
        notes: expense.notes,
        expenseDate: expense.expenseDate,
      );

  // No need to update total_expense directly as it's now calculated by the view
  Future<void> _updateGoatTotalExpense(String goatId) async {
    // The total_expense is now automatically calculated by the goat_expenses view
    return;
  }

  Future<Map<ExpenseType, double>> getExpensesByType(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return handleResponse(() async {
      final response = await supabase
          .from(_tableName)
          .select()
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());
      
      final expenses = (response as List)
          .map((json) => Expense.fromJson(json))
          .toList();
      
      return {
        for (final type in ExpenseType.values)
          type: expenses
              .where((e) => e.type == type)
              .fold(0.0, (sum, e) => sum + e.amount)
      };
    }, 'fetching expenses by type');
  }
}

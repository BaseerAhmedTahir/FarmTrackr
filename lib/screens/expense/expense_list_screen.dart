import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goat_tracker/models/expense.dart';
import 'package:goat_tracker/models/expense_type.dart';
import 'package:goat_tracker/services/expense_service.dart';
import 'package:intl/intl.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _expenseService = ExpenseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: FutureBuilder<List<Expense>>(
        future: _expenseService.getAllExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final expenses = snapshot.data ?? [];

          if (expenses.isEmpty) {
            return const Center(
              child: Text('No expenses recorded'),
            );
          }

          return ListView.builder(
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final expense = expenses[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    _getExpenseIcon(expense.type),
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    'Rs. ${expense.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(
                    '${expense.type.name.toUpperCase()}\n'
                    '${DateFormat('MMM d, y').format(expense.expenseDate)}',
                  ),
                  trailing: expense.goatId != null
                      ? const Icon(Icons.pets)
                      : null,
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'expense_list_fab',
        onPressed: () => context.go('/expenses/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getExpenseIcon(ExpenseType type) {
    switch (type) {
      case ExpenseType.feed:
        return Icons.restaurant;
      case ExpenseType.medicine:
        return Icons.medical_services;
      case ExpenseType.transport:
        return Icons.local_shipping;
      case ExpenseType.other:
        return Icons.miscellaneous_services;
    }
  }
}

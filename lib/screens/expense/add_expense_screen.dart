import 'package:flutter/material.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/expense_type.dart';
import 'package:goat_tracker/services/expense_service.dart';
import 'package:goat_tracker/services/goat_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _expenseService = ExpenseService();
  final _goatService = GoatService();

  ExpenseType _selectedType = ExpenseType.feed;
  DateTime _expenseDate = DateTime.now();
  String? _selectedGoatId;
  List<Goat> _goats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGoats();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadGoats() async {
    try {
      final goats = await _goatService.getAllGoats();
      if (!mounted) return;
      setState(() {
        _goats = goats.where((g) => g.status == GoatStatus.active).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading goats: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');

      await _expenseService.createExpense(
        userId: user.id,
        type: _selectedType,
        amount: double.parse(_amountController.text),
        goatId: _selectedGoatId,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        expenseDate: _expenseDate,
      );

      if (!mounted) return;
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense added successfully')),
      );
      
      // Navigate back if possible, otherwise go to home
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding expense: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<ExpenseType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: ExpenseType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGoatId,
                  decoration: const InputDecoration(
                    labelText: 'Goat (Optional)',
                    helperText: 'Select a goat if this expense is specific to one',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('General Expense'),
                    ),
                    ..._goats.map((goat) {
                      return DropdownMenuItem(
                        value: goat.id,
                        child: Text('${goat.name} (${goat.tagNumber})'),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedGoatId = value);
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _expenseDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => _expenseDate = date);
                    }
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(DateFormat('MMMM d, y').format(_expenseDate)),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Add any additional details',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save Expense'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

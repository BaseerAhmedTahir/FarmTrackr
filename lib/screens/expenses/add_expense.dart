import 'package:flutter/material.dart';
import 'package:goat_tracker/services/supabase_service.dart';

class AddExpenseScreen extends StatefulWidget {
  final String goatId;
  const AddExpenseScreen(this.goatId, {super.key});
  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amt = TextEditingController();
  final _note = TextEditingController();
  String _type = 'feed';
  @override
  Widget build(BuildContext ctx) => Scaffold(
        appBar: AppBar(title: const Text('New Expense')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            DropdownButtonFormField<String>(
              value: _type,
              items: const [
                DropdownMenuItem(value: 'feed', child: Text('Feed')),
                DropdownMenuItem(value: 'medicine', child: Text('Medicine')),
                DropdownMenuItem(value: 'transport', child: Text('Transport')),
              ],
              onChanged: (v) => setState(() => _type = v!),
            ),
            TextField(
              controller: _amt,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            TextField(controller: _note, decoration: const InputDecoration(labelText: 'Notes')),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                await Svc.addExpense(
                    goatId: widget.goatId,
                    amt: double.parse(_amt.text),
                    type: _type,
                    notes: _note.text);
                if (mounted) Navigator.pop(ctx);
              },
            )
          ]),
        ),
      );
}

import 'package:flutter/material.dart';
import 'package:goat_tracker/services/supabase_service.dart';

class AddCaretakerScreen extends StatefulWidget {
  const AddCaretakerScreen({super.key});
  @override
  State<AddCaretakerScreen> createState() => _AddCaretakerScreenState();
}

class _AddCaretakerScreenState extends State<AddCaretakerScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Caretaker')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _form,
          child: Column(children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(label: Text('Name')),
              validator: (v) => v!.isEmpty ? 'required' : null,
            ),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(label: Text('Phone (opt)')),
            ),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: () async {
                if (!_form.currentState!.validate()) return;
                await Svc.addCaretaker(name: _name.text, phone: _phone.text);
                if (!mounted) return;
                Navigator.pop(context);
              },
            )
          ]),
        ),
      ),
    );
  }
}
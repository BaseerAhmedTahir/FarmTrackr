import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
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
  final _location = TextEditingController();
  final _paymentTerms = TextEditingController();
  final _profitShare = TextEditingController(text: '0');
  bool _isLoading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _location.dispose();
    _paymentTerms.dispose();
    _profitShare.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await Svc.addCaretaker(
        name: _name.text,
        phone: _phone.text,
        loc: _location.text,
        payment: _paymentTerms.text,
        profitShare: double.tryParse(_profitShare.text) ?? 0,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding caretaker: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) => v!.isEmpty ? 'Name is required' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _paymentTerms,
              decoration: const InputDecoration(
                labelText: 'Payment Terms',
                prefixIcon: Icon(Icons.payment),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _profitShare,
              decoration: const InputDecoration(
                labelText: 'Profit Share (%)',
                prefixIcon: Icon(Icons.percent),
                hintText: 'Enter percentage (0-100)',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final number = double.tryParse(v);
                if (number == null) return 'Please enter a valid number';
                if (number < 0 || number > 100) return 'Please enter a value between 0 and 100';
                return null;
              },
              textInputAction: TextInputAction.done,
              onEditingComplete: _save,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
                label: const Text('Save Caretaker'),
                onPressed: _isLoading ? null : _save,
              ),
            )
          ]),
        ),
      ),
    );
  }
}
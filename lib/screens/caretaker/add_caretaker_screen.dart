import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddCaretakerScreen extends StatefulWidget {
  const AddCaretakerScreen({super.key});

  @override
  State<AddCaretakerScreen> createState() => _AddCaretakerScreenState();
}

class _AddCaretakerScreenState extends State<AddCaretakerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentType = 'fixed';  // 'fixed' or 'share'
  final _profitShareController = TextEditingController();
  final _monthlyFeeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _saveCaretaker() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not logged in');

      final data = <String, dynamic>{
        'name': _nameController.text,
        'phone': _phoneController.text,
        'location': _locationController.text,
        'notes': _notesController.text,
        'payment_type': _paymentType,
        'user_id': userId,
      };

      if (_paymentType == 'share' && _profitShareController.text.isNotEmpty) {
        data['profit_share_pct'] = double.tryParse(_profitShareController.text) ?? 0.0;
      }
      if (_paymentType == 'fixed' && _monthlyFeeController.text.isNotEmpty) {
        data['monthly_fee'] = double.tryParse(_monthlyFeeController.text) ?? 0.0;
      }

      await Supabase.instance.client.from('caretakers').insert(data);

      if (mounted) {
        context.go('/caretakers');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save caretaker: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _profitShareController.dispose();
    _monthlyFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Caretaker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _paymentType,
                decoration: const InputDecoration(
                  labelText: 'Payment Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'fixed',
                    child: Text('Fixed Monthly Fee'),
                  ),
                  DropdownMenuItem(
                    value: 'share',
                    child: Text('Profit Share'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _paymentType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_paymentType == 'fixed')
                TextFormField(
                  controller: _monthlyFeeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monthly Fee',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                    }
                    return null;
                  },
                ),
              if (_paymentType == 'share')
                TextFormField(
                  controller: _profitShareController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Profit Share %',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final number = double.tryParse(value);
                      if (number == null) {
                        return 'Please enter a valid number';
                      }
                      if (number < 0 || number > 100) {
                        return 'Please enter a number between 0 and 100';
                      }
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveCaretaker,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Caretaker'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

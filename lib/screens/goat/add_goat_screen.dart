import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddGoatScreen extends ConsumerStatefulWidget {
  const AddGoatScreen({super.key});

  @override
  ConsumerState<AddGoatScreen> createState() => _AddGoatScreenState();
}

class _AddGoatScreenState extends ConsumerState<AddGoatScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tagNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  String? _caretakerId;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _caretakers = [];

  @override
  void initState() {
    super.initState();
    _loadCaretakers();
  }

  Future<void> _loadCaretakers() async {
    try {
      final response = await Supabase.instance.client
          .from('caretakers')
          .select()
          .eq('user_id', Supabase.instance.client.auth.currentUser!.id);
      if (mounted) {
        setState(() {
          _caretakers = (response as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      debugPrint('Error loading caretakers: $e');
    }
  }

  @override
  void dispose() {
    _tagNumberController.dispose();
    _nameController.dispose();
    _breedController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null && mounted) {
      setState(() => _birthDate = date);
    }
  }

  Future<void> _saveGoat() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_birthDate == null) {
      setState(() {
        _errorMessage = 'Please select birth date';
      });
      return;
    }
    if (_gender == null) {
      setState(() {
        _errorMessage = 'Please select gender';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.from('goats').insert({
        'tag_number': _tagNumberController.text.trim(),
        'name': _nameController.text.trim(),
        'breed': _breedController.text.trim(),
        'birth_date': _birthDate!.toIso8601String().split('T')[0],
        'price': double.parse(_priceController.text.trim()),
        'gender': _gender,
        'caretaker_id': _caretakerId,
        'user_id': Supabase.instance.client.auth.currentUser!.id,
        'status': 'active',
      });

      if (mounted) {
        context.go('/goats');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to save goat: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Goat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _tagNumberController,
                decoration: const InputDecoration(
                  labelText: 'Tag Number *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a tag number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name *',
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
                controller: _breedController,
                decoration: const InputDecoration(
                  labelText: 'Breed *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a breed';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Purchase Price *',
                  border: OutlineInputBorder(),
                  prefixText: '₹ ',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the purchase price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Birth Date *',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate == null
                            ? 'Select date'
                            : '${_birthDate!.day}/${_birthDate!.month}/${_birthDate!.year}',
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(
                  labelText: 'Gender *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'male',
                    child: Text('Male'),
                  ),
                  DropdownMenuItem(
                    value: 'female',
                    child: Text('Female'),
                  ),
                ],
                onChanged: (value) => setState(() => _gender = value),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                value: _caretakerId,
                decoration: const InputDecoration(
                  labelText: 'Caretaker',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None'),
                  ),
                  ..._caretakers.map((c) => DropdownMenuItem(
                        value: c['id'].toString(),
                        child: Text(c['name']),
                      )),
                ],
                onChanged: (value) => setState(() => _caretakerId = value),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton(
                onPressed: _isLoading ? null : _saveGoat,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save Goat'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

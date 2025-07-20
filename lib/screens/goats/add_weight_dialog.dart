import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
import '../../services/supabase_service.dart';

const double _minWeight = 0.1;
const double _maxWeight = 200.0; // Maximum reasonable weight for a goat

class AddWeightDialog extends StatefulWidget {
  final String goatId;

  const AddWeightDialog({super.key, required this.goatId});

  @override
  State<AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends State<AddWeightDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _submitWeight() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final weight = double.parse(_weightController.text);
      await Svc.addWeight(widget.goatId, weight);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Weight record added: ${weight}kg'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add weight record: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Weight Record'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _weightController,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            hintText: 'Enter weight in kilograms',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a weight';
            }
            final weight = double.tryParse(value);
            if (weight == null) {
              return 'Please enter a valid number';
            }
            if (weight < _minWeight) {
              return 'Weight must be at least ${_minWeight}kg';
            }
            if (weight > _maxWeight) {
              return 'Weight cannot exceed ${_maxWeight}kg';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitWeight,
          child: _isLoading
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

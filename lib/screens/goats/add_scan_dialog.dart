import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
import 'package:goat_tracker/services/supabase_service.dart';

class AddScanDialog extends StatefulWidget {
  final String goatId;
  final String scanType;

  const AddScanDialog({
    super.key,
    required this.goatId,
    required this.scanType,
  });

  @override
  State<AddScanDialog> createState() => _AddScanDialogState();
}

class _AddScanDialogState extends State<AddScanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitScan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await Svc.addScan(
        goatId: widget.goatId,
        scanType: widget.scanType,
        location: _locationController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Record ${widget.scanType.toUpperCase()} Scan'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Where was the scan made?',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the location';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional notes',
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submitScan,
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

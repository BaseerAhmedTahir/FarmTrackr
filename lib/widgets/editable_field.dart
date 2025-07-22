import 'package:flutter/material.dart';

class EditableField extends StatelessWidget {
  final String label;
  final String value;
  final bool isEditing;
  final void Function(String)? onChanged;

  const EditableField({
    super.key,
    required this.label,
    required this.value,
    this.isEditing = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (isEditing && onChanged != null)
            TextField(
              controller: TextEditingController(text: value),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }
}

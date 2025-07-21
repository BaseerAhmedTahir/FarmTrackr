import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/health_record.dart';
import 'package:goat_tracker/providers.dart';

class RecordsSection extends StatelessWidget {
  final String title;
  final List<HealthRecord> records;

  const RecordsSection({
    super.key,
    required this.title,
    required this.records,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          if (records.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No records found'),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: records.length,
              itemBuilder: (context, index) {
                final record = records[index];
                return ListTile(
                  title: Text(record.diagnosis ?? record.recordType),
                  subtitle: Text(dateFormat.format(record.recordDate)),
                  trailing: Text(record.recordType),
                );
              },
            ),
        ],
      ),
    );
  }
}

class HealthTab extends ConsumerWidget {
  final Goat goat;
  final bool canEdit;

  const HealthTab({
    super.key,
    required this.goat,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthRecordsAsync = ref.watch(healthRecordsProvider(goat.id));

    return healthRecordsAsync.when(
      data: (healthRecords) {
        final regularRecords = healthRecords.where((r) => 
          r.recordType != 'vaccination' && r.recordType != 'deworming'
        ).toList();
        final vaccinations = healthRecords.where((r) => 
          r.recordType == 'vaccination'
        ).toList();
        final dewormings = healthRecords.where((r) => 
          r.recordType == 'deworming'
        ).toList();

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (canEdit)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddRecordDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Health Record'),
                    ),
                  ),
                RecordsSection(
                  title: 'Health Records',
                  records: regularRecords,
                ),
                RecordsSection(
                  title: 'Vaccinations',
                  records: vaccinations,
                ),
                RecordsSection(
                  title: 'Deworming Records',
                  records: dewormings,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading health records: $error'),
      ),

    );
  }

  Future<void> _showAddRecordDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    String recordType = 'general';
    String description = '';
    DateTime date = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Health Record'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: recordType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['general', 'vaccination', 'deworming']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) => recordType = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => description = value,
                validator: (value) =>
                    value?.isEmpty == true ? 'Please enter a description' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Save the record
                ref.read(healthRecordServiceProvider).addHealthRecord(
                  goatId: goat.id,
                  recordType: recordType,
                  diagnosis: description,
                  recordDate: date,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}



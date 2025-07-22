import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/breeding_record.dart';
import 'package:goat_tracker/providers.dart';

class BreedingTab extends ConsumerStatefulWidget {
  final Goat goat;
  final bool canEdit;

  const BreedingTab({
    Key? key,
    required this.goat,
    this.canEdit = true,
  }) : super(key: key);

  @override
  ConsumerState<BreedingTab> createState() => _BreedingTabState();
}

class _BreedingTabState extends ConsumerState<BreedingTab> {
  final _formKey = GlobalKey<FormState>();
  String _sireId = '';
  DateTime _matingDate = DateTime.now();
  String? _notes;

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Breeding Record'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sire ID'),
                onChanged: (value) => setState(() => _sireId = value),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter sire ID' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                onChanged: (value) => setState(() => _notes = value),
                maxLines: 3,
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
              if (_formKey.currentState!.validate()) {
                ref.read(breedingRecordServiceProvider).addBreedingRecord(
                      damId: widget.goat.id,
                      sireId: _sireId,
                      matingDate: _matingDate,
                      notes: _notes,
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

  void _showEditRecordDialog(BreedingRecord record) {
    _sireId = record.sireId;
    _matingDate = record.matingDate ?? DateTime.now();
    _notes = record.notes;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Breeding Record'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Sire ID'),
                initialValue: _sireId,
                onChanged: (value) => setState(() => _sireId = value),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter sire ID' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Notes'),
                initialValue: _notes,
                onChanged: (value) => setState(() => _notes = value),
                maxLines: 3,
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
              if (_formKey.currentState!.validate()) {
                // TODO: Update breeding record logic here
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildParentInfo(String goatId, String label) {
    final parent = ref.watch(goatProvider(goatId));
    return parent.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error loading $label: $error'),
      data: (goat) => ListTile(
        title: Text(label),
        subtitle: Text(goat.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breedingRecordsAsync = ref.watch(breedingRecordsProvider(widget.goat.id));
    final dateFormat = DateFormat('MMM d, yyyy');

    return breedingRecordsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (breedingRecords) => DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(
                  text: widget.goat.gender == GoatGender.female
                      ? 'Birth Records'
                      : 'Offspring',
                ),
                const Tab(text: 'Lineage'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Birth Records / Offspring Tab
                  Stack(
                    children: [
                      if (breedingRecords.isEmpty)
                        const Center(
                          child: Text('No breeding records found'),
                        )
                      else
                        ListView.builder(
                          itemCount: breedingRecords.length,
                          itemBuilder: (context, index) {
                            final record = breedingRecords[index];
                            return ListTile(
                              title: Text('Breeding Record ${index + 1}'),
                              subtitle: Text(
                                'Mating Date: ${dateFormat.format(record.matingDate ?? DateTime.now())}',
                              ),
                              onTap: () => _showEditRecordDialog(record),
                            );
                          },
                        ),
                      if (widget.canEdit)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton(
                            onPressed: _showAddRecordDialog,
                            child: const Icon(Icons.add),
                          ),
                        ),
                    ],
                  ),
                  // Lineage Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.goat.parentSireId != null || widget.goat.parentDamId != null)
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Parents',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const Divider(),
                                  if (widget.goat.parentSireId != null)
                                    _buildParentInfo(widget.goat.parentSireId!, 'Sire'),
                                  if (widget.goat.parentDamId != null)
                                    _buildParentInfo(widget.goat.parentDamId!, 'Dam'),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/weight_log.dart';
import 'package:goat_tracker/providers.dart';
import 'package:fl_chart/fl_chart.dart';

class WeightTab extends ConsumerWidget {
  final Goat goat;
  final bool canEdit;

  const WeightTab({
    super.key,
    required this.goat,
    this.canEdit = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightLogsAsync = ref.watch(weightLogsProvider(goat.id));
    
    return weightLogsAsync.when(
      data: (weightLogs) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Weight',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        goat.lastWeightKg != null
                            ? '${goat.lastWeightKg!.toStringAsFixed(1)} kg'
                            : 'No weight recorded',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      if (weightLogs.length >= 2) ...[
                        const SizedBox(height: 8),
                        Text(
                          _getWeightTrend(weightLogs),
                          style: TextStyle(
                            color: _getWeightTrendColor(weightLogs),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (weightLogs.length >= 2) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 1.7,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: _getChartData(weightLogs),
                              isCurved: true,
                              color: Theme.of(context).primaryColor,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  itemCount: weightLogs.length,
                  itemBuilder: (context, index) {
                    final log = weightLogs[index];
                    final previousWeight = index < weightLogs.length - 1
                        ? weightLogs[index + 1].weightKg
                        : null;
                    final change = previousWeight != null
                        ? log.weightKg - previousWeight
                        : null;

                    return Card(
                      child: ListTile(
                        title: Text('${log.weightKg} kg'),
                        subtitle: Text(DateFormat('MMM d, yyyy').format(log.measurementDate)),
                        trailing: change != null
                            ? Text(
                                '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
                                style: TextStyle(
                                  color: change >= 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
              if (canEdit) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddWeightDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Weight Record'),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  String _getWeightTrend(List<WeightLog> logs) {
    if (logs.length < 2) return '';

    final latestWeight = logs.first.weightKg;
    final previousWeight = logs[1].weightKg;
    final difference = latestWeight - previousWeight;
    final percentChange = (difference / previousWeight * 100).abs();

    return difference > 0
        ? '⬆ Gained ${difference.toStringAsFixed(1)} kg (${percentChange.toStringAsFixed(1)}%)'
        : '⬇ Lost ${difference.abs().toStringAsFixed(1)} kg (${percentChange.toStringAsFixed(1)}%)';
  }

  Color _getWeightTrendColor(List<WeightLog> logs) {
    if (logs.length < 2) return Colors.black;

    final latestWeight = logs.first.weightKg;
    final previousWeight = logs[1].weightKg;
    return latestWeight > previousWeight ? Colors.green : Colors.red;
  }

  List<FlSpot> _getChartData(List<WeightLog> logs) {
    final reversedLogs = logs.reversed.toList();
    return List.generate(reversedLogs.length, (index) {
      return FlSpot(index.toDouble(), reversedLogs[index].weightKg);
    });
  }

  Future<void> _showAddWeightDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    double? weight;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Weight Record'),
        content: Form(
          key: formKey,
          child: TextFormField(
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              suffixText: 'kg',
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a weight';
              }
              final number = double.tryParse(value);
              if (number == null || number <= 0) {
                return 'Please enter a valid weight';
              }
              return null;
            },
            onSaved: (value) => weight = double.parse(value!),
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
                formKey.currentState!.save();
                ref.read(weightLogServiceProvider).addWeightLog(
                      goatId: goat.id,
                      weightKg: weight!,
                      measurementDate: DateTime.now(),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/services/supabase_service.dart';

final expenseSummaryProvider = StreamProvider.autoDispose((ref) => Svc.expenseSummary());

class ExpenseSummaryScreen extends ConsumerWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(expenseSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Summary'),
      ),
      body: summary.when(
        data: (data) {
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return ListTile(
                leading: Icon(
                  item['type'] == 'feed' ? Icons.grass :
                  item['type'] == 'medicine' ? Icons.medical_services :
                  Icons.directions_bus,
                  color: Colors.green,
                ),
                title: Text(
                  item['type'].toString().toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Total: ₹${item['total']}'),
                trailing: Text('${item['count']} expenses'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

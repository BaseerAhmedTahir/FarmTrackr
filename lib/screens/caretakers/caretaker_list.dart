import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:goat_tracker/models/caretaker.dart';
import 'package:goat_tracker/screens/caretakers/add_caretaker.dart';
import 'package:goat_tracker/services/service.dart';

final caretakerSummaryProvider = StreamProvider.autoDispose((ref) => Svc.caretakerSummary());

class CaretakerList extends ConsumerWidget {
  const CaretakerList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summarySnap = ref.watch(caretakerSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretakers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCaretakerScreen()),
            ),
          ),
        ],
      ),
      body: summarySnap.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No caretakers yet'));
          }
          return ListView.builder(
            itemCount: list.length,
            itemBuilder: (context, i) {
              final c = list[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.person, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c['name'],
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                if (c['phone'] != null)
                                  Text(c['phone'], style: Theme.of(context).textTheme.bodyMedium),
                                if (c['location'] != null)
                                  Text(c['location'], style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _stat('Goats', (c['total_goats'] ?? 0).toString()),
                            const VerticalDivider(),
                            _stat('Investment', '₹${c['total_expenses'] ?? 0}'),
                            const VerticalDivider(),
                            _stat('Profit Share', '${c['profit_share'] ?? 0}%'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
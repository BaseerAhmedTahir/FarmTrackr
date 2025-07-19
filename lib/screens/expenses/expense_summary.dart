import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:goat_tracker/widgets/chart_card.dart';
import 'package:goat_tracker/widgets/summary_card.dart';
import 'package:goat_tracker/models/metric.dart';
import 'package:goat_tracker/models/expense_summary.dart';

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
      body: RefreshIndicator(
        onRefresh: () async {
          await Svc.syncData();
          ref.invalidate(expenseSummaryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            summary.when(
              data: (data) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Monthly expense chart
                  ChartCard(
                    title: 'Monthly Expenses',
                    data: data,
                  ),
                  const SizedBox(height: 24),

                  // Summary statistics
                  SummaryCard(
                    title: 'Expense Statistics',
                    metrics: [
                      Metric(
                        'Total Expenses',
                        '₹${data.fold<double>(0, (sum, e) => sum + e.amount).toStringAsFixed(2)}',
                      ),
                      Metric(
                        'Average Monthly',
                        data.isEmpty 
                            ? '₹0.00'
                            : '₹${(data.fold<double>(0, (sum, e) => sum + e.amount) / data.length).toStringAsFixed(2)}',
                      ),
                      Metric(
                        'Highest Month',
                        data.isEmpty 
                            ? 'No data'
                            : '${data.reduce((a, b) => a.amount > b.amount ? a : b).month}',
                      ),
                    ],
                  ),
                ],
              ),
              error: (e, s) => Center(child: Text('Error: $e')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}

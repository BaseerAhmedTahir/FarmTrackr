import 'package:flutter/material.dart';
import 'package:goat_tracker/services/service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:goat_tracker/screens/expenses/expense_summary.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';

final financeProvider = StreamProvider.autoDispose((ref) => Svc.financeSummary());

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext ctx, WidgetRef ref) {
    final snap = ref.watch(financeProvider);
    
    // Debug: Check goats when dashboard loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Svc.debugCheckGoats();
    });
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            onPressed: () => Navigator.push(
              ctx,
              MaterialPageRoute(builder: (_) => const ExpenseSummaryScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final data = await Svc.exportData();
              final csvStr = const ListToCsvConverter().convert(data);
              final bytes = utf8.encode(csvStr);
              final temp = await getTemporaryDirectory();
              final file = File('${temp.path}/goat_data.csv')..writeAsBytesSync(bytes);
              await Share.shareXFiles([XFile(file.path)], text: 'Goat Farm Data Export');
            },
          ),
        ],
      ),
      body: snap.when(
        data: (d) => GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 2,
          padding: const EdgeInsets.all(12),
          children: [
            _tile('Goats', d.count.toString(), Icons.pets),
            _tile('Invested', '₹${d.invested.toStringAsFixed(2)}', Icons.account_balance),
            _tile('Sales', '₹${d.sales.toStringAsFixed(2)}', Icons.shopping_cart),
            _tile('Profit', '₹${d.profit.toStringAsFixed(2)}', Icons.trending_up,
                color: d.profit >= 0 ? Colors.green : Colors.red),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _tile(String title, String val, IconData ic, {Color? color}) => Card(
        color: color?.withAlpha(30),
        child: Center(
          child: ListTile(
            title: Text(val, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            subtitle: Text(title),
            leading: Icon(ic),
          ),
        ),
      );
}
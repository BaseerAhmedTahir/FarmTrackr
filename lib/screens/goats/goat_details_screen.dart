import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_weight_dialog.dart';
import 'weight_chart.dart';
import 'scan_history.dart';
import 'qr_scanner_screen.dart';
import 'nfc_scanner_screen.dart';

class GoatDetailsScreen extends ConsumerWidget {
  final Map<String, dynamic> goat;

  const GoatDetailsScreen({super.key, required this.goat});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Goat ${goat['tag_id']}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Basic Info',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      leading: const Icon(Icons.tag),
                      title: const Text('Tag ID'),
                      subtitle: Text(goat['tag_id']),
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Purchase Date'),
                      subtitle: Text(goat['purchase_date']),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title: const Text('Purchase Price'),
                      subtitle: Text('₹${goat['purchase_price']}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Weight History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddWeightDialog(
                                goatId: goat['id'],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: WeightChart(goatId: goat['id']),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Scan History',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.qr_code),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QrScannerScreen(goatId: goat['id']),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.nfc),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NfcScannerScreen(goatId: goat['id']),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ScanHistory(goatId: goat['id']),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

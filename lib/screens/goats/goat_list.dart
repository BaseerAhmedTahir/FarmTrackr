import 'package:flutter/material.dart';
import 'package:goat_tracker/services/supabase_service.dart';
import 'package:goat_tracker/screens/expenses/add_expense.dart';
import 'package:goat_tracker/screens/sales/sell_goat.dart';
import 'goat_details_screen.dart';

class GoatListScreen extends StatelessWidget {
  const GoatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Svc.goats(),
      builder: (context, goatSnap) {
        if (!goatSnap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final goats = goatSnap.data!;
        if (goats.isEmpty) {
          return const Center(child: Text('No goats 🐐'));
        }

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: Svc.caretakers(),
          builder: (context, careSnap) {
            if (!careSnap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final caretakersList = careSnap.data!;
            final caretakers = {
              for (var c in caretakersList) c['id'] as String: c['name'] as String
            };

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 0.75,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: goats.length,
              itemBuilder: (ctx, i) {
                final g = goats[i];
                final caretakerName = caretakers[g['caretaker_id']] ?? '—';
                return Card(
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: g['photo_url'] != null
                          ? Image.network(g['photo_url'], fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported, size: 48),
                      ),
                      ListTile(
                        title: Text(g['tag_id'] ?? ''),
                        subtitle: Text('₹${g['purchase_price']} • $caretakerName'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.info_outline),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => GoatDetailsScreen(goat: g),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.receipt_long),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddExpenseScreen(g['id']),
                                ),
                              ),
                            ),
                            if (!(g['is_sold'] ?? false))
                              IconButton(
                                icon: const Icon(Icons.currency_rupee),
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SellGoatScreen(g),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  Future<List<Map<String, dynamic>>> _fetchSales() async {
    try {
      final response = await Supabase.instance.client
          .from('sales')
          .select('*, goats(*)')
          .order('date', ascending: false);
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching sales: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchSales(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final sales = snapshot.data ?? [];

          if (sales.isEmpty) {
            return const Center(
              child: Text('No sales recorded'),
            );
          }

          return ListView.builder(
            itemCount: sales.length,
            itemBuilder: (context, index) {
              final sale = sales[index];
              final goat = sale['goats'] as Map<String, dynamic>?;
              return ListTile(
                leading: const Icon(Icons.sell),
                title: Text(goat?['tag_number'] ?? 'Unknown Goat'),
                subtitle: Text(
                  'Date: ${sale['date'] ?? 'Unknown'}\n'
                  'Price: \$${sale['price']?.toString() ?? '0.00'}',
                ),
                trailing: goat?['tag_number'] != null
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.error, color: Colors.red),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add sale functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Add sale functionality coming soon!'),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

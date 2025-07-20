import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoatListScreen extends StatefulWidget {
  const GoatListScreen({super.key});

  @override
  State<GoatListScreen> createState() => _GoatListScreenState();
}

class _GoatListScreenState extends State<GoatListScreen> {
  Future<List<Map<String, dynamic>>> _fetchGoats() async {
    try {
      final response = await Supabase.instance.client
          .from('goats')
          .select()
          .order('tag_number');
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      // Handle error appropriately
      print('Error fetching goats: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goats'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchGoats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final goats = snapshot.data ?? [];

          if (goats.isEmpty) {
            return const Center(
              child: Text('No goats found'),
            );
          }

          return ListView.builder(
            itemCount: goats.length,
            itemBuilder: (context, index) {
              final goat = goats[index];
              final id = goat['id'] as String?;
              if (id == null) return const SizedBox.shrink();
              
              return ListTile(
                leading: CircleAvatar(
                  child: Text(goat['tag_number']?.toString().substring(0, 1) ?? '?'),
                ),
                title: Text(goat['tag_number']?.toString() ?? 'No tag'),
                subtitle: Text(goat['breed']?.toString() ?? 'Unknown breed'),
                trailing: Text(
                  goat['status']?.toString() ?? 'Active',
                ),
                onTap: () => context.go('/goats/$id'),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaretakerListScreen extends StatefulWidget {
  const CaretakerListScreen({super.key});

  @override
  State<CaretakerListScreen> createState() => _CaretakerListScreenState();
}

class _CaretakerListScreenState extends State<CaretakerListScreen> {
  Future<List<Map<String, dynamic>>> _fetchCaretakers() async {
    try {
      final response = await Supabase.instance.client
          .from('caretakers')
          .select()
          .order('name');
      return response as List<Map<String, dynamic>>;
    } catch (e) {
      print('Error fetching caretakers: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretakers'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchCaretakers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final caretakers = snapshot.data ?? [];

          if (caretakers.isEmpty) {
            return const Center(
              child: Text('No caretakers found'),
            );
          }

          return ListView.builder(
            itemCount: caretakers.length,
            itemBuilder: (context, index) {
              final caretaker = caretakers[index];
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(caretaker['name'] ?? 'Unnamed'),
                subtitle: Text(caretaker['phone'] ?? 'No phone'),
                onTap: () => context.go('/caretakers/${caretaker['id']}'),
              );
            },
          );
        },
      ),
    );
  }
}

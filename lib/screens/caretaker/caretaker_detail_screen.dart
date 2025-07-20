import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class CaretakerDetailScreen extends StatefulWidget {
  final String caretakerId;

  const CaretakerDetailScreen({
    Key? key,
    required this.caretakerId,
  }) : super(key: key);

  @override
  State<CaretakerDetailScreen> createState() => _CaretakerDetailScreenState();
}

class _CaretakerDetailScreenState extends State<CaretakerDetailScreen> {
  Future<Map<String, dynamic>?> _fetchCaretaker() async {
    try {
      final response = await Supabase.instance.client
          .from('caretakers')
          .select()
          .eq('id', widget.caretakerId)
          .single();
      return response as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching caretaker: $e');
      return null;
    }
  }

  Future<void> _deleteCaretaker() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this caretaker?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Supabase.instance.client
            .from('caretakers')
            .delete()
            .eq('id', widget.caretakerId);
        if (mounted) context.go('/caretakers');
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting caretaker: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caretaker Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/caretakers/${widget.caretakerId}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteCaretaker,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchCaretaker(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final caretaker = snapshot.data;
          if (caretaker == null) {
            return const Center(child: Text('Caretaker not found'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Name'),
                subtitle: Text(caretaker['name'] ?? 'Not provided'),
              ),
              ListTile(
                title: const Text('Phone'),
                subtitle: Text(caretaker['phone'] ?? 'Not provided'),
              ),
              ListTile(
                title: const Text('Location'),
                subtitle: Text(caretaker['location'] ?? 'Not provided'),
              ),
              ListTile(
                title: const Text('Payment Type'),
                subtitle: Text(caretaker['payment_type'] ?? 'Not provided'),
              ),
              if (caretaker['profit_share_pct'] != null)
                ListTile(
                  title: const Text('Profit Share %'),
                  subtitle: Text('${caretaker['profit_share_pct']}%'),
                ),
              if (caretaker['monthly_fee'] != null)
                ListTile(
                  title: const Text('Monthly Fee'),
                  subtitle: Text('\$${caretaker['monthly_fee']}'),
                ),
              if (caretaker['notes'] != null && caretaker['notes'].isNotEmpty)
                ListTile(
                  title: const Text('Notes'),
                  subtitle: Text(caretaker['notes']),
                ),
            ],
          );
        },
      ),
    );
  }
}

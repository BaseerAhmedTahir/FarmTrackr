import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GoatDetailScreen extends StatefulWidget {
  final String goatId;

  const GoatDetailScreen({
    required this.goatId,
    super.key,
  });

  @override
  State<GoatDetailScreen> createState() => _GoatDetailScreenState();
}

class _GoatDetailScreenState extends State<GoatDetailScreen> {
  Map<String, dynamic>? _goat;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadGoat();
  }

  Future<void> _loadGoat() async {
    try {
      final response = await Supabase.instance.client
          .from('goats')
          .select()
          .eq('id', widget.goatId)
          .single();
      
      setState(() {
        _goat = response as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load goat: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteGoat() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goat'),
        content: const Text('Are you sure you want to delete this goat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('goats')
          .delete()
          .eq('id', widget.goatId);
      
      if (mounted) {
        context.go('/goats');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to delete goat: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Text(_error!),
        ),
      );
    }

    if (_goat == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: Text('Goat not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Goat ${_goat!['tag_number']}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteGoat,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_goat!['photo_url'] != null)
              Card(
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  _goat!['photo_url'],
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            _buildInfoRow('Tag Number', _goat!['tag_number']?.toString() ?? 'Unknown'),
            _buildInfoRow('Breed', _goat!['breed']?.toString() ?? 'Unknown'),
            _buildInfoRow('Age', _goat!['age'] != null ? '${_goat!['age']} months' : 'Unknown'),
            _buildInfoRow('Gender', _goat!['gender']?.toString() ?? 'Unknown'),
            _buildInfoRow('Status', _goat!['status']?.toString() ?? 'Active'),
            _buildInfoRow('Weight', _goat!['weight'] != null ? '${_goat!['weight']} kg' : 'Unknown'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Health Records',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Implement health record addition
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // TODO: Implement health records list
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

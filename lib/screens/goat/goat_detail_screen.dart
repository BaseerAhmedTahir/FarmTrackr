import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/goat.dart';
import '../../providers.dart';
import 'goat_tabs/breeding_tab.dart';
import 'goat_tabs/health_tab.dart';
import 'goat_tabs/profile_tab.dart';
import 'goat_tabs/weight_tab.dart';

class GoatDetailScreen extends ConsumerWidget {
  final String goatId;

  const GoatDetailScreen({
    required this.goatId,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goatAsyncValue = ref.watch(goatProvider(goatId));

    return goatAsyncValue.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (goat) => DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text(goat.tagNumber),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: () {
                  // TODO: Implement photo upload
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(context, ref, goat),
              ),
            ],
            bottom: const TabBar(
              isScrollable: true,
              tabs: [
                Tab(text: 'Profile'),
                Tab(text: 'Weight'),
                Tab(text: 'Health'),
                Tab(text: 'Breeding'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              GoatProfileTab(goat: goat),
              WeightTab(goat: goat),
              HealthTab(goat: goat),
              BreedingTab(goat: goat),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref, Goat goat) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goat'),
        content: const Text('Are you sure you want to delete this goat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(goatServiceProvider).deleteGoat(goat.id);
      if (context.mounted) {
        context.pop(); // Pop screen
      }
    }
  }
}

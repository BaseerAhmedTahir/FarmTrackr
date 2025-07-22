import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/goat.dart';
import '../../providers.dart';

extension GoatStatusX on GoatStatus {
  Color get color {
    switch (this) {
      case GoatStatus.active:
        return Colors.green;
      case GoatStatus.sold:
        return Colors.blue;
      case GoatStatus.dead:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class GoatListScreen extends ConsumerWidget {
  const GoatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goatsAsyncValue = ref.watch(goatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/goats/add'),
          ),
        ],
      ),
      body: goatsAsyncValue.when(
        data: (goats) {
          if (goats.isEmpty) {
            return const Center(
              child: Text('No goats found. Add your first goat!'),
            );
          }

          return ListView.builder(
            itemCount: goats.length,
            itemBuilder: (context, index) {
              final goat = goats[index];
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    goat.tagNumber.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(goat.tagNumber),
                subtitle: Text(goat.name ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: goat.status.color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        goat.status.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => context.push('/goats/${goat.id}'),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

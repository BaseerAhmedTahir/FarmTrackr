import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/goat.dart';
import '../../providers.dart';
import '../../widgets/goat_search_delegate.dart';

extension GoatStatusX on GoatStatus {
  Color get color {
    switch (this) {
      case GoatStatus.active:
        return Colors.green;
      case GoatStatus.sold:
        return Colors.blue;
      case GoatStatus.dead:
        return Colors.red;
    }
  }
}

// Filter and sort providers
final goatSearchProvider = StateProvider<String>((ref) => '');
final goatStatusFilterProvider = StateProvider<GoatStatus?>((ref) => null);
final goatSortFieldProvider = StateProvider<String>((ref) => 'tagNumber');
final goatSortAscendingProvider = StateProvider<bool>((ref) => true);

// Filtered goats provider
final filteredGoatsProvider = Provider<AsyncValue<List<Goat>>>((ref) {
  return ref.watch(goatsProvider).when(
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
    data: (goats) {
      var filteredGoats = List<Goat>.from(goats);
      final search = ref.watch(goatSearchProvider).toLowerCase();
      final statusFilter = ref.watch(goatStatusFilterProvider);
      final sortField = ref.watch(goatSortFieldProvider);
      final ascending = ref.watch(goatSortAscendingProvider);

      // Apply search filter
      if (search.isNotEmpty) {
        filteredGoats = filteredGoats.where((goat) {
          return goat.tagNumber.toLowerCase().contains(search) ||
              goat.name.toLowerCase().contains(search);
        }).toList();
      }

      // Apply status filter
      if (statusFilter != null) {
        filteredGoats = filteredGoats
            .where((goat) => goat.status == statusFilter)
            .toList();
      }

      // Apply sorting
      filteredGoats.sort((a, b) {
        var comparison = 0;
        switch (sortField) {
          case 'tagNumber':
            comparison = a.tagNumber.compareTo(b.tagNumber);
            break;
          case 'name':
            comparison = a.name.compareTo(b.name);
            break;
          case 'birthDate':
            comparison = a.birthDate.compareTo(b.birthDate);
            break;
          case 'status':
            comparison = a.status.name.compareTo(b.status.name);
            break;
        }
        return ascending ? comparison : -comparison;
      });

      return AsyncData(filteredGoats);
    },
  );
});

class GoatListScreen extends ConsumerWidget {
  const GoatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goatsAsync = ref.watch(filteredGoatsProvider);
    final sortField = ref.watch(goatSortFieldProvider);
    final ascending = ref.watch(goatSortAscendingProvider);
    final statusFilter = ref.watch(goatStatusFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Goats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search goats',
            onPressed: () async {
              final allGoats = await ref.read(goatsProvider.future);
              // ignore: use_build_context_synchronously
              final searchResult = await showSearch(
                context: context,
                delegate: GoatSearchDelegate(allGoats),
              );
              if (searchResult != null && searchResult.isNotEmpty) {
                ref.read(goatSearchProvider.notifier).state = searchResult;
              }
            },
          ),
          PopupMenuButton<GoatStatus?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by status',
            initialValue: statusFilter,
            onSelected: (status) {
              ref.read(goatStatusFilterProvider.notifier).state = status;
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('All Goats'),
              ),
              ...GoatStatus.values.map((status) => PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: status.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(status.name.toUpperCase()),
                  ],
                ),
              )),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort goats',
            initialValue: sortField,
            onSelected: (value) {
              if (sortField == value) {
                ref.read(goatSortAscendingProvider.notifier).state = !ascending;
              } else {
                ref.read(goatSortFieldProvider.notifier).state = value;
                ref.read(goatSortAscendingProvider.notifier).state = true;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'tagNumber',
                child: Row(
                  children: [
                    const Text('Sort by Tag'),
                    if (sortField == 'tagNumber')
                      Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    const Text('Sort by Name'),
                    if (sortField == 'name')
                      Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'birthDate',
                child: Row(
                  children: [
                    const Text('Sort by Age'),
                    if (sortField == 'birthDate')
                      Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'status',
                child: Row(
                  children: [
                    const Text('Sort by Status'),
                    if (sortField == 'status')
                      Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add new goat',
            onPressed: () => context.push('/goats/add'),
          ),
        ],
      ),
      body: switch (goatsAsync) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                statusFilter != null || ref.read(goatSearchProvider).isNotEmpty
                    ? 'No goats found matching filters'
                    : 'No goats yet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                statusFilter != null || ref.read(goatSearchProvider).isNotEmpty
                    ? 'Try changing your search or filters'
                    : 'Add your first goat to get started',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 16),
              if (statusFilter != null || ref.read(goatSearchProvider).isNotEmpty)
                FilledButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear Filters'),
                  onPressed: () {
                    ref.read(goatSearchProvider.notifier).state = '';
                    ref.read(goatStatusFilterProvider.notifier).state = null;
                  },
                )
              else
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Goat'),
                  onPressed: () => context.push('/goats/add'),
                ),
            ],
          ),
        ),
        AsyncData(:final value) => ListView.separated(
          padding: const EdgeInsets.all(8),
          itemCount: value.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final goat = value[index];
            return ListTile(
              leading: Hero(
                tag: 'goat-avatar-${goat.id}',
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    goat.tagNumber.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              title: Text(goat.tagNumber),
              subtitle: Text(goat.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
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
        ),
        AsyncError(:final error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error loading goats',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.invalidate(goatsProvider),
              ),
            ],
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

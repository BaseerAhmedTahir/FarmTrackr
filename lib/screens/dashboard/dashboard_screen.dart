import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goat_tracker/services/auth_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16.0),
        crossAxisCount: 2,
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _DashboardTile(
            icon: Icons.pets,
            title: 'Goats',
            onTap: () => context.go('/goats'),
          ),
          _DashboardTile(
            icon: Icons.people,
            title: 'Caretakers',
            onTap: () => context.go('/caretakers'),
          ),
          _DashboardTile(
            icon: Icons.monetization_on,
            title: 'Expenses',
            onTap: () => context.go('/expenses'),
          ),
          _DashboardTile(
            icon: Icons.sell,
            title: 'Sales',
            onTap: () => context.go('/sales'),
          ),
          _DashboardTile(
            icon: Icons.bar_chart,
            title: 'Reports',
            onTap: () => context.go('/reports'),
          ),
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

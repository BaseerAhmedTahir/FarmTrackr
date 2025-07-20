import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_bar.dart' as nav;

class MainLayout extends StatelessWidget {
  final Widget child;
  final int selectedIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: nav.NavigationBar(selectedIndex: selectedIndex),
      floatingActionButton: selectedIndex == 1
          ? FloatingActionButton(
              heroTag: 'add_goat_fab',
              onPressed: () => context.go('/goats/add'),
              child: const Icon(Icons.add),
            )
          : selectedIndex == 2
              ? FloatingActionButton(
                  heroTag: 'add_caretaker_fab',
                  onPressed: () => context.go('/caretakers/add'),
                  child: const Icon(Icons.add),
                )
              : selectedIndex == 3
                  ? FloatingActionButton(
                      heroTag: 'add_expense_fab',
                      onPressed: () => context.go('/expenses/add'),
                      child: const Icon(Icons.add),
                    )
                  : null,
    );
  }
}

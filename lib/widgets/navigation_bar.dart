import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goat_tracker/screens/expense/expense_list_screen.dart';
import 'package:goat_tracker/screens/goat/goat_list_screen.dart';
import 'package:goat_tracker/screens/caretaker/caretaker_list_screen.dart';

class NavigationBar extends StatelessWidget {
  final int selectedIndex;

  const NavigationBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/');
            break;
          case 1:
            context.go('/goats');
            break;
          case 2:
            context.go('/caretakers');
            break;
          case 3:
            context.go('/expenses');
            break;
          case 4:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Goats',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'Caretakers',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.monetization_on),
          label: 'Expenses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

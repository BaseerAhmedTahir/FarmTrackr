import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'goats/goat_list.dart';
import './caretakers/caretaker_list.dart';
import './goats/add_goat.dart';
import './caretakers/add_caretaker.dart';
import './profile_screen.dart';
import './settings_screen.dart';
import './notifications_screen.dart' show NotificationsScreen, notificationsProvider;

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});
  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int idx = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const GoatListScreen(),
      const CaretakerList(),
      const NotificationsScreen(),
      const ProfileScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: screens[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Goats'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Caretakers'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                Consumer(
                  builder: (context, ref, _) {
                    final unread = ref.watch(notificationsProvider).whenOrNull(
                      data: (notifications) => notifications
                        .where((n) => !n['read'])
                        .length,
                    );
                    if (unread == null || unread == 0) return const SizedBox();
                    return Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          const BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: idx == 0
        ? FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddGoatScreen()),
            ),
            child: const Icon(Icons.add),
          )
        : idx == 1
        ? FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddCaretakerScreen()),
            ),
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
}

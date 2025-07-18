import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:goat_tracker/screens/goats/goat_list.dart';
import 'package:goat_tracker/screens/goats/add_goat.dart';
import 'package:goat_tracker/screens/caretakers/caretaker_list.dart';
import 'package:goat_tracker/screens/caretakers/add_caretaker.dart';
import 'package:goat_tracker/screens/profile_screen.dart';
import 'package:goat_tracker/screens/dashboard_screen.dart';
import 'package:goat_tracker/screens/settings_screen.dart';
import 'package:goat_tracker/services/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:goat_tracker/theme/app_theme.dart';
import 'package:goat_tracker/screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await Future.wait([
    dotenv.load(),
    SettingsService.init(),
  ]);

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const ProviderScope(child: MyApp()));
}


class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    return MaterialApp(
      title: 'Goat Tracker',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) return const HomeShell();
    return const AuthScreen();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}
class _HomeShellState extends State<HomeShell> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      const DashboardScreen(),
      const GoatListScreen(),
      const CaretakerList(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: screens[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Goats'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Caretakers'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: idx == 1
          ? FloatingActionButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddGoatScreen())),
              child: const Icon(Icons.add),
            )
          : idx == 2
              ? FloatingActionButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AddCaretakerScreen())),
                  child: const Icon(Icons.add),
                )
              : null,
    );
  }
}


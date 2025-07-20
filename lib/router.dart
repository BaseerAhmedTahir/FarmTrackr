import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goat_tracker/layouts/main_layout.dart';
import 'package:goat_tracker/screens/auth/login_screen.dart';
import 'package:goat_tracker/screens/auth/profile_screen.dart';
import 'package:goat_tracker/screens/dashboard/dashboard_screen.dart';
import 'package:goat_tracker/screens/goat/add_goat_screen.dart';
import 'package:goat_tracker/screens/goat/goat_detail_screen.dart';
import 'package:goat_tracker/screens/goat/goat_list_screen.dart';
import 'package:goat_tracker/screens/caretaker/caretaker_list_screen.dart';
import 'package:goat_tracker/screens/caretaker/add_caretaker_screen.dart';
import 'package:goat_tracker/screens/caretaker/caretaker_detail_screen.dart';
import 'package:goat_tracker/screens/caretaker/edit_caretaker_screen.dart';
import 'package:goat_tracker/screens/expense/expense_list_screen.dart';
import 'package:goat_tracker/screens/expense/add_expense_screen.dart';
import 'package:goat_tracker/screens/reports/reports_screen.dart';
import 'package:goat_tracker/screens/sale/sale_screen.dart';
import 'package:goat_tracker/services/auth_service.dart';

final router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) async {
    final isLoggedIn = await AuthService().isLoggedIn();
    final isLoginRoute = state.matchedLocation == '/login';

    if (!isLoggedIn && !isLoginRoute) {
      return '/login';
    }
    if (isLoggedIn && isLoginRoute) {
      return '/';
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const MainLayout(
        selectedIndex: 0,
        child: DashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/goats',
      builder: (context, state) => const MainLayout(
        selectedIndex: 1,
        child: GoatListScreen(),
      ),
    ),
    GoRoute(
      path: '/goats/add',
      builder: (context, state) => const AddGoatScreen(),
    ),
    GoRoute(
      path: '/goats/:id',
      builder: (context, state) => GoatDetailScreen(
        goatId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/caretakers',
      builder: (context, state) => const MainLayout(
        selectedIndex: 2,
        child: CaretakerListScreen(),
      ),
    ),
    GoRoute(
      path: '/caretakers/add',
      builder: (context, state) => const AddCaretakerScreen(),
    ),
    GoRoute(
      path: '/caretakers/:id',
      builder: (context, state) => CaretakerDetailScreen(
        caretakerId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/caretakers/:id/edit',
      builder: (context, state) => EditCaretakerScreen(
        caretakerId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/expenses',
      builder: (context, state) => const MainLayout(
        selectedIndex: 3,
        child: ExpenseListScreen(),
      ),
    ),
    GoRoute(
      path: '/expenses/add',
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      path: '/reports',
      builder: (context, state) => const ReportsScreen(),
    ),
    GoRoute(
      path: '/sales',
      builder: (context, state) => const SaleScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainLayout(
        selectedIndex: 4,
        child: ProfileScreen(),
      ),
    ),
  ],
);

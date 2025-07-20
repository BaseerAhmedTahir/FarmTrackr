import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/caretaker.dart';
import 'models/goat.dart';
import 'models/sale.dart';
import 'models/expense.dart';
import 'models/financial_summary.dart';
import 'services/auth_service.dart';
import 'services/backup_service.dart';
import 'services/caretaker_service.dart';
import 'services/email_service.dart';
import 'services/expense_service.dart';
import 'services/goat_service.dart';
import 'services/notification_service.dart';
import 'services/pdf_service.dart';
import 'services/qr_service.dart';
import 'services/report_service.dart';
import 'services/sale_service.dart';
import 'services/settings_service.dart';

// Client Providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

final pdfServiceProvider = Provider<PDFService>((ref) {
  return PDFService();
});

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(
    ref.watch(pdfServiceProvider),
    ref.watch(emailServiceProvider),
  );
});

final caretakerServiceProvider = Provider<CaretakerService>((ref) {
  return CaretakerService();
});

final expenseServiceProvider = Provider<ExpenseService>((ref) {
  return ExpenseService();
});

final goatServiceProvider = Provider<GoatService>((ref) {
  return GoatService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService(ref.watch(supabaseClientProvider));
});

final saleServiceProvider = Provider<SaleService>((ref) {
  return SaleService();
});

// Data Providers
final goatsProvider = StreamProvider.autoDispose<List<Goat>>((ref) {
  return ref.watch(goatServiceProvider).watchGoats();
});

final caretakersProvider = StreamProvider.autoDispose<List<Caretaker>>((ref) {
  return ref.watch(caretakerServiceProvider).watchCaretakers();
});

final salesProvider = StreamProvider.autoDispose<List<Sale>>((ref) {
  return ref.watch(saleServiceProvider).watchSales();
});

final expensesProvider = StreamProvider.autoDispose<List<Expense>>((ref) {
  return ref.watch(expenseServiceProvider).watchExpenses();
});

final financialSummaryProvider = StreamProvider.autoDispose<FinancialSummary>((ref) {
  return ref.watch(goatServiceProvider).watchFinancialSummary();
});

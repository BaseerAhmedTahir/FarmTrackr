import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/caretaker.dart';
import 'models/goat.dart';
import 'models/sale.dart';
import 'models/expense.dart';
import 'models/financial_summary.dart';
import 'models/weight_log.dart';
import 'models/health_record.dart';
import 'models/breeding_record.dart';
import 'models/notification.dart' as goat_notification;
import 'services/auth_service.dart';
import 'services/backup_service.dart';
import 'services/caretaker_service.dart';
import 'services/email_service.dart';
import 'services/expense_service.dart';
import 'services/goat_service.dart';
import 'services/notification_service.dart';
import 'services/pdf_service.dart';
import 'services/report_service.dart';
import 'services/sale_service.dart';
import 'services/weight_log_service.dart';
import 'services/health_record_service.dart';
import 'services/breeding_record_service.dart';

// Client Providers
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main.dart');
});

// Service Providers
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

final pdfServiceProvider = Provider<PDFReportService>((ref) {
  return PDFReportService();
});

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

final reportServiceProvider = Provider<ReportService>((ref) {
  return ReportService(ref.watch(emailServiceProvider));
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
// Base Data Providers
final goatsProvider = StreamProvider.autoDispose<List<Goat>>((ref) {
  return ref.watch(goatServiceProvider).watchGoats();
});

final goatProvider = StreamProvider.family<Goat, String>((ref, id) {
  return ref.watch(goatServiceProvider).watchGoat(id);
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

// Service Providers for Enhanced Features
final weightLogServiceProvider = Provider<WeightLogService>((ref) {
  return WeightLogService();
});

final healthRecordServiceProvider = Provider<HealthRecordService>((ref) {
  return HealthRecordService();
});

final breedingRecordServiceProvider = Provider<BreedingRecordService>((ref) {
  return BreedingRecordService();
});

// Enhanced Data Providers
final weightLogsProvider = StreamProvider.family<List<WeightLog>, String>((ref, goatId) {
  return ref.watch(weightLogServiceProvider).watchWeightLogs(goatId);
});

final healthRecordsProvider = StreamProvider.family<List<HealthRecord>, String>((ref, goatId) {
  return ref.watch(healthRecordServiceProvider).watchHealthRecords(goatId);
});

final breedingRecordsProvider = StreamProvider.family<List<BreedingRecord>, String>((ref, goatId) {
  return ref.watch(breedingRecordServiceProvider).watchBreedingRecords(goatId);
});

final pendingNotificationsProvider = StreamProvider<List<goat_notification.Notification>>((ref) {
  return ref.watch(notificationServiceProvider).watchNotifications();
});

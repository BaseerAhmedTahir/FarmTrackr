import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';
import 'package:goat_tracker/services/base_service.dart';
import 'package:goat_tracker/services/email_service.dart';

class ReportService extends BaseService {
  final pdf = pw.Document();
  final EmailService _emailService;
  late final double totalInvestment;
  late final double totalSales;
  late final double totalExpenses;
  late final List<Map<String, dynamic>> expenses;
  final dateFormat = DateFormat('dd/MM/yyyy');

  ReportService(this._emailService);

  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return handleResponse(() async {
      final now = DateTime.now();
      startDate ??= DateTime(now.year, now.month, 1);
      endDate ??= DateTime(now.year, now.month + 1, 0);

      final response = await supabase.rpc('get_farm_analytics', params: {
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      });

      final data = response as Map<String, dynamic>;
      totalInvestment = (data['total_investment'] as num).toDouble();
      totalSales = (data['total_sales'] as num).toDouble();
      totalExpenses = (data['total_expenses'] as num).toDouble();
      expenses = (data['expense_breakdown'] as List).cast<Map<String, dynamic>>();

      return data;
    }, 'fetching farm analytics');
  }

  Future<List<Map<String, dynamic>>> getMonthlyTrends() async {
    return handleResponse(() async {
      final response = await supabase.rpc('get_monthly_trends');
      return (response as List).cast<Map<String, dynamic>>();
    }, 'fetching monthly trends');
  }

  Future<Map<String, dynamic>> getBreedPerformance() async {
    return handleResponse(() async {
      final response = await supabase.rpc('get_breed_performance');
      return response as Map<String, dynamic>;
    }, 'fetching breed performance');
  }

  Future<Map<String, dynamic>> getCaretakerPerformance() async {
    return handleResponse(() async {
      final response = await supabase.rpc('get_caretaker_performance');
      return response as Map<String, dynamic>;
    }, 'fetching caretaker performance');
  }

  Future<File> generateMonthlyReport({
    required DateTime? startDate,
    required DateTime? endDate,
  }) async {
    await getAnalytics(startDate: startDate, endDate: endDate);

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Monthly Farm Report', style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Paragraph(
            text: 'Report Period: ${dateFormat.format(startDate ?? DateTime.now())} to ${dateFormat.format(endDate ?? DateTime.now())}',
          ),
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Financial Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellHeight: 30,
                  data: [
                    ['Category', 'Amount (₹)'],
                    ['Total Investment', totalInvestment.toStringAsFixed(2)],
                    ['Total Sales', totalSales.toStringAsFixed(2)],
                    ['Total Expenses', totalExpenses.toStringAsFixed(2)],
                    ['Net Profit', (totalSales - totalInvestment - totalExpenses).toStringAsFixed(2)],
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Container(
            padding: pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Expense Breakdown',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green800,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Table.fromTextArray(
                  context: context,
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headerDecoration: pw.BoxDecoration(
                    color: PdfColors.grey200,
                  ),
                  cellHeight: 30,
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerRight,
                  },
                  data: [
                    ['Type', 'Amount (₹)'],
                    ...expenses.map((e) => [
                      e['type'] ?? 'Other',
                      (e['total_expense'] ?? 0).toString(),
                    ]),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Save PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/monthly_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  Future<void> sendReportByEmail({
    required String email,
    required File report,
  }) async {
    try {
      await _emailService.sendReport(
        recipientEmail: email,
        subject: 'Monthly Farm Report - ${DateFormat.yMMM().format(DateTime.now())}',
        body: 'Please find attached your monthly farm report.',
        attachment: report,
      );
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  Future<void> viewReport({DateTime? startDate, DateTime? endDate}) async {
    final file = await generateMonthlyReport(startDate: startDate, endDate: endDate);
    await OpenFilex.open(file.path);
  }
}

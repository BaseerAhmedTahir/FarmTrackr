import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/sale.dart';
import 'package:goat_tracker/models/expense.dart';
import 'package:goat_tracker/models/financial_summary.dart';
import 'package:goat_tracker/services/base_service.dart';
import 'package:goat_tracker/services/pdf_service.dart';
import 'package:goat_tracker/services/email_service.dart';

class ReportService extends BaseService {
  final PDFService _pdfService;
  final EmailService _emailService;

  ReportService(this._pdfService, this._emailService);

  Future<Map<String, dynamic>> getAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return handleResponse(() async {
      final now = DateTime.now();
      startDate ??= DateTime(now.year, now.month, 1);
      endDate ??= DateTime(now.year, now.month + 1, 0);

      final response = await supabase.rpc('get_farm_analytics', params: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      });

      return response as Map<String, dynamic>;
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
    required String recipientEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final analytics = await getAnalytics(startDate: startDate, endDate: endDate);
    final trends = await getMonthlyTrends();
    final breedPerformance = await getBreedPerformance();
    final caretakerPerformance = await getCaretakerPerformance();
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

          // Expense Breakdown
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
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
                    color: PdfColor.fromHex('#2E7D32'),
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

  static Future<void> sendReportByEmail({
    required String email,
    required File report,
  }) async {
    final smtpServer = gmail('your-email@gmail.com', 'your-app-password');
    
    final message = Message()
      ..from = Address('your-email@gmail.com', 'Goat Tracker')
      ..recipients.add(email)
      ..subject = 'Monthly Farm Report - ${DateFormat.yMMM().format(DateTime.now())}'
      ..text = 'Please find attached your monthly farm report.'
      ..attachments = [
        FileAttachment(report)
          ..location = Location.attachment
          ..fileName = 'monthly_report.pdf'
      ];

    try {
      await send(message, smtpServer);
    } catch (e) {
      throw Exception('Failed to send email: $e');
    }
  }

  static Future<void> viewReport() async {
    final file = await generateMonthlyReport();
    await OpenFilex.open(file.path);
  }
}

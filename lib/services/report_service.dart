import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'supabase_service.dart';

class ReportService {
  static Future<File> generateMonthlyReport() async {
    final pdf = pw.Document();
    
    // Fetch data
    final finances = await Svc.getFinanceData();
    final expenses = await Svc.getFinanceData(); // You might want to create a separate method for monthly expenses

    // Calculate monthly totals
    double totalInvestment = 0;
    double totalSales = 0;
    double totalExpenses = 0;

    for (var item in finances) {
      totalInvestment += (item['purchase_price'] as num).toDouble();
      totalSales += ((item['sale_price'] ?? 0) as num).toDouble();
    }

    for (var expense in expenses) {
      totalExpenses += ((expense['total_expense'] ?? 0) as num).toDouble();
    }

    // Generate PDF content
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#2E7D32'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Monthly Farm Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  'Generated on: ${DateFormat.yMMMMd().format(DateTime.now())}',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Financial Summary
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
                  'Financial Summary',
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

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:goat_tracker/models/goat.dart';
import 'package:goat_tracker/models/sale.dart';
import 'package:goat_tracker/models/expense.dart';
import 'package:goat_tracker/models/financial_summary.dart';
import 'package:goat_tracker/models/weight_record.dart';

class PDFReportService {
  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  static Future<File> generateGoatReport(
    Goat goat,
    List<Expense> expenses,
    List<WeightRecord> weights,
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Goat Details Report'),
          _buildGoatDetails(goat),
          pw.SizedBox(height: 20),
          if (weights.isNotEmpty) ...[
            _buildWeightHistory(weights),
            pw.SizedBox(height: 20),
          ],
          if (expenses.isNotEmpty) ...[
            _buildExpensesTable(expenses),
          ],
        ],
      ),
    );

    return _savePdf('goat_${goat.tagNumber}_report.pdf', pdf);
  }

  static Future<File> generateFinancialReport(
    FinancialSummary summary,
    List<Sale> sales,
    List<Expense> expenses,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          _buildHeader('Financial Report'),
          _buildDateRange(startDate, endDate),
          _buildFinancialSummary(summary),
          pw.SizedBox(height: 20),
          _buildSalesTable(sales),
          pw.SizedBox(height: 20),
          _buildExpensesTable(expenses),
        ],
      ),
    );

    return _savePdf('financial_report_${DateFormat('yyyy_MM_dd').format(startDate)}.pdf', pdf);
  }

  static pw.Widget _buildHeader(String title) {
    return pw.Header(
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static pw.Widget _buildDateRange(DateTime start, DateTime end) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 10),
      child: pw.Text(
        'Period: ${_dateFormat.format(start)} - ${_dateFormat.format(end)}',
        style: pw.TextStyle(fontSize: 14),
      ),
    );
  }

  static pw.Widget _buildGoatDetails(Goat goat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Tag Number', goat.tagNumber),
          _buildDetailRow('Name', goat.name),
          _buildDetailRow('Breed', goat.breed),
          _buildDetailRow('Gender', goat.gender.name),
          _buildDetailRow('Birth Date', _dateFormat.format(goat.birthDate)),
          _buildDetailRow('Purchase Price', 'Rs. ${goat.price}'),
          if (goat.saleDate != null) ...[
            _buildDetailRow('Sale Date', _dateFormat.format(goat.saleDate!)),
            _buildDetailRow('Sale Price', 'Rs. ${goat.salePrice ?? 0}'),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value),
        ],
      ),
    );
  }

  static pw.Widget _buildFinancialSummary(FinancialSummary summary) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Active Goats', summary.activeGoats.toString()),
          _buildDetailRow('Sold Goats', summary.soldGoats.toString()),
          _buildDetailRow('Total Investment', 'Rs. ${summary.totalInvestment}'),
          _buildDetailRow('Total Sales', 'Rs. ${summary.totalSales}'),
          _buildDetailRow('Total Profit', 'Rs. ${summary.totalProfit}'),
        ],
      ),
    );
  }

  static pw.Widget _buildWeightHistory(List<WeightRecord> weights) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Weight (kg)'),
            _buildTableHeader('Notes'),
          ],
        ),
        ...weights.map((weight) => pw.TableRow(
          children: [
            _buildTableCell(_dateFormat.format(weight.date)),
            _buildTableCell(weight.weight.toString()),
            _buildTableCell(weight.notes ?? ''),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text),
    );
  }

  static Future<File> _savePdf(String fileName, pw.Document pdf) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildSalesTable(List<Sale> sales) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Goat Tag'),
            _buildTableHeader('Price'),
            _buildTableHeader('Buyer'),
          ],
        ),
        ...sales.map((sale) => pw.TableRow(
          children: [
            _buildTableCell(_dateFormat.format(sale.saleDate)),
            _buildTableCell(sale.goatId),
            _buildTableCell('Rs. ${sale.salePrice}'),
            _buildTableCell(sale.buyerName ?? ''),
          ],
        )),
      ],
    );
  }

  static pw.Widget _buildExpensesTable(List<Expense> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Type'),
            _buildTableHeader('Amount'),
            _buildTableHeader('Notes'),
          ],
        ),
        ...expenses.map((expense) => pw.TableRow(
          children: [
            _buildTableCell(_dateFormat.format(expense.date)),
            _buildTableCell(expense.type.name),
            _buildTableCell('Rs. ${expense.amount}'),
            _buildTableCell(expense.notes ?? ''),
          ],
        )),
      ],
    );
  }
}

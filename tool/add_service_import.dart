import 'dart:io';

void main() {
  final files = [
    'lib/screens/dashboard_screen.dart',
    'lib/screens/expenses/expense_summary.dart',
    'lib/screens/goats/goat_list.dart',
    'lib/screens/goats/add_goat.dart',
    'lib/screens/caretakers/add_caretaker.dart',
    'lib/screens/expenses/add_expense.dart',
    'lib/screens/sales/sell_goat.dart',
    'lib/widgets/goat_photo.dart',
    'lib/services/report_service.dart',
    'lib/screens/goats/add_weight_dialog.dart',
    'lib/screens/goats/weight_chart.dart',
    'lib/screens/goats/scan_history.dart',
    'lib/screens/goats/add_scan_dialog.dart',
  ];

  for (final file in files) {
    final content = File(file).readAsStringSync();
    if (!content.contains("import 'package:goat_tracker/services/service.dart'")) {
      final newContent = content.replaceFirst(
        RegExp(r'(import[^;]+;[\r\n]+)'),
        r"$1import 'package:goat_tracker/services/service.dart';\n"
      );
      File(file).writeAsStringSync(newContent);
      print('Updated $file');
    }
  }
}

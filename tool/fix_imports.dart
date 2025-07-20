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
    final fullPath = 'C:/Users/baseerahmed/Desktop/flutt/goat_tracker/$file';
    if (File(fullPath).existsSync()) {
      var content = File(fullPath).readAsStringSync();
      // Remove incorrect imports
      content = content.replaceAll(r'$1import', 'import');
      
      // Add correct import if not present
      if (!content.contains("import 'package:goat_tracker/services/service.dart'")) {
        content = "import 'package:goat_tracker/services/service.dart';\n" + content;
      }
      
      // Add Flutter material import if missing
      if (!content.contains("import 'package:flutter/material.dart'")) {
        content = "import 'package:flutter/material.dart';\n" + content;
      }
      
      File(fullPath).writeAsStringSync(content);
      print('Updated $file');
    }
  }
}

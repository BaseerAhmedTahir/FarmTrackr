import 'dart:io';

void main() {
  final Map<String, List<String>> fileImports = {
    'lib/screens/goats/add_goat.dart': [
      "import 'package:flutter_riverpod/flutter_riverpod.dart'",
      "import 'dart:io'"
    ],
    'lib/screens/goats/weight_chart.dart': [
      "import 'package:fl_chart/fl_chart.dart'",
    ],
    'lib/services/report_service.dart': [
      "import 'dart:io'",
    ]
  };

  for (final entry in fileImports.entries) {
    final file = entry.key;
    final imports = entry.value;
    final fullPath = 'C:/Users/baseerahmed/Desktop/flutt/goat_tracker/$file';
    
    if (File(fullPath).existsSync()) {
      var content = File(fullPath).readAsStringSync();
      
      for (final imp in imports) {
        if (!content.contains(imp)) {
          content = '$imp;\n$content';
        }
      }
      
      File(fullPath).writeAsStringSync(content);
      print('Updated $file');
    }
  }
}

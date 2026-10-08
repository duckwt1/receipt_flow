import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class BudgetStorageService {
  static const _filename = 'budget.txt';

  Future<double> loadBudget() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(docDir.path, _filename));
      if (await file.exists()) {
        final content = await file.readAsString();
        final parsed = double.tryParse(content.trim());
        if (parsed != null && parsed >= 0) {
          return parsed;
        }
      }
    } catch (_) {
      // Fallback to default budget if storage is not available (e.g., in unit tests)
    }
    return 5000000.0;
  }

  Future<void> saveBudget(double budget) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final file = File(path.join(docDir.path, _filename));
      await file.writeAsString(budget.toString());
    } catch (_) {
      // Ignore storage errors in test environments
    }
  }
}

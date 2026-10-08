import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../ui/features/dashboard/view_models/dashboard_view_model.dart';
import '../../ui/features/expenses/view_models/expenses_view_model.dart';
import '../../ui/features/expenses/view_models/expense_editor_view_model.dart';
import '../../ui/features/reports/view_models/reports_view_model.dart';
import '../../ui/features/scan_receipt/view_models/receipt_review_view_model.dart';
import '../../ui/features/scan_receipt/view_models/scan_receipt_view_model.dart';

import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/receipt_repository_impl.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/database/sqlite_database_service.dart';
import '../../data/services/camera/receipt_camera_service.dart';
import '../../data/services/ocr/mlkit_ocr_service.dart';
import '../../data/services/storage/receipt_storage_service.dart';
import '../../data/services/storage/receipt_image_picker_service.dart';
import '../../data/services/storage/budget_storage_service.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../../domain/repositories/receipt_image_picker_repository.dart';
import '../../domain/use_cases/parse_receipt_use_case.dart';
import '../../domain/use_cases/aggregate_expenses_use_case.dart';

final databaseServiceProvider = Provider<DatabaseService>(
  (ref) => SqliteDatabaseService(),
);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final budgetStorageServiceProvider = Provider<BudgetStorageService>(
  (ref) => BudgetStorageService(),
);

class MonthlyBudgetNotifier extends StateNotifier<double> {
  MonthlyBudgetNotifier(this._storage) : super(5000000.0) {
    _load();
  }

  final BudgetStorageService _storage;

  Future<void> _load() async {
    final saved = await _storage.loadBudget();
    state = saved;
  }

  Future<void> setBudget(double newBudget) async {
    state = newBudget;
    await _storage.saveBudget(newBudget);
  }
}

final monthlyBudgetProvider = StateNotifierProvider<MonthlyBudgetNotifier, double>((ref) {
  return MonthlyBudgetNotifier(ref.watch(budgetStorageServiceProvider));
});

final receiptStorageServiceProvider = Provider<ReceiptStorageService>(
  (ref) => ReceiptStorageService(),
);

final receiptImagePickerServiceProvider = Provider<ReceiptImagePickerRepository>(
  (ref) => ReceiptImagePickerService(),
);

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepositoryImpl(ref.watch(receiptStorageServiceProvider));
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepositoryImpl(
    ref.watch(databaseServiceProvider),
    ref.watch(receiptRepositoryProvider),
  );
});

final ocrServiceProvider = Provider.autoDispose<MlkitOcrService>((ref) {
  final service = MlkitOcrService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final parseReceiptUseCaseProvider = Provider<ParseReceiptUseCase>(
  (ref) => const ParseReceiptUseCase(),
);

final receiptCameraServiceProvider = Provider.autoDispose<ReceiptCameraService>((ref) {
  final service = ReceiptCameraService();
  ref.onDispose(() => unawaited(service.dispose()));
  return service;
});

final dashboardViewModelProvider = ChangeNotifierProvider.autoDispose((ref) {
  return DashboardViewModel(
    ref.watch(expenseRepositoryProvider),
    const AggregateExpensesUseCase(),
  );
});

final expensesViewModelProvider = ChangeNotifierProvider.autoDispose((ref) {
  return ExpensesViewModel(ref.watch(expenseRepositoryProvider));
});

final expenseEditorViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<ExpenseEditorViewModel, int?>((ref, id) {
  return ExpenseEditorViewModel(
    ref.watch(expenseRepositoryProvider),
    id,
    ref.watch(receiptRepositoryProvider),
    ref.watch(receiptImagePickerServiceProvider),
  );
});

final reportsViewModelProvider = ChangeNotifierProvider.autoDispose((ref) {
  return ReportsViewModel(
    ref.watch(expenseRepositoryProvider),
    const AggregateExpensesUseCase(),
  );
});

final receiptReviewViewModelProvider = ChangeNotifierProvider.autoDispose((ref) {
  return ReceiptReviewViewModel(ref.watch(expenseRepositoryProvider));
});

final scanReceiptViewModelProvider = ChangeNotifierProvider.autoDispose((ref) {
  return ScanReceiptViewModel(
    cameraService: ref.watch(receiptCameraServiceProvider),
    ocrService: ref.watch(ocrServiceProvider),
    parseReceipt: ref.watch(parseReceiptUseCaseProvider),
    receiptRepository: ref.watch(receiptRepositoryProvider),
    imagePicker: ref.watch(receiptImagePickerServiceProvider),
  );
});

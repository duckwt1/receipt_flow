import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:receipt_flow/app/app.dart';
import 'package:receipt_flow/app/providers/app_providers.dart';
import 'package:receipt_flow/domain/models/expense.dart';
import 'package:receipt_flow/domain/models/expense_category.dart';
import 'package:receipt_flow/domain/models/parsed_receipt.dart';
import 'package:receipt_flow/domain/repositories/expense_repository.dart';
import 'package:receipt_flow/domain/repositories/receipt_repository.dart';
import 'package:receipt_flow/domain/use_cases/parse_receipt_use_case.dart';
import 'package:receipt_flow/data/services/camera/receipt_camera_service.dart';
import 'package:receipt_flow/data/services/ocr/ocr_service.dart';
import 'package:receipt_flow/data/services/storage/receipt_image_picker_service.dart';
import 'package:receipt_flow/ui/features/scan_receipt/view_models/scan_receipt_view_model.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('manual expense appears in the expense list', (tester) async {
    final repository = _InMemoryExpenseRepository();
    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(repository)],
      child: const ReceiptFlowApp(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add expense'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Corner Store');
    await tester.enterText(find.byType(TextField).at(1), '125000');
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('Corner Store'), findsOneWidget);
    expect(repository.items, hasLength(1));
  });

  testWidgets('scan review save adds the reviewed receipt to expenses', (tester) async {
    final repository = _InMemoryExpenseRepository();
    final directory = await Directory.systemTemp.createTemp('receipt-flow-integration-');
    final image = File('${directory.path}${Platform.pathSeparator}receipt.png');
    await image.writeAsBytes(_onePixelPng);
    addTearDown(() async => directory.delete(recursive: true));
    final scanViewModel = _FakeScanReceiptViewModel(
      imagePath: image.path,
      receiptRepository: _ReceiptRepository(),
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(repository),
        scanReceiptViewModelProvider.overrideWith((ref) => scanViewModel),
      ],
      child: const ReceiptFlowApp(),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan receipt'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Choose from gallery'));
    await tester.pumpAndSettle();
    expect(find.text('Review receipt'), findsOneWidget);
    await tester.tap(find.text('Save expense'));
    await tester.pumpAndSettle();

    expect(find.text('FRESH MART'), findsOneWidget);
    expect(repository.items, hasLength(1));
  });
}

const _onePixelPng = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 82,
  0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
  0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 2, 0, 0,
  5, 0, 1, 167, 90, 43, 255, 0, 0, 0, 0, 73, 69, 78, 68, 174,
  66, 96, 130,
];

class _FakeScanReceiptViewModel extends ScanReceiptViewModel {
  _FakeScanReceiptViewModel({required this.imagePath, required super.receiptRepository})
      : super(
          cameraService: ReceiptCameraService(),
          ocrService: _FakeOcrService(),
          parseReceipt: const ParseReceiptUseCase(),
          imagePicker: ReceiptImagePickerService(),
        );

  final String imagePath;

  @override
  Future<void> initializeCamera() async {}

  @override
  Future<void> chooseFromGallery() async {
    state = ScanReceiptState(
      imagePath: imagePath,
      receipt: ParsedReceipt(
        merchantName: 'FRESH MART',
        totalAmount: 120000,
        transactionDate: DateTime(2026, 10, 8),
        rawText: 'FRESH MART\nTOTAL 120000',
        merchantConfidence: 0.9,
        amountConfidence: 0.9,
        dateConfidence: 0.9,
      ),
    );
    notifyListeners();
  }
}

class _FakeOcrService implements OcrService {
  @override
  Future<String> recognizeText(String imagePath) async => 'FRESH MART\nTOTAL 120000';
  @override
  Future<void> dispose() async {}
}

class _ReceiptRepository implements ReceiptRepository {
  @override
  Future<String> storeReceipt(String sourcePath) async => sourcePath;
  @override
  Future<bool> deleteReceipt(String path) async => true;
  @override
  Future<bool> receiptExists(String path) async => true;
}

class _InMemoryExpenseRepository implements ExpenseRepository {
  final List<Expense> items = [];
  var _nextId = 1;

  @override
  Future<List<Expense>> getExpenses() async => List.unmodifiable(items);
  @override
  Future<Expense?> getExpenseById(int id) async {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }
  @override
  Future<int> insertExpense(Expense expense) async {
    final id = _nextId++;
    items.add(expense.copyWith(id: id));
    return id;
  }
  @override
  Future<void> updateExpense(Expense expense) async {
    final index = items.indexWhere((item) => item.id == expense.id);
    if (index >= 0) items[index] = expense;
  }
  @override
  Future<void> deleteExpense(int id) async => items.removeWhere((item) => item.id == id);
  @override
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async => items.where((e) => e.category == category).toList();
  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async => items.where((e) => !e.expenseDate.isBefore(start) && !e.expenseDate.isAfter(end)).toList();
}

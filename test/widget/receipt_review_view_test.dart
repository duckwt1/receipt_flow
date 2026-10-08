import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_flow/app/providers/app_providers.dart';
import 'package:receipt_flow/domain/models/expense.dart';
import 'package:receipt_flow/domain/models/expense_category.dart';
import 'package:receipt_flow/domain/models/parsed_receipt.dart';
import 'package:receipt_flow/domain/repositories/expense_repository.dart';
import 'package:receipt_flow/ui/features/expenses/views/expenses_view.dart';
import 'package:receipt_flow/ui/features/scan_receipt/views/receipt_review_view.dart';
import 'package:receipt_flow/ui/features/scan_receipt/views/scan_receipt_view.dart';

void main() {
  testWidgets('review shows editable OCR values and a low confidence prompt', (tester) async {
    final directory = Directory.systemTemp.createTempSync('receipt-flow-test-');
    final image = File('${directory.path}${Platform.pathSeparator}receipt.png');
    image.writeAsBytesSync(_onePixelPng);
    addTearDown(() => directory.deleteSync(recursive: true));
    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepository())],
      child: MaterialApp(
        home: ReceiptReviewView(
          result: ScanResult(
            imagePath: image.path,
            receipt: const ParsedReceipt(
              rawText: 'CAFE\nTOTAL 45000',
              merchantName: 'CAFE',
              totalAmount: 45000,
              merchantConfidence: 0.4,
              amountConfidence: 0.95,
              dateConfidence: 0.6,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Kiểm tra hóa đơn'), findsOneWidget);
    expect(find.text('Độ tin cậy thấp — vui lòng kiểm tra lại'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lưu chi tiêu'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lưu chi tiêu'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });

  testWidgets('ReceiptReviewView does not overflow on narrow 320dp screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final directory = Directory.systemTemp.createTempSync('receipt-flow-narrow-');
    final image = File('${directory.path}${Platform.pathSeparator}receipt.png');
    image.writeAsBytesSync(_onePixelPng);
    addTearDown(() => directory.deleteSync(recursive: true));

    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepository())],
      child: MaterialApp(
        home: ReceiptReviewView(
          result: ScanResult(
            imagePath: image.path,
            receipt: const ParsedReceipt(
              rawText: 'CAFE\nTOTAL 45000',
              merchantName: 'CAFE',
              totalAmount: 45000,
              merchantConfidence: 0.3,
              amountConfidence: 0.95,
              dateConfidence: 0.5,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Kiểm tra hóa đơn'), findsOneWidget);
    expect(find.text('Độ tin cậy thấp — vui lòng kiểm tra lại'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExpenseEditorView does not overflow on narrow 320dp screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepository())],
      child: const MaterialApp(
        home: ExpenseEditorView(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Thêm chi tiêu'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Đính kèm ảnh hóa đơn (tùy chọn)'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Đính kèm ảnh hóa đơn (tùy chọn)'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ExpenseDetailView provides Về trang chủ navigation button', (tester) async {
    final now = DateTime.now();
    final expense = Expense(
      id: 1,
      merchantName: 'Siêu thị Co.opmart',
      amount: 120000,
      expenseDate: now,
      category: ExpenseCategory.food,
      createdAt: now,
      updatedAt: now,
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        expenseRepositoryProvider.overrideWithValue(_FakeExpenseRepositoryWithData(expense)),
      ],
      child: const MaterialApp(
        home: ExpenseDetailView(expenseId: 1),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('GIAO DỊCH HOÀN TẤT'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Xem danh sách giao dịch'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Về trang chủ'), findsWidgets);
    expect(find.text('Xem danh sách giao dịch'), findsOneWidget);
  });
}

class _FakeExpenseRepositoryWithData extends _FakeExpenseRepository {
  _FakeExpenseRepositoryWithData(this.expense);
  final Expense expense;
  @override
  Future<Expense?> getExpenseById(int id) async => expense;
}

const _onePixelPng = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82,
  0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137,
  0, 0, 0, 11, 73, 68, 65, 84, 120, 156, 99, 96, 0, 2, 0, 0,
  5, 0, 1, 167, 90, 43, 255, 0, 0, 0, 0, 73, 69, 78, 68, 174,
  66, 96, 130,
];

class _FakeExpenseRepository implements ExpenseRepository {
  @override
  Future<List<Expense>> getExpenses() async => const [];
  @override
  Future<Expense?> getExpenseById(int id) async => null;
  @override
  Future<int> insertExpense(Expense expense) async => 1;
  @override
  Future<void> updateExpense(Expense expense) async {}
  @override
  Future<void> deleteExpense(int id) async {}
  @override
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async => const [];
  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async => const [];
}

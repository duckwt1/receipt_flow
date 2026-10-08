import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_flow/app/app.dart';
import 'package:receipt_flow/app/providers/app_providers.dart';
import 'package:receipt_flow/ui/features/expenses/views/expenses_view.dart';
import 'package:receipt_flow/domain/models/expense.dart';
import 'package:receipt_flow/domain/models/expense_category.dart';
import 'package:receipt_flow/domain/repositories/expense_repository.dart';

void main() {
  testWidgets('dashboard shows its empty state when there are no expenses', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_EmptyExpenseRepository())],
      child: const ReceiptFlowApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Ngân sách'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Chưa có khoản chi nào'), 200);
    expect(find.text('Chưa có khoản chi nào'), findsOneWidget);
  });

  testWidgets('expense list shows its empty state', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_EmptyExpenseRepository())],
      child: const MaterialApp(home: ExpensesView()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Không tìm thấy giao dịch nào'), findsOneWidget);
  });

  testWidgets('dashboard shows a recovery action when loading fails', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_FailingExpenseRepository())],
      child: const ReceiptFlowApp(),
    ));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.textContaining('Không thể tải dữ liệu chi tiêu'),
      200,
    );
    expect(find.textContaining('Không thể tải dữ liệu chi tiêu'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('tapping set budget opens dialog and updates monthly budget', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [expenseRepositoryProvider.overrideWithValue(_EmptyExpenseRepository())],
      child: const ReceiptFlowApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Đặt ngân sách'), findsOneWidget);
    await tester.tap(find.text('Đặt ngân sách'));
    await tester.pumpAndSettle();

    expect(find.text('Thiết lập ngân sách'), findsOneWidget);
    expect(find.text('Lưu ngân sách'), findsOneWidget);

    // Tap quick preset 10.000.000 ₫
    await tester.tap(find.text('10.000.000 ₫'));
    await tester.pumpAndSettle();

    // Tap Lưu ngân sách
    await tester.tap(find.text('Lưu ngân sách'));
    await tester.pumpAndSettle();

    expect(find.text('Quỹ: 10.000.000 ₫ (0%)'), findsOneWidget);
  });
}

class _FailingExpenseRepository extends _EmptyExpenseRepository {
  @override
  Future<List<Expense>> getExpenses() async => throw Exception('storage unavailable');
}

class _EmptyExpenseRepository implements ExpenseRepository {
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

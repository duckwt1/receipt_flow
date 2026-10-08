import 'package:flutter_test/flutter_test.dart';
import 'package:receipt_flow/domain/models/expense.dart';
import 'package:receipt_flow/domain/models/expense_category.dart';
import 'package:receipt_flow/domain/use_cases/aggregate_expenses_use_case.dart';

void main() {
  const aggregate = AggregateExpensesUseCase();
  final now = DateTime(2026, 10, 8, 12);
  final expenses = [
    _expense(100, ExpenseCategory.food, DateTime(2026, 10, 5, 10)),
    _expense(250, ExpenseCategory.travel, DateTime(2026, 10, 8, 9)),
    _expense(75, ExpenseCategory.food, DateTime(2026, 9, 28)),
  ];

  test('aggregates monthly and category totals', () {
    final result = aggregate(expenses, now);
    expect(result.monthlyTotal, 350);
    expect(result.categoryTotals[ExpenseCategory.food], 100);
    expect(result.categoryTotals[ExpenseCategory.travel], 250);
  });

  test('aggregates current Monday-to-Sunday spending', () {
    final result = aggregate(expenses, now);
    expect(result.weeklyTotals[0], 100);
    expect(result.weeklyTotals[3], 250);
    expect(result.weeklyTotals.fold<double>(0, (sum, value) => sum + value), 350);
    expect(result.weekStart, DateTime(2026, 10, 5));
    expect(result.weekEnd, DateTime(2026, 10, 11));
  });

  test('aggregates historical month week by latest expense in that month', () {
    final result = aggregate(expenses, DateTime(2026, 9, 1));
    expect(result.monthlyTotal, 75);
    // Sept 28 was Monday -> index 0
    expect(result.weeklyTotals[0], 75);
    expect(result.weekStart, DateTime(2026, 9, 28));
  });
}

Expense _expense(double amount, ExpenseCategory category, DateTime date) => Expense(
  merchantName: 'Shop', amount: amount, expenseDate: date, category: category,
  createdAt: date, updatedAt: date,
);

import '../models/expense.dart';
import '../models/expense_category.dart';

class SpendingSummary {
  const SpendingSummary({
    required this.monthlyTotal,
    required this.categoryTotals,
    required this.weeklyTotals,
    this.weekStart,
    this.weekEnd,
  });

  final double monthlyTotal;
  final Map<ExpenseCategory, double> categoryTotals;
  final List<double> weeklyTotals;
  final DateTime? weekStart;
  final DateTime? weekEnd;
}

class AggregateExpensesUseCase {
  const AggregateExpensesUseCase();

  SpendingSummary call(List<Expense> expenses, DateTime referenceDate) {
    final monthly = expenses.where((expense) =>
        expense.expenseDate.year == referenceDate.year &&
        expense.expenseDate.month == referenceDate.month);
    final categories = <ExpenseCategory, double>{};
    var monthlyTotal = 0.0;
    for (final expense in monthly) {
      monthlyTotal += expense.amount;
      categories.update(expense.category, (total) => total + expense.amount,
          ifAbsent: () => expense.amount);
    }

    final now = DateTime.now();
    final DateTime weekAnchor;
    if (referenceDate.day > 1) {
      weekAnchor = referenceDate;
    } else if (referenceDate.year == now.year && referenceDate.month == now.month) {
      weekAnchor = now;
    } else {
      final inMonth = expenses.where((e) =>
          e.expenseDate.year == referenceDate.year &&
          e.expenseDate.month == referenceDate.month).toList();
      if (inMonth.isNotEmpty) {
        weekAnchor = inMonth.reduce((a, b) => a.expenseDate.isAfter(b.expenseDate) ? a : b).expenseDate;
      } else {
        weekAnchor = referenceDate;
      }
    }

    final today = DateTime(weekAnchor.year, weekAnchor.month, weekAnchor.day);
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final sunday = DateTime(monday.year, monday.month, monday.day + 6);
    final weekly = List<double>.filled(7, 0);
    for (final expense in expenses) {
      final day = DateTime(expense.expenseDate.year, expense.expenseDate.month, expense.expenseDate.day);
      final diff = DateTime.utc(day.year, day.month, day.day)
          .difference(DateTime.utc(monday.year, monday.month, monday.day))
          .inDays;
      if (diff >= 0 && diff < weekly.length) {
        weekly[diff] += expense.amount;
      }
    }
    return SpendingSummary(
      monthlyTotal: monthlyTotal,
      categoryTotals: Map.unmodifiable(categories),
      weeklyTotals: List.unmodifiable(weekly),
      weekStart: monday,
      weekEnd: sunday,
    );
  }
}

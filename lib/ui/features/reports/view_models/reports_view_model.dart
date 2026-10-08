import 'package:flutter/foundation.dart';

import '../../../../domain/models/expense.dart';
import '../../../../domain/repositories/expense_repository.dart';
import '../../../../domain/use_cases/aggregate_expenses_use_case.dart';

class ReportsState {
  const ReportsState({
    this.isLoading = false,
    this.expenses = const [],
    this.summary,
    this.selectedMonth,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Expense> expenses;
  final SpendingSummary? summary;
  final DateTime? selectedMonth;
  final String? errorMessage;
}

class ReportsViewModel extends ChangeNotifier {
  ReportsViewModel(this._repository, this._aggregateExpenses);

  final ExpenseRepository _repository;
  final AggregateExpensesUseCase _aggregateExpenses;
  ReportsState state = const ReportsState();
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  Future<void> load({DateTime? month}) async {
    final targetMonth = month ?? _currentMonth;
    _currentMonth = targetMonth;
    state = ReportsState(
      isLoading: true,
      expenses: state.expenses,
      summary: state.summary,
      selectedMonth: targetMonth,
    );
    notifyListeners();
    try {
      final expenses = await _repository.getExpenses();
      DateTime effectiveMonth = targetMonth;
      if (month == null && expenses.isNotEmpty) {
        final hasExpensesInTarget = expenses.any((e) =>
            e.expenseDate.year == targetMonth.year &&
            e.expenseDate.month == targetMonth.month);
        if (!hasExpensesInTarget) {
          final latestExpense = expenses.reduce((a, b) =>
              a.expenseDate.isAfter(b.expenseDate) ? a : b);
          effectiveMonth = DateTime(
              latestExpense.expenseDate.year, latestExpense.expenseDate.month);
          _currentMonth = effectiveMonth;
        }
      }
      state = ReportsState(
        expenses: expenses,
        selectedMonth: effectiveMonth,
        summary: _aggregateExpenses(expenses, effectiveMonth),
      );
    } on Exception catch (error) {
      state = ReportsState(
        errorMessage: 'Không thể tải báo cáo thống kê: $error',
        selectedMonth: _currentMonth,
      );
    }
    notifyListeners();
  }

  void previousMonth() {
    final prev = DateTime(_currentMonth.year, _currentMonth.month - 1);
    load(month: prev);
  }

  void nextMonth() {
    final next = DateTime(_currentMonth.year, _currentMonth.month + 1);
    load(month: next);
  }

  void selectMonth(DateTime month) {
    load(month: DateTime(month.year, month.month));
  }
}

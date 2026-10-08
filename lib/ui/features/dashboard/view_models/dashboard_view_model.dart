import 'package:flutter/foundation.dart';

import '../../../../domain/models/expense.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../../domain/repositories/expense_repository.dart';
import '../../../../domain/use_cases/aggregate_expenses_use_case.dart';

class DashboardState {
  const DashboardState({
    this.isLoading = false,
    this.monthlyTotal = 0,
    this.categoryTotals = const {},
    this.recentExpenses = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final double monthlyTotal;
  final Map<ExpenseCategory, double> categoryTotals;
  final List<Expense> recentExpenses;
  final String? errorMessage;
}

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._repository, this._aggregateExpenses);
  final ExpenseRepository _repository;
  final AggregateExpensesUseCase _aggregateExpenses;
  DashboardState state = const DashboardState();

  Future<void> load() async {
    state = const DashboardState(isLoading: true);
    notifyListeners();
    try {
      final expenses = await _repository.getExpenses();
      final summary = _aggregateExpenses(expenses, DateTime.now());
      state = DashboardState(
        monthlyTotal: summary.monthlyTotal,
        categoryTotals: summary.categoryTotals,
        recentExpenses: expenses.take(5).toList(growable: false),
      );
    } on Exception catch (error) {
      state = DashboardState(errorMessage: 'Không thể tải dữ liệu chi tiêu: $error');
    }
    notifyListeners();
  }
}

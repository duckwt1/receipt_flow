import 'package:flutter/foundation.dart';

import '../../../../domain/models/expense.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../../domain/repositories/expense_repository.dart';

class ExpensesState {
  const ExpensesState({
    this.isLoading = false,
    this.expenses = const [],
    this.searchQuery = '',
    this.category,
    this.startDate,
    this.endDate,
    this.errorMessage,
  });

  final bool isLoading;
  final List<Expense> expenses;
  final String searchQuery;
  final ExpenseCategory? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? errorMessage;
}

class ExpensesViewModel extends ChangeNotifier {
  ExpensesViewModel(this._repository);

  final ExpenseRepository _repository;
  ExpensesState state = const ExpensesState();
  List<Expense> _allExpenses = const [];

  Future<void> load() async {
    state = ExpensesState(isLoading: true, searchQuery: state.searchQuery, category: state.category, startDate: state.startDate, endDate: state.endDate);
    notifyListeners();
    try {
      _allExpenses = await _repository.getExpenses();
      _filter();
    } on Exception catch (error) {
      state = ExpensesState(errorMessage: 'Không thể tải danh sách chi tiêu: $error');
      notifyListeners();
    }
  }

  void search(String query) {
    state = ExpensesState(searchQuery: query, category: state.category, startDate: state.startDate, endDate: state.endDate);
    _filter();
  }

  void filterCategory(ExpenseCategory? category) {
    state = ExpensesState(searchQuery: state.searchQuery, category: category, startDate: state.startDate, endDate: state.endDate);
    _filter();
  }

  void filterDateRange(DateTime? start, DateTime? end) {
    state = ExpensesState(searchQuery: state.searchQuery, category: state.category, startDate: start, endDate: end);
    _filter();
  }

  Future<void> delete(int id) async {
    try {
      await _repository.deleteExpense(id);
      _allExpenses = _allExpenses.where((expense) => expense.id != id).toList();
      _filter();
    } on Exception catch (error) {
      state = ExpensesState(
        expenses: state.expenses,
        searchQuery: state.searchQuery,
        category: state.category,
        startDate: state.startDate,
        endDate: state.endDate,
        errorMessage: 'Không thể xóa khoản chi này: $error',
      );
      notifyListeners();
    }
  }

  void _filter() {
    final query = state.searchQuery.toLowerCase().trim();
    final filtered = _allExpenses.where((expense) {
      final matchesQuery = query.isEmpty || expense.merchantName.toLowerCase().contains(query);
      final matchesCategory = state.category == null || expense.category == state.category;
      final day = DateTime(expense.expenseDate.year, expense.expenseDate.month, expense.expenseDate.day);
      final matchesDate = (state.startDate == null || !day.isBefore(state.startDate!)) &&
          (state.endDate == null || !day.isAfter(state.endDate!));
      return matchesQuery && matchesCategory && matchesDate;
    }).toList(growable: false);
    state = ExpensesState(
      expenses: filtered,
      searchQuery: state.searchQuery,
      category: state.category,
      startDate: state.startDate,
      endDate: state.endDate,
    );
    notifyListeners();
  }
}

import '../models/expense.dart';
import '../models/expense_category.dart';

abstract interface class ExpenseRepository {
  Future<List<Expense>> getExpenses();

  Future<Expense?> getExpenseById(int id);

  Future<int> insertExpense(Expense expense);

  Future<void> updateExpense(Expense expense);

  Future<void> deleteExpense(int id);

  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category);

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end);
}

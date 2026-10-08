import '../../../domain/models/expense_category.dart';

abstract interface class DatabaseService {
  Future<int> insertExpense(Map<String, Object?> values);

  Future<List<Map<String, Object?>>> getExpenses();

  Future<Map<String, Object?>?> getExpenseById(int id);

  Future<int> updateExpense(int id, Map<String, Object?> values);

  Future<int> deleteExpense(int id);

  Future<List<Map<String, Object?>>> getExpensesByCategory(
    ExpenseCategory category,
  );

  Future<List<Map<String, Object?>>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  );
}

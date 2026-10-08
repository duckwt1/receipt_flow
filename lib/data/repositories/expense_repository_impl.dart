import '../../domain/models/expense.dart';
import '../../domain/models/expense_category.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/receipt_repository.dart';
import '../models/expense_model.dart';
import '../services/database/database_service.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  const ExpenseRepositoryImpl(this._databaseService, this._receiptRepository);

  final DatabaseService _databaseService;
  final ReceiptRepository _receiptRepository;

  @override
  Future<List<Expense>> getExpenses() async {
    final rows = await _databaseService.getExpenses();
    return rows.map(ExpenseModel.fromMap).toList(growable: false);
  }

  @override
  Future<Expense?> getExpenseById(int id) async {
    final row = await _databaseService.getExpenseById(id);
    return row == null ? null : ExpenseModel.fromMap(row);
  }

  @override
  Future<int> insertExpense(Expense expense) {
    return _databaseService.insertExpense(ExpenseModel.toMap(expense));
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final id = expense.id;
    if (id == null) {
      throw ArgumentError.value(id, 'expense.id', 'An id is required to update an expense.');
    }
    await _databaseService.updateExpense(id, ExpenseModel.toMap(expense));
  }

  @override
  Future<void> deleteExpense(int id) async {
    final expense = await getExpenseById(id);
    if (expense == null) return;

    await _databaseService.deleteExpense(id);
    final receiptPath = expense.receiptImagePath;
    if (receiptPath != null) {
      // The expense is already removed; a failed file cleanup leaves only an orphan file.
      await _receiptRepository.deleteReceipt(receiptPath);
    }
  }

  @override
  Future<List<Expense>> getExpensesByCategory(ExpenseCategory category) async {
    final rows = await _databaseService.getExpensesByCategory(category);
    return rows.map(ExpenseModel.fromMap).toList(growable: false);
  }

  @override
  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    if (end.isBefore(start)) {
      throw ArgumentError.value(end, 'end', 'End date must not precede start date.');
    }
    final rows = await _databaseService.getExpensesByDateRange(start, end);
    return rows.map(ExpenseModel.fromMap).toList(growable: false);
  }
}

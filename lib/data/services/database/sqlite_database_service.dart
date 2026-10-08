import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../../../domain/models/expense_category.dart';
import '../../models/expense_model.dart';
import 'database_service.dart';

class SqliteDatabaseService implements DatabaseService {
  static const _databaseName = 'receipt_flow.db';
  static const _databaseVersion = 1;

  Future<Database>? _databaseFuture;

  Future<Database> get _database async {
    try {
      return await (_databaseFuture ??= _openDatabase());
    } on Object catch (error, stackTrace) {
      _databaseFuture = null;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<Database> _openDatabase() async {
    final databasePath = path.join(await getDatabasesPath(), _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (database, version) async {
        await database.execute('''
          CREATE TABLE ${ExpenseModel.tableName} (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            merchant_name TEXT NOT NULL,
            amount REAL NOT NULL CHECK (amount >= 0),
            expense_date TEXT NOT NULL,
            category TEXT NOT NULL,
            receipt_image_path TEXT,
            raw_ocr_text TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL
          )
        ''');
        await database.execute(
          'CREATE INDEX expenses_expense_date_idx '
          'ON ${ExpenseModel.tableName} (expense_date)',
        );
        await database.execute(
          'CREATE INDEX expenses_category_idx '
          'ON ${ExpenseModel.tableName} (category)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        // Add forward-only schema migrations here as _databaseVersion grows.
      },
    );
  }

  @override
  Future<int> insertExpense(Map<String, Object?> values) async {
    return (await _database).insert(ExpenseModel.tableName, values);
  }

  @override
  Future<List<Map<String, Object?>>> getExpenses() async {
    return (await _database).query(
      ExpenseModel.tableName,
      orderBy: 'expense_date DESC, id DESC',
    );
  }

  @override
  Future<Map<String, Object?>?> getExpenseById(int id) async {
    final rows = await (await _database).query(
      ExpenseModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.single;
  }

  @override
  Future<int> updateExpense(int id, Map<String, Object?> values) async {
    return (await _database).update(
      ExpenseModel.tableName,
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<int> deleteExpense(int id) async {
    return (await _database).delete(
      ExpenseModel.tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<Map<String, Object?>>> getExpensesByCategory(
    ExpenseCategory category,
  ) async {
    return (await _database).query(
      ExpenseModel.tableName,
      where: 'category = ?',
      whereArgs: [category.name],
      orderBy: 'expense_date DESC, id DESC',
    );
  }

  @override
  Future<List<Map<String, Object?>>> getExpensesByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return (await _database).query(
      ExpenseModel.tableName,
      where: 'expense_date >= ? AND expense_date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'expense_date DESC, id DESC',
    );
  }
}

import '../../domain/models/expense.dart';
import '../../domain/models/expense_category.dart';

class ExpenseModel {
  const ExpenseModel._();

  static const tableName = 'expenses';

  static Expense fromMap(Map<String, Object?> map) {
    return Expense(
      id: map['id'] as int?,
      merchantName: map['merchant_name'] as String,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(map['expense_date'] as String),
      category: ExpenseCategory.values.byName(map['category'] as String),
      receiptImagePath: map['receipt_image_path'] as String?,
      rawOcrText: map['raw_ocr_text'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  static Map<String, Object?> toMap(Expense expense, {bool includeId = false}) {
    return {
      if (includeId && expense.id != null) 'id': expense.id,
      'merchant_name': expense.merchantName,
      'amount': expense.amount,
      'expense_date': expense.expenseDate.toIso8601String(),
      'category': expense.category.name,
      'receipt_image_path': expense.receiptImagePath,
      'raw_ocr_text': expense.rawOcrText,
      'created_at': expense.createdAt.toIso8601String(),
      'updated_at': expense.updatedAt.toIso8601String(),
    };
  }
}

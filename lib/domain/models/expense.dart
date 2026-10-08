import 'expense_category.dart';

class Expense {
  const Expense({
    this.id,
    required this.merchantName,
    required this.amount,
    required this.expenseDate,
    required this.category,
    this.receiptImagePath,
    this.rawOcrText,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String merchantName;
  final double amount;
  final DateTime expenseDate;
  final ExpenseCategory category;
  final String? receiptImagePath;
  final String? rawOcrText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense copyWith({
    int? id,
    String? merchantName,
    double? amount,
    DateTime? expenseDate,
    ExpenseCategory? category,
    String? receiptImagePath,
    bool clearReceiptImagePath = false,
    String? rawOcrText,
    bool clearRawOcrText = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      merchantName: merchantName ?? this.merchantName,
      amount: amount ?? this.amount,
      expenseDate: expenseDate ?? this.expenseDate,
      category: category ?? this.category,
      receiptImagePath: clearReceiptImagePath
          ? null
          : receiptImagePath ?? this.receiptImagePath,
      rawOcrText: clearRawOcrText ? null : rawOcrText ?? this.rawOcrText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

import 'package:flutter/foundation.dart';

import '../../../../domain/models/expense.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../../domain/models/parsed_receipt.dart';
import '../../../../domain/repositories/expense_repository.dart';
import '../../../../domain/utils/money_parser.dart';

class ReceiptReviewState {
  const ReceiptReviewState({this.isSaving = false, this.errorMessage});

  final bool isSaving;
  final String? errorMessage;
}

class ReceiptReviewViewModel extends ChangeNotifier {
  ReceiptReviewViewModel(this._expenseRepository);

  final ExpenseRepository _expenseRepository;
  ReceiptReviewState state = const ReceiptReviewState();

  Future<int?> save({
    required ParsedReceipt receipt,
    required String merchantName,
    required String amount,
    required DateTime expenseDate,
    required ExpenseCategory category,
    required String? receiptImagePath,
  }) async {
    final parsedAmount = MoneyParser.parse(amount);
    if (merchantName.trim().isEmpty || parsedAmount == null || parsedAmount <= 0) {
      state = const ReceiptReviewState(errorMessage: 'Vui lòng nhập nơi bán và số tiền hợp lệ.');
      notifyListeners();
      return null;
    }
    state = const ReceiptReviewState(isSaving: true);
    notifyListeners();
    try {
      final now = DateTime.now();
      final id = await _expenseRepository.insertExpense(Expense(
        merchantName: merchantName.trim(),
        amount: parsedAmount,
        expenseDate: expenseDate,
        category: category,
        receiptImagePath: receiptImagePath,
        rawOcrText: receipt.rawText,
        createdAt: now,
        updatedAt: now,
      ));
      state = const ReceiptReviewState();
      notifyListeners();
      return id;
    } on Exception catch (error) {
      state = ReceiptReviewState(errorMessage: 'Không thể lưu khoản chi này: $error');
      notifyListeners();
      return null;
    }
  }
}

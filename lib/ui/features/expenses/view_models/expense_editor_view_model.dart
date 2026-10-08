import 'package:flutter/foundation.dart';

import '../../../../domain/models/expense.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../../domain/repositories/expense_repository.dart';
import '../../../../domain/repositories/receipt_repository.dart';
import '../../../../domain/repositories/receipt_image_picker_repository.dart';
import '../../../../domain/utils/money_parser.dart';

class ExpenseEditorState {
  const ExpenseEditorState({this.isLoading = false, this.isSaving = false, this.errorMessage});
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
}

class ExpenseEditorViewModel extends ChangeNotifier {
  ExpenseEditorViewModel(this._repository, this.expenseId, this._receiptRepository, this._imagePicker);
  final ExpenseRepository _repository;
  final ReceiptRepository _receiptRepository;
  final ReceiptImagePickerRepository _imagePicker;
  final int? expenseId;
  Expense? expense;
  String? selectedImagePath;
  ExpenseEditorState state = const ExpenseEditorState();

  Future<void> load() async {
    if (expenseId == null) return;
    state = const ExpenseEditorState(isLoading: true);
    notifyListeners();
    try {
      expense = await _repository.getExpenseById(expenseId!);
      state = ExpenseEditorState(errorMessage: expense == null ? 'Khoản chi này không còn tồn tại.' : null);
    } on Exception catch (error) {
      state = ExpenseEditorState(errorMessage: 'Không thể tải khoản chi này: $error');
    }
    notifyListeners();
  }

  Future<bool> save({
    required String merchant,
    required String amount,
    required DateTime date,
    required ExpenseCategory category,
  }) async {
    final value = MoneyParser.parse(amount);
    if (merchant.trim().isEmpty || value == null || value <= 0) {
      state = const ExpenseEditorState(errorMessage: 'Vui lòng nhập nơi bán và số tiền lớn hơn 0.');
      notifyListeners();
      return false;
    }
    state = const ExpenseEditorState(isSaving: true);
    notifyListeners();
    String? storedReceiptPath;
    try {
      final now = DateTime.now();
      final current = expense;
      var receiptPath = current?.receiptImagePath;
      if (selectedImagePath != null) {
        storedReceiptPath = await _receiptRepository.storeReceipt(selectedImagePath!);
        receiptPath = storedReceiptPath;
      }
      if (current == null) {
        await _repository.insertExpense(Expense(
          merchantName: merchant.trim(),
          amount: value,
          expenseDate: date,
          category: category,
          receiptImagePath: receiptPath,
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        await _repository.updateExpense(current.copyWith(
          merchantName: merchant.trim(),
          amount: value,
          expenseDate: date,
          category: category,
          updatedAt: now,
          receiptImagePath: receiptPath,
        ));
      }
      if (selectedImagePath != null && current?.receiptImagePath != null) {
        await _receiptRepository.deleteReceipt(current!.receiptImagePath!);
      }
      state = const ExpenseEditorState();
      notifyListeners();
      return true;
    } on Exception catch (error) {
      if (storedReceiptPath != null) {
        await _receiptRepository.deleteReceipt(storedReceiptPath);
      }
      state = ExpenseEditorState(errorMessage: 'Không thể lưu khoản chi này: $error');
      notifyListeners();
      return false;
    }
  }

  Future<void> selectReceiptImage() async {
    try {
      selectedImagePath = await _imagePicker.pickFromGallery();
      notifyListeners();
    } on Exception catch (error) {
      state = ExpenseEditorState(errorMessage: 'Không thể chọn ảnh hóa đơn: $error');
      notifyListeners();
    }
  }

  Future<bool> delete() async {
    final id = expenseId;
    if (id == null) return false;
    state = const ExpenseEditorState(isSaving: true);
    notifyListeners();
    try {
      await _repository.deleteExpense(id);
      state = const ExpenseEditorState();
      notifyListeners();
      return true;
    } on Exception catch (error) {
      state = ExpenseEditorState(errorMessage: 'Không thể xóa khoản chi này: $error');
      notifyListeners();
      return false;
    }
  }
}

import '../../domain/repositories/receipt_repository.dart';
import '../services/storage/receipt_storage_service.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  const ReceiptRepositoryImpl(this._storageService);

  final ReceiptStorageService _storageService;

  @override
  Future<String> storeReceipt(String sourcePath) {
    return _storageService.storeReceipt(sourcePath);
  }

  @override
  Future<bool> deleteReceipt(String path) {
    return _storageService.deleteReceipt(path);
  }

  @override
  Future<bool> receiptExists(String path) {
    return _storageService.receiptExists(path);
  }
}

abstract interface class ReceiptRepository {
  Future<String> storeReceipt(String sourcePath);

  /// Returns false when the file could not be removed.
  Future<bool> deleteReceipt(String path);

  Future<bool> receiptExists(String path);
}

import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReceiptStorageService {
  static const _directoryName = 'receipts';
  static const _allowedExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  final Random _random = Random.secure();

  Future<String> storeReceipt(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw FileSystemException('Receipt image does not exist', sourcePath);
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final receiptDirectory = Directory(
      path.join(documentsDirectory.path, _directoryName),
    );
    await receiptDirectory.create(recursive: true);

    final extension = path.extension(sourcePath).toLowerCase();
    final safeExtension = _allowedExtensions.contains(extension) ? extension : '.jpg';
    final filename =
        '${DateTime.now().microsecondsSinceEpoch}_${_random.nextInt(1 << 32)}$safeExtension';
    final destination = File(path.join(receiptDirectory.path, filename));
    return (await source.copy(destination.path)).path;
  }

  Future<bool> deleteReceipt(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) await file.delete();
      return true;
    } on FileSystemException {
      return false;
    }
  }

  Future<bool> receiptExists(String filePath) => File(filePath).exists();
}

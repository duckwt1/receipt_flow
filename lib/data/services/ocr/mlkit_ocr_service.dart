import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../../core/errors/app_exception.dart';
import 'ocr_service.dart';

class MlkitOcrService implements OcrService {
  final TextRecognizer _recognizer = TextRecognizer();
  bool _isDisposed = false;

  @override
  Future<String> recognizeText(String imagePath) async {
    if (_isDisposed) throw const OcrException('OCR service has been disposed.');
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final result = await _recognizer.processImage(inputImage);
      return result.text;
    } on Exception catch (error) {
      throw OcrException('On-device text recognition failed.', cause: error);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _recognizer.close();
  }
}

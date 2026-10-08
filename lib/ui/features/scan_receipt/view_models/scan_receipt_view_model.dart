import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/services/camera/receipt_camera_service.dart';
import '../../../../data/services/ocr/ocr_service.dart';
import '../../../../domain/models/parsed_receipt.dart';
import '../../../../domain/repositories/receipt_repository.dart';
import '../../../../domain/use_cases/parse_receipt_use_case.dart';
import '../../../../domain/repositories/receipt_image_picker_repository.dart';

class ScanReceiptState {
  const ScanReceiptState({
    this.isInitializing = false,
    this.isProcessing = false,
    this.imagePath,
    this.receipt,
    this.errorMessage,
    this.flashEnabled = false,
  });

  final bool isInitializing;
  final bool isProcessing;
  final String? imagePath;
  final ParsedReceipt? receipt;
  final String? errorMessage;
  final bool flashEnabled;
}

class ScanReceiptViewModel extends ChangeNotifier {
  ScanReceiptViewModel({
    required this.cameraService,
    required this.ocrService,
    required this.parseReceipt,
    required this.receiptRepository,
    required this.imagePicker,
  });

  final ReceiptCameraService cameraService;
  final OcrService ocrService;
  final ParseReceiptUseCase parseReceipt;
  final ReceiptRepository receiptRepository;
  final ReceiptImagePickerRepository imagePicker;

  ScanReceiptState state = const ScanReceiptState();
  CameraController? get cameraController => cameraService.controller;

  Future<void> initializeCamera() async {
    _setState(const ScanReceiptState(isInitializing: true));
    try {
      await cameraService.initialize();
      _setState(const ScanReceiptState());
    } on Exception catch (error) {
      _setState(ScanReceiptState(errorMessage: 'Không thể khởi động máy ảnh: $error'));
    }
  }

  Future<void> toggleFlash() async {
    try {
      await cameraService.toggleFlash();
      state = ScanReceiptState(flashEnabled: !state.flashEnabled);
      notifyListeners();
    } on Exception catch (error) {
      _setState(ScanReceiptState(errorMessage: 'Không thể điều khiển đèn flash: $error'));
    }
  }

  Future<void> focus(Offset point) async {
    try {
      await cameraService.focus(point);
    } on Exception catch (error) {
      _setState(ScanReceiptState(errorMessage: 'Không thể lấy nét máy ảnh: $error'));
    }
  }

  Future<void> capture() async {
    try {
      await _processImage(await cameraService.capture());
    } on Exception catch (error) {
      _setState(ScanReceiptState(errorMessage: 'Không thể chụp ảnh hóa đơn: $error'));
    }
  }

  Future<void> chooseFromGallery() async {
    try {
      final imagePath = await imagePicker.pickFromGallery();
      if (imagePath != null) await _processImage(imagePath);
    } on Exception catch (error) {
      _setState(ScanReceiptState(errorMessage: 'Không thể mở ảnh đã chọn: $error'));
    }
  }

  Future<void> _processImage(String imagePath) async {
    _setState(ScanReceiptState(isProcessing: true, imagePath: imagePath));
    String? storedPath;
    try {
      final receiptPath = await receiptRepository.storeReceipt(imagePath);
      storedPath = receiptPath;
      final rawText = await ocrService.recognizeText(receiptPath);
      _setState(ScanReceiptState(
        imagePath: receiptPath,
        receipt: parseReceipt(rawText),
      ));
    } on Exception catch (error) {
      if (storedPath != null) await receiptRepository.deleteReceipt(storedPath);
      _setState(ScanReceiptState(
        imagePath: imagePath,
        errorMessage: 'Không thể đọc hóa đơn này. Bạn có thể thử lại hoặc nhập thủ công. $error',
      ));
    }
  }

  void resetScan() {
    state = ScanReceiptState(flashEnabled: state.flashEnabled);
    notifyListeners();
  }

  void _setState(ScanReceiptState next) {
    state = next;
    notifyListeners();
  }
}

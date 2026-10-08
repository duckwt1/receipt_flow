import 'dart:ui';

import 'package:camera/camera.dart';

class ReceiptCameraService {
  CameraController? _controller;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) throw Exception('No camera is available on this device.');
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
  }

  Future<void> toggleFlash() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final next = controller.value.flashMode == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;
    await controller.setFlashMode(next);
  }

  Future<void> focus(Offset point) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    await controller.setFocusPoint(point);
    await controller.setExposurePoint(point);
  }

  Future<String> capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      throw Exception('Camera is not ready.');
    }
    return (await controller.takePicture()).path;
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }
}

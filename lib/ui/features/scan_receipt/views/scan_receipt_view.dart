import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/parsed_receipt.dart';

class ScanResult {
  const ScanResult({required this.imagePath, required this.receipt});
  final String imagePath;
  final ParsedReceipt receipt;
}

class ScanReceiptView extends ConsumerStatefulWidget {
  const ScanReceiptView({super.key});
  @override
  ConsumerState<ScanReceiptView> createState() => _ScanReceiptViewState();
}

class _ScanReceiptViewState extends ConsumerState<ScanReceiptView> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(scanReceiptViewModelProvider).initializeCamera());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(scanReceiptViewModelProvider, (previous, next) {
      final receipt = next.state.receipt;
      if (receipt != null && !_navigated && next.state.imagePath != null) {
        _navigated = true;
        context.push('/scan/review', extra: ScanResult(imagePath: next.state.imagePath!, receipt: receipt)).then((_) {
          if (mounted) {
            setState(() => _navigated = false);
            ref.read(scanReceiptViewModelProvider).resetScan();
          }
        });
      }
    });
    final vm = ref.watch(scanReceiptViewModelProvider);
    final state = vm.state;
    final controller = vm.cameraController;

    return Scaffold(
      backgroundColor: AppColors.scannerBackground,
      appBar: AppBar(
        title: const Text('Quét hóa đơn'),
        backgroundColor: AppColors.scannerBackground,
        foregroundColor: AppColors.scannerForeground,
        actions: [
          IconButton(
            tooltip: 'Bật/tắt đèn flash',
            onPressed: vm.toggleFlash,
            icon: Icon(
              state.flashEnabled ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: state.flashEnabled ? const Color(0xFFFBBF24) : Colors.white,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (state.isInitializing)
                  const Center(child: CircularProgressIndicator(color: Colors.white))
                else if (controller?.value.isInitialized == true)
                  GestureDetector(
                    onTapDown: (details) {
                      final size = context.size;
                      if (size != null) {
                        vm.focus(Offset(details.localPosition.dx / size.width, details.localPosition.dy / size.height));
                      }
                    },
                    child: CameraPreview(controller!),
                  )
                else
                  const Center(
                    child: Text(
                      'Máy ảnh không khả dụng. Hãy chọn ảnh từ thư viện.',
                      style: TextStyle(color: AppColors.scannerForeground),
                    ),
                  ),

                // Corner bracket viewfinder
                IgnorePointer(child: CustomPaint(painter: _FramePainter())),

                // Instruction Banner
                Positioned(
                  top: 24,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.crop_free_rounded, color: AppColors.primaryEmerald, size: 16),
                        SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Căn chỉnh hóa đơn vào khung hình',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (state.isProcessing)
                  Container(
                    color: AppColors.scannerOverlay,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(color: AppColors.primaryEmerald),
                            SizedBox(height: 16),
                            Text(
                              'Đang phân tích hóa đơn…',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Đang nhận diện số tiền & nơi bán',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xs),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.lg),
            color: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton.filledTonal(
                  tooltip: 'Chọn ảnh từ thư viện',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white12,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(48, 48),
                  ),
                  onPressed: state.isProcessing ? null : vm.chooseFromGallery,
                  icon: const Icon(Icons.photo_library_outlined, size: 24),
                ),
                GestureDetector(
                  onTap: state.isProcessing || controller?.value.isInitialized != true ? null : vm.capture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.5),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary, size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width * 0.82;
    final height = width * 1.38;
    final rect = Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: width, height: height);

    // Dim the background outside the frame
    final backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(backgroundPath, backgroundPaint);

    // Subtle outline border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), borderPaint);

    // Corner brackets (banking scan HUD)
    final cornerPaint = Paint()
      ..color = AppColors.primaryEmerald
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 26.0;
    final r = rect;

    // Top-left
    canvas.drawLine(Offset(r.left, r.top + cornerLength), Offset(r.left, r.top), cornerPaint);
    canvas.drawLine(Offset(r.left, r.top), Offset(r.left + cornerLength, r.top), cornerPaint);

    // Top-right
    canvas.drawLine(Offset(r.right - cornerLength, r.top), Offset(r.right, r.top), cornerPaint);
    canvas.drawLine(Offset(r.right, r.top), Offset(r.right, r.top + cornerLength), cornerPaint);

    // Bottom-left
    canvas.drawLine(Offset(r.left, r.bottom - cornerLength), Offset(r.left, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.left, r.bottom), Offset(r.left + cornerLength, r.bottom), cornerPaint);

    // Bottom-right
    canvas.drawLine(Offset(r.right - cornerLength, r.bottom), Offset(r.right, r.bottom), cornerPaint);
    canvas.drawLine(Offset(r.right, r.bottom), Offset(r.right, r.bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

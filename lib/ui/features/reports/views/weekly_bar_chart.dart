import 'dart:math' as math;

import 'package:flutter/material.dart';

class WeeklyBarChart extends StatefulWidget {
  const WeeklyBarChart({super.key, required this.values});
  final List<double> values;

  @override
  State<WeeklyBarChart> createState() => _WeeklyBarChartState();
}

class _WeeklyBarChartState extends State<WeeklyBarChart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..forward();

  bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  void didUpdateWidget(covariant WeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_listEquals(oldWidget.values, widget.values)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final maxValue = widget.values.fold<double>(0, (max, value) => value > max ? value : max);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => SizedBox(
        height: 190,
        width: constraints.maxWidth,
        child: CustomPaint(
          painter: _WeeklyBarPainter(
            values: widget.values,
            progress: Curves.easeOutCubic.transform(_controller.value),
            maxValue: maxValue,
            primary: Theme.of(context).colorScheme.primary,
            muted: Theme.of(context).colorScheme.onSurfaceVariant,
            outline: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  });
}

class _WeeklyBarPainter extends CustomPainter {
  const _WeeklyBarPainter({
    required this.values,
    required this.progress,
    required this.maxValue,
    required this.primary,
    required this.muted,
    required this.outline,
  });
  final List<double> values;
  final double progress;
  final double maxValue;
  final Color primary;
  final Color muted;
  final Color outline;
  static const _days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  static String _formatCompact(double value) {
    if (value <= 0) return '';
    if (value >= 1000000) {
      final tr = value / 1000000;
      final formatted = tr % 1 == 0 ? tr.toInt().toString() : tr.toStringAsFixed(1);
      return '${formatted}tr';
    }
    if (value >= 1000) {
      final k = value / 1000;
      final formatted = k % 1 == 0 ? k.toInt().toString() : k.toStringAsFixed(1);
      return '${formatted}k';
    }
    return value.toStringAsFixed(0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = TextStyle(color: muted, fontSize: 10, fontWeight: FontWeight.w600);
    final baseline = size.height - 24;
    final chartHeight = baseline - 42;
    final itemWidth = size.width / 7;
    final barWidth = math.min(24.0, itemWidth * 0.5).toDouble();
    final linePaint = Paint()..color = outline..strokeWidth = 1;
    canvas.drawLine(Offset(0, baseline), Offset(size.width, baseline), linePaint);

    for (var i = 0; i < 7; i++) {
      final value = i < values.length ? values[i] : 0.0;
      final height = maxValue == 0 ? 0.0 : chartHeight * value / maxValue * progress;
      final centerX = itemWidth * (i + 0.5);

      // Background track bar (pill)
      final trackRect = Rect.fromLTWH(centerX - barWidth / 2, baseline - chartHeight, barWidth, chartHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, const Radius.circular(6)),
        Paint()..color = outline.withValues(alpha: 0.35),
      );

      if (height > 0) {
        final barRect = Rect.fromLTWH(centerX - barWidth / 2, baseline - height, barWidth, height);
        final barPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primary,
              primary.withValues(alpha: 0.75),
            ],
          ).createShader(barRect);

        canvas.drawRRect(
          RRect.fromRectAndRadius(barRect, const Radius.circular(6)),
          barPaint,
        );
        _drawText(
          canvas,
          _formatCompact(value),
          Offset(centerX, baseline - height - 8),
          textStyle,
          centered: true,
        );
      }
      _drawText(canvas, _days[i], Offset(centerX, baseline + 8), textStyle, centered: true);
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style, {bool centered = false}) {
    if (text.isEmpty) return;
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: 64);
    painter.paint(canvas, Offset(centered ? position.dx - painter.width / 2 : position.dx, position.dy));
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.progress != progress || oldDelegate.primary != primary;
}

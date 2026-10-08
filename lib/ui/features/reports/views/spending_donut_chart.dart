import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../core/widgets/expense_presentation.dart';

class SpendingDonutChart extends StatefulWidget {
  const SpendingDonutChart({super.key, required this.values, this.onCategorySelected});
  final Map<ExpenseCategory, double> values;
  final ValueChanged<ExpenseCategory?>? onCategorySelected;

  @override
  State<SpendingDonutChart> createState() => _SpendingDonutChartState();
}

class _SpendingDonutChartState extends State<SpendingDonutChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  )..forward();
  ExpenseCategory? _selected;

  @override
  void didUpdateWidget(covariant SpendingDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.values != widget.values) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectAt(Offset point, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    var angle = math.atan2(point.dy - center.dy, point.dx - center.dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;
    final total = widget.values.values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;
    var cursor = 0.0;
    final entries = widget.values.entries.toList();
    for (final entry in entries) {
      cursor += entry.value / total * 2 * math.pi;
      if (angle <= cursor) {
        setState(() => _selected = _selected == entry.key ? null : entry.key);
        widget.onCategorySelected?.call(_selected);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.values.values.fold<double>(0, (sum, value) => sum + value);
    final selectedAmount = _selected == null ? null : widget.values[_selected];
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, 250.0).toDouble();
          return GestureDetector(
            onTapDown: (details) => _selectAt(details.localPosition, Size(size, size)),
            child: SizedBox(
              width: size,
              height: size,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) => CustomPaint(
                  painter: _DonutPainter(
                    values: widget.values,
                    progress: Curves.easeOutCubic.transform(_controller.value),
                    selected: _selected,
                  palette: AppColors.chartPalette,
                    track: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: total == 0
                        ? const Text('Chưa có dữ liệu')
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                selectedAmount == null ? 'Tổng chi tiêu' : categoryLabel(_selected!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatAmount(selectedAmount ?? total),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              if (selectedAmount != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                  ),
                                  child: Text(
                                    '${(selectedAmount / total * 100).round()}% trong tháng',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: AppSpacing.sm),
        if (total > 0)
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            alignment: WrapAlignment.center,
            children: [
              for (var i = 0; i < widget.values.length; i++)
                _LegendItem(
                  color: AppColors.chartPalette[i % AppColors.chartPalette.length],
                  label: categoryLabel(widget.values.keys.elementAt(i)),
                  isSelected: _selected == widget.values.keys.elementAt(i),
                  onTap: () {
                    final key = widget.values.keys.elementAt(i);
                    setState(() => _selected = _selected == key ? null : key);
                    widget.onCategorySelected?.call(_selected);
                  },
                ),
            ],
          ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : (theme.brightness == Brightness.dark ? AppColors.darkSubtle : AppColors.lightSubtle),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: isSelected ? color : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({
    required this.values,
    required this.progress,
    required this.selected,
    required this.palette,
    required this.track,
  });
  final Map<ExpenseCategory, double> values;
  final double progress;
  final ExpenseCategory? selected;
  final List<Color> palette;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = math.min(size.width, size.height).toDouble() * 0.39;
    final stroke = math.min(size.width, size.height).toDouble() * 0.12;
    final trackPaint = Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = stroke;
    canvas.drawCircle(center, radius, trackPaint);
    final total = values.values.fold<double>(0, (sum, value) => sum + value);
    if (total <= 0) return;
    var start = -math.pi / 2;
    var index = 0;
    for (final entry in values.entries) {
      final sweep = entry.value / total * math.pi * 2 * progress;
      final selectedSegment = entry.key == selected;
      final paint = Paint()
        ..color = palette[index % palette.length].withValues(alpha: selected == null || selectedSegment ? 1 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
      start += entry.value / total * math.pi * 2;
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.progress != progress ||
      oldDelegate.selected != selected || oldDelegate.track != track;
}

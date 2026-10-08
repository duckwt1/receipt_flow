import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../core/widgets/expense_presentation.dart';
import 'spending_donut_chart.dart';
import 'weekly_bar_chart.dart';

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});
  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(reportsViewModelProvider).load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(reportsViewModelProvider);
    final state = vm.state;
    final summary = state.summary;
    final month = state.selectedMonth ?? DateTime.now();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê chi tiêu'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: () => ref.read(reportsViewModelProvider).load(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 2),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.errorMessage!),
                        const SizedBox(height: AppSpacing.sm),
                        FilledButton(
                          onPressed: () => ref.read(reportsViewModelProvider).load(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : state.expenses.isEmpty
                  ? EmptyState(
                      title: 'Chưa có dữ liệu báo cáo',
                      message: 'Biểu đồ sẽ tự động cập nhật khi bạn thêm chi tiêu.',
                      action: FilledButton.icon(
                        onPressed: () => context.push('/scan'),
                        icon: const Icon(Icons.document_scanner_outlined),
                        label: const Text('Quét hóa đơn'),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => ref.read(reportsViewModelProvider).load(),
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        children: [
                          // Period Selector
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                            child: Card(
                              margin: EdgeInsets.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xs,
                                  vertical: 4,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      tooltip: 'Tháng trước',
                                      icon: const Icon(Icons.chevron_left_rounded),
                                      onPressed: vm.previousMonth,
                                    ),
                                    Flexible(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.calendar_today_rounded, size: 16),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Text(
                                              '${_monthName(month.month)} ${month.year}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Tháng sau',
                                      icon: const Icon(Icons.chevron_right_rounded),
                                      onPressed: vm.nextMonth,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),

                          if (summary == null || summary.monthlyTotal == 0) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.surfaceContainerHighest,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.calendar_month_outlined,
                                          size: 28,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        'Không có chi tiêu trong ${_monthName(month.month)} ${month.year}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Text(
                                        'Bạn có ${state.expenses.length} khoản chi ở các tháng khác. Dùng mũi tên để chuyển tháng.',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // Total Monthly Outflow Card
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                              child: Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? AppColors.darkCard
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(AppRadius.medium),
                                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'TỔNG CHI TIÊU TRONG THÁNG',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatAmount(summary.monthlyTotal),
                                      style: theme.textTheme.headlineMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: theme.brightness == Brightness.dark
                                            ? const Color(0xFFF87171)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Category Breakdown Donut
                            const SectionTitle('Phân bổ theo danh mục'),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: SpendingDonutChart(values: summary.categoryTotals),
                                ),
                              ),
                            ),

                            // Weekly Pulse Bar Chart
                            SectionTitle(
                              'Chi tiêu tuần này',
                              trailing: summary.weekStart != null && summary.weekEnd != null
                                  ? Text(
                                      '${summary.weekStart!.day.toString().padLeft(2, '0')}/${summary.weekStart!.month.toString().padLeft(2, '0')} – ${summary.weekEnd!.day.toString().padLeft(2, '0')}/${summary.weekEnd!.month.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    )
                                  : null,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      WeeklyBarChart(values: summary.weeklyTotals),
                                      if (summary.weeklyTotals.every((v) => v == 0)) ...[
                                        const SizedBox(height: AppSpacing.xs),
                                        Center(
                                          child: Text(
                                            'Chưa có chi tiêu nào trong tuần này',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.onSurfaceVariant,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Detailed Category Breakdown
                            const SectionTitle('Tổng tiền theo danh mục'),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              child: Card(
                                margin: EdgeInsets.zero,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                                  child: Column(
                                    children: [
                                      for (final entry in summary.categoryTotals.entries)
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: categoryColors(entry.key, theme.brightness).background,
                                                  borderRadius: BorderRadius.circular(AppRadius.small),
                                                ),
                                                child: Icon(
                                                  categoryIcon(entry.key),
                                                  color: categoryColors(entry.key, theme.brightness).foreground,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.sm),
                                              Expanded(
                                                child: Text(
                                                  categoryLabel(entry.key),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                                ),
                                              ),
                                              const SizedBox(width: AppSpacing.xs),
                                              Text(
                                                formatAmount(entry.value),
                                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ],
                      ),
                    ),
    );
  }

  String _monthName(int month) => const [
    'Tháng 1',
    'Tháng 2',
    'Tháng 3',
    'Tháng 4',
    'Tháng 5',
    'Tháng 6',
    'Tháng 7',
    'Tháng 8',
    'Tháng 9',
    'Tháng 10',
    'Tháng 11',
    'Tháng 12'
  ][month - 1];
}

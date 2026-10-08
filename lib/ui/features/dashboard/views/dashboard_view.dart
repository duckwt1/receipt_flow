import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../core/widgets/budget_editor_dialog.dart';
import '../../../core/widgets/expense_presentation.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView> {
  bool _isBalanceObscured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(dashboardViewModelProvider).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(dashboardViewModelProvider).state;
    final monthlyBudget = ref.watch(monthlyBudgetProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1E3A8A)],
                ),
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: const Icon(Icons.account_balance_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSpacing.xs),
            const Flexible(
              child: Text(
                'ReceiptFlow',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(dashboardViewModelProvider).load(),
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          children: [
            // Top User Status Pill
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_rounded,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quỹ cá nhân / CLB',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Quản lý thu chi',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryEmerald.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, color: AppColors.primaryEmerald, size: 13),
                        SizedBox(width: 4),
                        Text(
                          'Đã xác thực',
                          style: TextStyle(
                            color: AppColors.primaryEmerald,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Hero Budget Card
            BankHeroCard(
              totalAmount: state.monthlyTotal,
              budgetAmount: monthlyBudget,
              isObscured: _isBalanceObscured,
              onToggleObscured: () => setState(() => _isBalanceObscured = !_isBalanceObscured),
              onEditBudget: () => showBudgetEditorDialog(context, ref),
              cardHolder: 'NGÂN SÁCH CHI TIÊU',
            ),

            // Banking Quick Actions Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
              child: Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
                  child: Row(
                    children: [
                      Expanded(
                        child: BankQuickActionButton(
                          icon: Icons.document_scanner_rounded,
                          label: 'Quét hóa đơn',
                          isHighlighted: true,
                          onTap: () => context.push('/scan').then((_) {
                            if (context.mounted) ref.read(dashboardViewModelProvider).load();
                          }),
                        ),
                      ),
                      Expanded(
                        child: BankQuickActionButton(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Thêm chi tiêu',
                          onTap: () => context.push('/expenses/new').then((_) {
                            if (context.mounted) ref.read(dashboardViewModelProvider).load();
                          }),
                        ),
                      ),
                      Expanded(
                        child: BankQuickActionButton(
                          icon: Icons.insights_rounded,
                          label: 'Thống kê',
                          onTap: () => context.push('/reports'),
                        ),
                      ),
                      Expanded(
                        child: BankQuickActionButton(
                          icon: Icons.receipt_long_rounded,
                          label: 'Lịch sử',
                          onTap: () => context.push('/expenses'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Spending by Category
            SectionTitle(
              'Chi tiêu theo danh mục',
              trailing: TextButton(
                onPressed: () => context.push('/reports'),
                child: const Text('Báo cáo'),
              ),
            ),
            if (state.categoryTotals.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Icon(Icons.pie_chart_outline_rounded, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          state.recentExpenses.isEmpty
                              ? 'Tổng chi tiêu theo danh mục sẽ xuất hiện ở đây.'
                              : 'Chưa có khoản chi nào trong tháng này. Bấm Báo cáo để xem tất cả các kỳ.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Column(
                    children: state.categoryTotals.entries.map((entry) {
                      final percentage = state.monthlyTotal > 0 ? (entry.value / state.monthlyTotal) : 0.0;
                      final palette = categoryColors(entry.key, theme.brightness);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: palette.background,
                                borderRadius: BorderRadius.circular(AppRadius.small),
                              ),
                              child: Icon(categoryIcon(entry.key), color: palette.foreground, size: 20),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          categoryLabel(entry.key),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        formatAmount(entry.value),
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    child: LinearProgressIndicator(
                                      value: percentage.clamp(0.0, 1.0),
                                      minHeight: 5,
                                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation(palette.foreground),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

            // Recent Expenses Section
            SectionTitle(
              'Giao dịch gần đây',
              trailing: TextButton(
                onPressed: () => context.push('/expenses'),
                child: const Text('Xem tất cả'),
              ),
            ),
            if (state.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (state.errorMessage != null)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: AppColors.error),
                  title: Text(state.errorMessage!),
                  trailing: IconButton(
                    onPressed: () => ref.read(dashboardViewModelProvider).load(),
                    icon: const Icon(Icons.refresh),
                  ),
                ),
              )
            else if (state.recentExpenses.isEmpty)
              const EmptyState(
                title: 'Chưa có khoản chi nào',
                message: 'Quét hóa đơn hoặc thêm khoản chi để bắt đầu theo dõi.',
              )
            else
              ...state.recentExpenses.map(
                (expense) => ExpenseCard(
                  expense: expense,
                  onTap: () => context.push('/expenses/${expense.id}').then((_) {
                    if (context.mounted) ref.read(dashboardViewModelProvider).load();
                  }),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 0),
    );
  }
}

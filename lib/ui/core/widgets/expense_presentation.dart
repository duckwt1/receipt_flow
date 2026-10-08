import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/models/expense.dart';
import '../../../domain/models/expense_category.dart';

String categoryLabel(ExpenseCategory category) => switch (category) {
  ExpenseCategory.food => 'Ăn uống',
  ExpenseCategory.study => 'Học tập',
  ExpenseCategory.travel => 'Đi lại',
  ExpenseCategory.gear => 'Thiết bị',
  ExpenseCategory.entertainment => 'Giải trí',
};

IconData categoryIcon(ExpenseCategory category) => switch (category) {
  ExpenseCategory.food => Icons.restaurant_rounded,
  ExpenseCategory.study => Icons.school_rounded,
  ExpenseCategory.travel => Icons.directions_car_rounded,
  ExpenseCategory.gear => Icons.devices_rounded,
  ExpenseCategory.entertainment => Icons.sports_esports_rounded,
};

({Color background, Color foreground}) categoryColors(ExpenseCategory category, Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  if (isDark) {
    return switch (category) {
      ExpenseCategory.food => (background: const Color(0xFF332014), foreground: const Color(0xFFFB923C)),
      ExpenseCategory.study => (background: const Color(0xFF172554), foreground: const Color(0xFF60A5FA)),
      ExpenseCategory.travel => (background: const Color(0xFF064E3B), foreground: const Color(0xFF34D399)),
      ExpenseCategory.gear => (background: const Color(0xFF2E1065), foreground: const Color(0xFFA78BFA)),
      ExpenseCategory.entertainment => (background: const Color(0xFF4C0519), foreground: const Color(0xFFF472B6)),
    };
  }
  return switch (category) {
    ExpenseCategory.food => (background: AppColors.categoryFoodBg, foreground: AppColors.categoryFoodIcon),
    ExpenseCategory.study => (background: AppColors.categoryStudyBg, foreground: AppColors.categoryStudyIcon),
    ExpenseCategory.travel => (background: AppColors.categoryTravelBg, foreground: AppColors.categoryTravelIcon),
    ExpenseCategory.gear => (background: AppColors.categoryGearBg, foreground: AppColors.categoryGearIcon),
    ExpenseCategory.entertainment => (background: AppColors.categoryEntertainmentBg, foreground: AppColors.categoryEntertainmentIcon),
  };
}

String formatAmount(double amount) {
  final integerPart = amount.round().toString();
  final formatted = integerPart.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]}.',
  );
  return '$formatted ₫';
}

/// Hero Budget Card
class BankHeroCard extends StatelessWidget {
  const BankHeroCard({
    super.key,
    required this.totalAmount,
    this.budgetAmount = 5000000.0,
    required this.isObscured,
    required this.onToggleObscured,
    this.onEditBudget,
    this.cardHolder = 'NGÂN SÁCH CHI TIÊU',
    this.cardNumber,
  });

  final double totalAmount;
  final double budgetAmount;
  final bool isObscured;
  final VoidCallback onToggleObscured;
  final VoidCallback? onEditBudget;
  final String cardHolder;
  final String? cardNumber;

  @override
  Widget build(BuildContext context) {
    final remaining = budgetAmount - totalAmount;
    final isRemainingPositive = remaining >= 0;
    final progress = budgetAmount > 0 ? (totalAmount / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final percent = budgetAmount > 0 ? (totalAmount / budgetAmount * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        gradient: AppColors.bankCardGradient,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1),
      ),
      child: Stack(
        children: [
          // Ambient background glow decoration
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryEmerald.withValues(alpha: 0.15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Budget badge & Edit Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFFFBBF24), size: 14),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                cardHolder,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (onEditBudget != null)
                      InkWell(
                        onTap: onEditBudget,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_outlined, color: Colors.white, size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Đặt ngân sách',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      const Icon(Icons.savings_outlined, color: Colors.white70, size: 20),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Balance Label & Eye Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Ngân sách',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: onToggleObscured,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white70,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isRemainingPositive ? AppColors.primaryEmerald : AppColors.error).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        isRemainingPositive ? 'Số dư còn lại' : 'Vượt quỹ',
                        style: TextStyle(
                          color: isRemainingPositive ? const Color(0xFF34D399) : const Color(0xFFFCA5A5),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxs),

                // Amount
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isObscured
                        ? '•••••••• ₫'
                        : (isRemainingPositive ? formatAmount(remaining) : '- ${formatAmount(remaining.abs())}'),
                    style: TextStyle(
                      color: isRemainingPositive ? Colors.white : const Color(0xFFFCA5A5),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Budget Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                      totalAmount > budgetAmount ? const Color(0xFFF87171) : const Color(0xFF34D399),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Đã chi: ${formatAmount(totalAmount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Quỹ: ${formatAmount(budgetAmount)} ($percent%)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Bottom row: Current Month Cycle & Active Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Tháng ${DateTime.now().month}/${DateTime.now().year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (totalAmount > budgetAmount ? AppColors.error : AppColors.primaryEmerald)
                            .withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: (totalAmount > budgetAmount ? AppColors.error : AppColors.primaryEmerald)
                              .withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            totalAmount > budgetAmount ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                            color: totalAmount > budgetAmount ? const Color(0xFFF87171) : const Color(0xFF34D399),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            totalAmount > budgetAmount ? 'Vượt quỹ' : 'Đang hoạt động',
                            style: TextStyle(
                              color: totalAmount > budgetAmount ? const Color(0xFFF87171) : const Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Banking Quick Action Button
class BankQuickActionButton extends StatelessWidget {
  const BankQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isHighlighted
        ? (isDark ? const Color(0xFF0F3B2C) : const Color(0xFFE6F4EA))
        : (isDark ? AppColors.darkSubtle : AppColors.lightSubtle);

    final iconColor = isHighlighted
        ? AppColors.primaryEmerald
        : (isDark ? Colors.white : AppColors.primary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: isHighlighted
                      ? AppColors.primaryEmerald.withValues(alpha: 0.3)
                      : theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Banking styled Transaction Card
class ExpenseCard extends StatelessWidget {
  const ExpenseCard({super.key, required this.expense, this.onTap});
  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = categoryColors(expense.category, theme.brightness);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 12),
          child: Row(
            children: [
              // Category Icon Container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                ),
                child: Icon(categoryIcon(expense.category), color: palette.foreground, size: 22),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Merchant & Category info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.merchantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${categoryLabel(expense.category)} · ${_date(expense.expenseDate)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Outflow Transaction Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '- ${formatAmount(expense.amount)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFFF87171)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Thành công',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.message, this.action});
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 36,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpacing.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.xs),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: -0.2,
            ),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

BoxDecoration appCardDecoration(BuildContext context) => BoxDecoration(
  color: Theme.of(context).colorScheme.surface,
  borderRadius: BorderRadius.circular(AppRadius.medium),
  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
);

class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({super.key, required this.selectedIndex});
  final int selectedIndex;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: selectedIndex,
    onDestinationSelected: (index) {
      switch (index) {
        case 1:
          context.go('/expenses');
          break;
        case 2:
          context.go('/reports');
          break;
        default:
          context.go('/');
          break;
      }
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.wallet_outlined),
        selectedIcon: Icon(Icons.wallet),
        label: 'Trang chủ',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Giao dịch',
      ),
      NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: 'Thống kê',
      ),
    ],
  );
}

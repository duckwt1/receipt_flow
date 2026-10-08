import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'expense_presentation.dart';

Future<void> showBudgetEditorDialog(BuildContext context, WidgetRef ref) async {
  final currentBudget = ref.read(monthlyBudgetProvider);
  final controller = TextEditingController(text: currentBudget.toStringAsFixed(0));

  final now = DateTime.now();
  final theme = Theme.of(context);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.large)),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryEmerald, size: 20),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Expanded(
                child: Text(
                  'Thiết lập ngân sách',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hạn mức quỹ chi tiêu Tháng ${now.month}/${now.year}',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
                  decoration: const InputDecoration(
                    labelText: 'Số tiền ngân sách',
                    prefixIcon: Icon(Icons.payments_outlined),
                    suffixText: '₫',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Gợi ý nhanh:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final preset in [2000000.0, 3000000.0, 5000000.0, 10000000.0])
                      ActionChip(
                        label: Text(formatAmount(preset)),
                        backgroundColor: theme.brightness == Brightness.dark
                            ? AppColors.darkSubtle
                            : AppColors.lightSubtle,
                        onPressed: () {
                          setState(() {
                            controller.text = preset.toStringAsFixed(0);
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () async {
                final text = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
                final amount = double.tryParse(text);
                if (amount != null && amount > 0) {
                  await ref.read(monthlyBudgetProvider.notifier).setBudget(amount);
                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã cập nhật ngân sách: ${formatAmount(amount)}'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                }
              },
              child: const Text('Lưu ngân sách'),
            ),
          ],
        );
      },
    ),
  );
}

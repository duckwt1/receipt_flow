import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../../domain/models/parsed_receipt.dart';
import '../../../core/widgets/expense_presentation.dart';
import 'scan_receipt_view.dart';

class ReceiptReviewView extends ConsumerStatefulWidget {
  const ReceiptReviewView({super.key, required this.result});
  final ScanResult result;
  @override
  ConsumerState<ReceiptReviewView> createState() => _ReceiptReviewViewState();
}

class _ReceiptReviewViewState extends ConsumerState<ReceiptReviewView> {
  late final ParsedReceipt _receipt = widget.result.receipt;
  late final TextEditingController _merchant = TextEditingController(text: _receipt.merchantName ?? '');
  late final TextEditingController _amount = TextEditingController(text: _receipt.totalAmount?.toStringAsFixed(0) ?? '');
  late DateTime _date = _receipt.transactionDate ?? DateTime.now();
  ExpenseCategory _category = ExpenseCategory.food;

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(receiptReviewViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Kiểm tra hóa đơn')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Receipt Image Card Preview
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Image.file(
                File(widget.result.imagePath),
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image_outlined, size: 40)),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Verification Form Card
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, color: AppColors.primaryEmerald, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thông tin bóc tách từ hóa đơn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ConfidenceBadge(confidence: _receipt.merchantConfidence),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _merchant,
                    decoration: const InputDecoration(
                      labelText: 'Nơi thanh toán / Đơn vị bán',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ConfidenceBadge(confidence: _receipt.amountConfidence),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _amount,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Số tiền',
                      suffixText: '₫',
                      prefixIcon: Icon(Icons.payments_outlined),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _ConfidenceBadge(confidence: _receipt.dateConfidence),
                  const SizedBox(height: 4),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      side: BorderSide(color: theme.colorScheme.outline),
                    ),
                    tileColor: theme.brightness == Brightness.light
                        ? AppColors.lightSubtle
                        : AppColors.darkSubtle,
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Ngày giao dịch'),
                    subtitle: Text(
                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (date != null) setState(() => _date = date);
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<ExpenseCategory>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Danh mục',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: [
                      for (final category in ExpenseCategory.values)
                        DropdownMenuItem(
                          value: category,
                          child: Row(
                            children: [
                              Icon(categoryIcon(category), size: 18),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  categoryLabel(category),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _category = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (vm.state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                vm.state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),

          FilledButton(
            onPressed: vm.state.isSaving
                ? null
                : () async {
                    final id = await vm.save(
                      receipt: _receipt,
                      merchantName: _merchant.text,
                      amount: _amount.text,
                      expenseDate: _date,
                      category: _category,
                      receiptImagePath: widget.result.imagePath,
                    );
                    if (id != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lưu chi tiêu thành công!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      context.go('/expenses/$id');
                    }
                  },
            child: vm.state.isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Lưu chi tiêu'),
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => context.go('/expenses/new'),
            child: const Text('Nhập thủ công thay thế'),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    final high = confidence >= 0.8;
    final medium = confidence >= 0.55 && !high;
    final label = high
        ? 'Độ tin cậy cao'
        : medium
            ? 'Độ tin cậy trung bình'
            : 'Độ tin cậy thấp — vui lòng kiểm tra lại';
    final color = high
        ? AppColors.success
        : medium
            ? AppColors.warning
            : Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              high ? Icons.verified_rounded : Icons.info_outline_rounded,
              size: 15,
              color: color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

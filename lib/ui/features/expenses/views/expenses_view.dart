import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../domain/models/expense_category.dart';
import '../../../core/widgets/expense_presentation.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});
  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expensesViewModelProvider).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(expensesViewModelProvider);
    final state = vm.state;
    final theme = Theme.of(context);
    final totalFiltered = state.expenses.fold<double>(0, (sum, item) => sum + item.amount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao dịch'),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            onPressed: vm.load,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      bottomNavigationBar: const AppNavigationBar(selectedIndex: 1),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/expenses/new'),
        icon: const Icon(Icons.add),
        label: const Text('Thêm mới'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Banking Account Spending Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 12),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? AppColors.darkCard
                    : AppColors.lightSubtle,
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng chi tiêu',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatAmount(totalFiltered),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      '${state.expenses.length} Giao dịch',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
            child: TextField(
              controller: _searchController,
              onChanged: vm.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm kiếm nơi thanh toán',
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          vm.search('');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category Chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.xs),
                  child: ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: state.category == null,
                    onSelected: (_) => vm.filterCategory(null),
                  ),
                ),
                for (final category in ExpenseCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: ChoiceChip(
                      label: Text(categoryLabel(category)),
                      selected: state.category == category,
                      onSelected: (_) => vm.filterCategory(category),
                    ),
                  ),
              ],
            ),
          ),

          // Date Filter Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.date_range, size: 18),
                    label: Text(
                      state.startDate == null
                          ? 'Lọc theo ngày'
                          : '${state.startDate!.day}/${state.startDate!.month} – ${state.endDate!.day}/${state.endDate!.month}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    onPressed: () async {
                      final range = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                        initialDateRange: state.startDate == null
                            ? null
                            : DateTimeRange(start: state.startDate!, end: state.endDate!),
                      );
                      if (range != null) vm.filterDateRange(range.start, range.end);
                    },
                  ),
                ),
                if (state.startDate != null)
                  IconButton(
                    tooltip: 'Xóa bộ lọc ngày',
                    onPressed: () => vm.filterDateRange(null, null),
                    icon: const Icon(Icons.close, size: 18),
                  ),
              ],
            ),
          ),

          // Transactions Stream
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? EmptyState(
                        title: 'Không thể tải danh sách chi tiêu',
                        message: state.errorMessage!,
                        action: FilledButton(onPressed: vm.load, child: const Text('Thử lại')),
                      )
                    : state.expenses.isEmpty
                        ? const EmptyState(
                            title: 'Không tìm thấy giao dịch nào',
                            message: 'Thử thay đổi tìm kiếm hoặc thêm giao dịch mới.',
                          )
                        : RefreshIndicator(
                            onRefresh: vm.load,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 80, top: 4),
                              itemCount: state.expenses.length,
                              itemBuilder: (context, index) => ExpenseCard(
                                expense: state.expenses[index],
                                onTap: () => context.push('/expenses/${state.expenses[index].id}'),
                              ),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class ExpenseEditorView extends ConsumerStatefulWidget {
  const ExpenseEditorView({super.key, this.expenseId});
  final int? expenseId;
  @override
  ConsumerState<ExpenseEditorView> createState() => _ExpenseEditorViewState();
}

class _ExpenseEditorViewState extends ConsumerState<ExpenseEditorView> {
  late final TextEditingController _merchant = TextEditingController();
  late final TextEditingController _amount = TextEditingController();
  DateTime _date = DateTime.now();
  ExpenseCategory _category = ExpenseCategory.food;
  bool _fieldsLoaded = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expenseEditorViewModelProvider(widget.expenseId)).load());
  }

  @override
  void dispose() {
    _merchant.dispose();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(expenseEditorViewModelProvider(widget.expenseId));
    final expense = vm.expense;
    if (!_fieldsLoaded && expense != null) {
      _merchant.text = expense.merchantName;
      _amount.text = expense.amount.toStringAsFixed(0);
      _date = expense.expenseDate;
      _category = expense.category;
      _fieldsLoaded = true;
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expenseId == null ? 'Thêm chi tiêu' : 'Sửa chi tiêu'),
      ),
      body: vm.state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                // Top Amount Hero Input Container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? AppColors.darkCard
                        : Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SỐ TIỀN CHI TIÊU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextField(
                        controller: _amount,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                        decoration: const InputDecoration(
                          hintText: '0',
                          suffixText: '₫',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Form Details Card
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Thông tin chi tiêu',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _merchant,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Nơi thanh toán / Đơn vị bán',
                            prefixIcon: Icon(Icons.storefront_outlined),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.small),
                            side: BorderSide(color: theme.colorScheme.outline),
                          ),
                          tileColor: theme.brightness == Brightness.light
                              ? AppColors.lightSubtle
                              : AppColors.darkSubtle,
                          leading: const Icon(Icons.calendar_month_outlined),
                          title: const Text('Ngày chi tiêu'),
                          subtitle: Text(
                            '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _date,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now().add(const Duration(days: 1)),
                            );
                            if (picked != null) setState(() => _date = picked);
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
                          onChanged: (category) {
                            if (category != null) setState(() => _category = category);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Receipt Attachment
                OutlinedButton(
                  onPressed: vm.selectReceiptImage,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.attach_file_rounded),
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          vm.selectedImagePath == null
                              ? 'Đính kèm ảnh hóa đơn (tùy chọn)'
                              : 'Thay đổi ảnh hóa đơn',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (vm.selectedImagePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.small),
                      child: Image.file(
                        File(vm.selectedImagePath!),
                        height: 160,
                        fit: BoxFit.contain,
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

                // Submit Button
                FilledButton(
                  onPressed: vm.state.isSaving
                      ? null
                      : () async {
                          final saved = await vm.save(
                            merchant: _merchant.text,
                            amount: _amount.text,
                            date: _date,
                            category: _category,
                          );
                          if (saved && context.mounted) context.go('/expenses');
                        },
                  child: vm.state.isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Lưu chi tiêu'),
                ),
              ],
            ),
    );
  }
}

class ExpenseDetailView extends ConsumerStatefulWidget {
  const ExpenseDetailView({super.key, required this.expenseId});
  final int expenseId;
  @override
  ConsumerState<ExpenseDetailView> createState() => _ExpenseDetailViewState();
}

class _ExpenseDetailViewState extends ConsumerState<ExpenseDetailView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(expenseEditorViewModelProvider(widget.expenseId)).load());
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(expenseEditorViewModelProvider(widget.expenseId));
    final expense = vm.expense;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Về trang chủ',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        title: const Text('Hóa đơn điện tử'),
        actions: [
          IconButton(
            tooltip: 'Trang chủ',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.home_outlined),
          ),
          if (expense != null)
            IconButton(
              tooltip: 'Chỉnh sửa',
              onPressed: () => context.push('/expenses/${widget.expenseId}/edit'),
              icon: const Icon(Icons.edit_outlined),
            ),
          if (expense != null)
            IconButton(
              tooltip: 'Xóa',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Xóa khoản chi?'),
                    content: const Text('Khoản chi này và ảnh hóa đơn đính kèm sẽ bị xóa vĩnh viễn.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Hủy'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Xóa'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  final deleted = await vm.delete();
                  if (deleted && context.mounted) context.go('/expenses');
                  if (!deleted && context.mounted && vm.state.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(vm.state.errorMessage!)),
                    );
                  }
                }
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
            ),
        ],
      ),
      body: vm.state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : expense == null
              ? EmptyState(
                  title: 'Không tìm thấy khoản chi',
                  message: vm.state.errorMessage ?? 'Khoản chi này có thể đã bị xóa.',
                  action: FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Về trang chủ'),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Official Digital Receipt Slip
                    Container(
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark
                            ? AppColors.darkCard
                            : Colors.white,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.5)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          // Success Badge
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.primaryEmerald.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryEmerald,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          const Text(
                            'GIAO DỊCH HOÀN TẤT',
                            style: TextStyle(
                              color: AppColors.primaryEmerald,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '- ${formatAmount(expense.amount)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.brightness == Brightness.dark
                                   ? const Color(0xFFF87171)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expense.merchantName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Dotted separator divider
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                            child: Divider(
                              color: theme.colorScheme.outline.withValues(alpha: 0.4),
                              thickness: 1,
                            ),
                          ),

                          // Receipt Details Rows
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              children: [
                                _ReceiptRow(label: 'Danh mục', value: categoryLabel(expense.category)),
                                const SizedBox(height: AppSpacing.sm),
                                _ReceiptRow(
                                  label: 'Thời gian',
                                  value: '${expense.expenseDate.day.toString().padLeft(2, '0')}/${expense.expenseDate.month.toString().padLeft(2, '0')}/${expense.expenseDate.year}',
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                _ReceiptRow(
                                  label: 'Mã giao dịch',
                                  value: 'TXN-${expense.id.toString().padLeft(6, '0')}',
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                const _ReceiptRow(
                                  label: 'Hình thức',
                                  value: 'Quỹ tiền mặt / Chuyển khoản',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Receipt Image if present
                    if (expense.receiptImagePath != null) ...[
                      const SectionTitle('Chứng từ / Hóa đơn đính kèm'),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        child: Image.file(
                          File(expense.receiptImagePath!),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const ListTile(
                            leading: Icon(Icons.broken_image_outlined),
                            title: Text('Không thể tải ảnh hóa đơn'),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.lg),

                    // Navigation Actions
                    FilledButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Về trang chủ'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: () => context.go('/expenses'),
                      icon: const Icon(Icons.receipt_long_rounded),
                      label: const Text('Xem danh sách giao dịch'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

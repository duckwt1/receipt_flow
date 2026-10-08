import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../core/widgets/budget_editor_dialog.dart';
import '../../../core/widgets/expense_presentation.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt & Bảo mật')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        children: [
          // Security Profile Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, Color(0xFF1E3A8A)],
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bảo mật trên thiết bị',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tất cả hóa đơn & dữ liệu chi tiêu được lưu trữ ngoại tuyến và bảo mật trên thiết bị.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Monthly Budget Setting Card
          Card(
            child: ListTile(
              leading: Icon(Icons.account_balance_wallet_outlined, color: theme.colorScheme.primary),
              title: const Text('Hạn mức ngân sách tháng'),
              subtitle: Text(
                formatAmount(ref.watch(monthlyBudgetProvider)),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.edit_outlined),
              onTap: () => showBudgetEditorDialog(context, ref),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // Appearance Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
                    child: Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Giao diện & Chủ đề',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  RadioGroup<ThemeMode>(
                    groupValue: mode,
                    onChanged: (value) {
                      if (value != null) ref.read(themeModeProvider.notifier).state = value;
                    },
                    child: Column(
                      children: const [
                        RadioListTile<ThemeMode>(
                          secondary: Icon(Icons.brightness_auto_outlined),
                          title: Text('Theo hệ thống'),
                          subtitle: Text('Đồng bộ theo cài đặt thiết bị'),
                          value: ThemeMode.system,
                        ),
                        RadioListTile<ThemeMode>(
                          secondary: Icon(Icons.light_mode_outlined),
                          title: Text('Giao diện Sáng'),
                          subtitle: Text('Sáng sủa, sắc nét phong cách ngân hàng'),
                          value: ThemeMode.light,
                        ),
                        RadioListTile<ThemeMode>(
                          secondary: Icon(Icons.dark_mode_outlined),
                          title: Text('Giao diện Tối'),
                          subtitle: Text('Tối tương phản cao, bảo vệ mắt'),
                          value: ThemeMode.dark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // About & Privacy Card
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.receipt_long_rounded),
                  title: const Text('Phiên bản ứng dụng'),
                  trailing: const Text(
                    '1.0.0 (Phiên bản Ngân hàng)',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.fingerprint_rounded),
                  title: const Text('Công nghệ OCR'),
                  trailing: const Text(
                    'Google ML Kit ngoại tuyến',
                    style: TextStyle(fontSize: 13, color: AppColors.primaryEmerald, fontWeight: FontWeight.w600),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.storage_rounded),
                  title: const Text('Cơ sở dữ liệu'),
                  trailing: const Text(
                    'SQLite cục bộ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

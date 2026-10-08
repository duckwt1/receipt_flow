import 'package:go_router/go_router.dart';

import '../../ui/features/dashboard/views/dashboard_view.dart';
import '../../ui/features/expenses/views/expenses_view.dart';
import '../../ui/features/reports/views/reports_view.dart';
import '../../ui/features/scan_receipt/views/receipt_review_view.dart';
import '../../ui/features/scan_receipt/views/scan_receipt_view.dart';
import '../../ui/features/settings/views/settings_view.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardView()),
    GoRoute(path: '/expenses', builder: (context, state) => const ExpensesView()),
    GoRoute(path: '/expenses/new', builder: (context, state) => const ExpenseEditorView()),
    GoRoute(path: '/expenses/:id/edit', builder: (context, state) => ExpenseEditorView(expenseId: int.parse(state.pathParameters['id']!))),
    GoRoute(path: '/expenses/:id', builder: (context, state) => ExpenseDetailView(expenseId: int.parse(state.pathParameters['id']!))),
    GoRoute(path: '/scan', builder: (context, state) => const ScanReceiptView()),
    GoRoute(path: '/scan/review', builder: (context, state) => ReceiptReviewView(result: state.extra! as ScanResult)),
    GoRoute(path: '/reports', builder: (context, state) => const ReportsView()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsView()),
  ],
);

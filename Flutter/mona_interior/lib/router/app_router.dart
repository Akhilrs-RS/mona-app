import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_interior/screens/dashboard_screen.dart';
import 'package:mona_interior/screens/main_scaffold.dart';
import 'package:mona_interior/screens/crm_screen.dart';
import 'package:mona_interior/screens/sites_screen.dart';

// Finance Screens
import 'package:mona_interior/screens/finance/billing_screen.dart';
import 'package:mona_interior/screens/finance/invoices_screen.dart';
import 'package:mona_interior/screens/finance/receipts_screen.dart';
import 'package:mona_interior/screens/finance/expenses_screen.dart';
import 'package:mona_interior/screens/finance/accounts_screen.dart';

// HR Screens
import 'package:mona_interior/screens/hr/employees_screen.dart';
import 'package:mona_interior/screens/hr/attendance_screen.dart';
import 'package:mona_interior/screens/hr/salary_screen.dart';
import 'package:mona_interior/screens/hr/reports_screen.dart';

// Quotes
import 'package:mona_interior/screens/quotations_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
          GoRoute(path: '/crm', builder: (context, state) => const CrmScreen()),
          GoRoute(path: '/quotations', builder: (context, state) => const QuotationsScreen()),
          GoRoute(path: '/sites', builder: (context, state) => const SitesScreen()),
          
          GoRoute(path: '/billing', builder: (context, state) => const BillingScreen()),
          GoRoute(path: '/invoices', builder: (context, state) => const InvoicesScreen()),
          GoRoute(path: '/receipts', builder: (context, state) => const ReceiptsScreen()),
          GoRoute(path: '/expenses', builder: (context, state) => const ExpensesScreen()),
          GoRoute(path: '/accounts', builder: (context, state) => const AccountsScreen()),
          
          GoRoute(path: '/employees', builder: (context, state) => const EmployeesScreen()),
          GoRoute(path: '/attendance', builder: (context, state) => const AttendanceScreen()),
          GoRoute(path: '/salary', builder: (context, state) => const SalaryScreen()),
          GoRoute(path: '/reports', builder: (context, state) => const ReportsScreen()),
        ],
      ),
    ],
  );
});

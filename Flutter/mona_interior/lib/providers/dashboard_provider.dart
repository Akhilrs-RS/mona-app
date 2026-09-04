import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/api/api_client.dart';
import 'package:mona_interior/models/dashboard_data.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final dio = ref.watch(dioProvider);

  try {
    // Fetch all required data concurrently
    final responses = await Future.wait([
      dio.get('/finance/receipts'),
      dio.get('/finance/expenses'),
      dio.get('/sites'),
      dio.get('/finance/payroll'),
      dio.get('/employees'),
      dio.get('/quotations'),
      dio.get('/attendance'),
    ]);

    final receipts = responses[0].data as List<dynamic>? ?? [];
    final expenses = responses[1].data as List<dynamic>? ?? [];
    final sites = responses[2].data as List<dynamic>? ?? [];
    final payroll = responses[3].data as List<dynamic>? ?? [];
    final employees = responses[4].data as List<dynamic>? ?? [];
    final quotations = responses[5].data as List<dynamic>? ?? [];
    final attendance = responses[6].data as Map<String, dynamic>? ?? {};

    // For simplicity in mobile view, we'll calculate all-time or 
    // current state without complex date filtering initially.
    
    // Expenses Calculation
    double creditExpenses = 0;
    double debitExpenses = 0;
    for (var e in expenses) {
      final type = e['type'];
      final amount = double.tryParse(e['amount']?.toString() ?? '0') ?? 0;
      if (type == 'Bank Credit' || type == 'Credit') {
        creditExpenses += amount;
      } else {
        debitExpenses += amount;
      }
    }

    // Receipts Calculation
    double receiptIncome = 0;
    for (var r in receipts) {
      receiptIncome += double.tryParse(r['amountPaid']?.toString() ?? r['amount']?.toString() ?? '0') ?? 0;
    }

    // Payroll Calculation
    double totalPayroll = 0;
    for (var p in payroll) {
      totalPayroll += double.tryParse(p['netPay']?.toString() ?? p['amount']?.toString() ?? '0') ?? 0;
    }

    // Sites Work Order Value
    double totalWOValue = 0;
    int inProcessSites = 0;
    int pendingWO = 0;
    for (var s in sites) {
      totalWOValue += double.tryParse(s['budget']?.toString() ?? '0') ?? 0;
      final status = s['status'];
      if (status == 'In Progress' || status == 'Active') inProcessSites++;
      if (status == 'Pre-Construction' || status == 'Pending') pendingWO++;
    }

    // Employees Advances
    double totalAdvances = 0;
    for (var e in employees) {
      totalAdvances += double.tryParse(e['advanceBalance']?.toString() ?? '0') ?? 0;
    }

    // Pending Quotations
    int pendingQuotes = 0;
    for (var q in quotations) {
      if (q['status'] == 'Pending' || q['status'] == null) pendingQuotes++;
    }

    // Attendance for today
    int presentToday = 0;
    final now = DateTime.now();
    final todayStr = "\${now.year}-\${now.month.toString().padLeft(2, '0')}-\${now.day.toString().padLeft(2, '0')}";
    if (attendance.containsKey(todayStr)) {
      final todayAttendance = attendance[todayStr] as Map<String, dynamic>;
      for (var status in todayAttendance.values) {
        if (status == 'Present' || status == 'Half-Day') presentToday++;
      }
    }

    final totalIncome = receiptIncome + creditExpenses;
    final totalSpent = debitExpenses + totalPayroll;
    final netProfit = totalIncome - totalSpent;

    return DashboardData(
      totalIncome: totalIncome,
      totalSpent: totalSpent,
      netProfit: netProfit,
      totalWOValue: totalWOValue,
      pendingQuotes: pendingQuotes,
      inProcessSites: inProcessSites,
      pendingWO: pendingWO,
      totalPayroll: totalPayroll,
      totalAdvances: totalAdvances,
      presentToday: presentToday,
      receipts: receipts,
      expenses: expenses,
      payroll: payroll,
      sites: sites,
    );
  } catch (e) {
    // Return empty on error or handle appropriately
    return DashboardData.empty();
  }
});

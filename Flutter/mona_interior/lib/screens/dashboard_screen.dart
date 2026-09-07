import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/dashboard_provider.dart';
import 'package:mona_interior/widgets/kpi_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mona_interior/models/dashboard_data.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/theme/app_colors.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _activePreset = 'this_month';
  DateTime _dateFrom = DateTime.now();
  DateTime _dateTo = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setPreset('this_month');
  }

  void _setPreset(String preset) {
    setState(() {
      _activePreset = preset;
      final now = DateTime.now();
      if (preset == 'this_month') {
        _dateFrom = DateTime(now.year, now.month, 1);
        _dateTo = now;
      } else if (preset == 'last_month') {
        _dateFrom = DateTime(now.year, now.month - 1, 1);
        _dateTo = DateTime(now.year, now.month, 0);
      } else if (preset == 'last_6_months') {
        _dateFrom = DateTime(now.year, now.month - 6, now.day);
        _dateTo = now;
      } else if (preset == 'financial_year') {
        final startYear = now.month >= 4 ? now.year : now.year - 1;
        _dateFrom = DateTime(startYear, 4, 1);
        _dateTo = DateTime(startYear + 1, 3, 31);
      }
    });
  }

  bool _inRange(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return false;
    try {
      final date = DateTime.parse(dateStr);
      return date.isAfter(_dateFrom.subtract(const Duration(days: 1))) && 
             date.isBefore(_dateTo.add(const Duration(days: 1)));
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardProvider);
    final fmt = (num n) => '₹${n.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          // --- Calculate filtered KPIs ---
          double creditExpenses = 0;
          double debitExpenses = 0;
          int expensesCount = 0;
          for (var e in data.expenses.where((e) => _inRange(e['date']))) {
            final type = e['type'];
            final amount = double.tryParse(e['amount']?.toString() ?? '0') ?? 0;
            if (type == 'Bank Credit' || type == 'Credit') creditExpenses += amount;
            else { debitExpenses += amount; expensesCount++; }
          }

          double receiptIncome = 0;
          int receiptsCount = 0;
          for (var r in data.receipts.where((r) => _inRange(r['date']))) {
            receiptIncome += double.tryParse(r['amountPaid']?.toString() ?? r['amount']?.toString() ?? '0') ?? 0;
            receiptsCount++;
          }

          double totalPayroll = 0;
          for (var p in data.payroll.where((p) => _inRange(p['paymentDate'] ?? p['date']))) {
            totalPayroll += double.tryParse(p['netPay']?.toString() ?? p['amount']?.toString() ?? '0') ?? 0;
          }

          final totalIncome = receiptIncome + creditExpenses;
          final totalSpent = debitExpenses + totalPayroll;
          final netProfit = totalIncome - totalSpent;
          
          double workOrderRevenue = 0;
          for (var s in data.sites) {
            workOrderRevenue += double.tryParse(s['totalCost']?.toString() ?? '0') ?? 0;
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(dashboardProvider),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1100;
                  return ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildHeader(isDesktop),
                      const SizedBox(height: 24),
                      _buildPrimaryKPIs(data, totalIncome, totalSpent, workOrderRevenue, netProfit, receiptsCount, expensesCount, isDesktop),
                      const SizedBox(height: 16),
                      _buildSecondaryKPIs(data, totalPayroll, isDesktop),
                      const SizedBox(height: 24),
                      _buildMainContent(data, isDesktop),
                      const SizedBox(height: 32),
                    ],
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    final headerContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Executive Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
        const SizedBox(height: 4),
        Text('REAL-TIME BUSINESS INTELLIGENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey[500], letterSpacing: 1.5)),
      ],
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('PERIOD', style: TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(
                    height: 20,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _activePreset,
                        isDense: true,
                        icon: const Icon(LucideIcons.chevron_down, size: 14),
                        items: const [
                          DropdownMenuItem(value: 'this_month', child: Text('This Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'last_month', child: Text('Last Month', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'last_6_months', child: Text('Last 6 Months', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                          DropdownMenuItem(value: 'financial_year', child: Text('Financial Year', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                        ],
                        onChanged: (val) => _setPreset(val ?? 'this_month'),
                      ),
                    ),
                  ),
                ],
              ),
              if (isDesktop) ...[
                const SizedBox(width: 16),
                Container(width: 1, height: 24, color: Colors.grey.withValues(alpha: 0.2)),
                const SizedBox(width: 16),
                Text(DateFormat('dd/MM/yyyy').format(_dateFrom), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
                const SizedBox(width: 8),
                const Icon(LucideIcons.arrow_right, size: 12, color: Colors.grey),
                const SizedBox(width: 8),
                Text(DateFormat('dd/MM/yyyy').format(_dateTo), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(width: 8),
                const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
              ]
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          ),
          child: IconButton(
            icon: Icon(LucideIcons.bell, size: 20, color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[300] : const Color(0xFF4B5563)),
            onPressed: () {},
          ),
        )
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: headerContent),
          controls,
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          headerContent,
          const SizedBox(height: 16),
          controls,
        ],
      );
    }
  }

  Widget _buildPrimaryKPIs(DashboardData data, double totalIncome, double totalSpent, double workOrderRev, double netProfit, int receiptsCount, int expensesCount, bool isDesktop) {
    final fmt = (num n) => '₹${n.toStringAsFixed(0)}';
    
    final cards = [
      Expanded(child: KpiCard(label: 'TOTAL INCOME', value: fmt(totalIncome), icon: LucideIcons.trending_up, color: Colors.green, sub: '$receiptsCount receipts')),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'TOTAL SPENT', value: fmt(totalSpent), icon: LucideIcons.trending_down, color: Colors.red, sub: '$expensesCount entries')),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'WORK ORDER REVENUE', value: fmt(workOrderRev), icon: LucideIcons.building, color: AppColors.primaryGold, sub: '${data.sites.length} total projects')),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'NET PROFIT / LOSS', value: (netProfit >= 0 ? '+' : '') + fmt(netProfit), icon: LucideIcons.indian_rupee, color: Colors.teal, sub: 'Income minus expenses')),
    ];

    if (isDesktop) {
      return Row(children: cards);
    } else {
      return Column(
        children: [
          Row(children: [cards[0], cards[1], cards[2]]),
          const SizedBox(height: 16),
          Row(children: [cards[4], cards[5], cards[6]]),
        ],
      );
    }
  }

  Widget _buildSecondaryKPIs(DashboardData data, double totalPayroll, bool isDesktop) {
    final fmt = (num n) => '₹${n.toStringAsFixed(0)}';
    int pendingWO = data.pendingWO;
    int inProcess = data.inProcessSites;

    final cards = [
      Expanded(child: KpiCard(label: 'PENDING QUOTATIONS', value: '0', icon: LucideIcons.file_text, color: Colors.brown[300]!, showLeftBorder: false, valueColor: Colors.brown[700])),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'IN-PROCESS SITES', value: '$inProcess', icon: LucideIcons.hard_hat, color: Colors.blueGrey, showLeftBorder: false, valueColor: Colors.blueGrey[700])),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'PENDING WORK ORDERS', value: '$pendingWO', icon: LucideIcons.clipboard_check, color: Colors.lightBlue, showLeftBorder: false, valueColor: Colors.lightBlue[700])),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'TOTAL PAYROLL', value: fmt(totalPayroll), icon: LucideIcons.banknote, color: Colors.indigo[300]!, showLeftBorder: false, valueColor: Colors.indigo[700])),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'TOTAL ADVANCES', value: '₹0', icon: LucideIcons.wallet, color: Colors.pinkAccent[100]!, showLeftBorder: false, valueColor: Colors.pinkAccent[700])),
      const SizedBox(width: 16, height: 16),
      Expanded(child: KpiCard(label: 'PRESENT TODAY', value: '0 staff', icon: LucideIcons.calendar_check, color: Colors.teal[300]!, showLeftBorder: false, valueColor: Colors.teal[700])),
    ];

    if (isDesktop) {
      return Row(children: cards);
    } else {
      return Column(
        children: [
          Row(children: [cards[0], cards[1], cards[2]]),
          const SizedBox(height: 16),
          Row(children: [cards[4], cards[5], cards[6]]),
          const SizedBox(height: 16),
          Row(children: [cards[8], cards[9], cards[10]]),
        ],
      );
    }
  }

  Widget _buildMainContent(DashboardData data, bool isDesktop) {
    Widget leftCol = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFinancialTrajectory(data),
        const SizedBox(height: 16),
        _buildExpenseCategories(data),
      ],
    );

    Widget rightCol = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSiteStatus(data),
        const SizedBox(height: 16),
        _buildQuickActions(),
      ],
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: leftCol),
          const SizedBox(width: 16),
          Expanded(flex: 1, child: rightCol),
        ],
      );
    } else {
      return Column(
        children: [leftCol, const SizedBox(height: 16), rightCol],
      );
    }
  }

  Widget _buildCardBase({required String title, required String subtitle, required Widget child, Widget? trailing}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
              if (trailing != null) trailing
            ],
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildFinancialTrajectory(DashboardData data) {
    return _buildCardBase(
      title: 'Financial Trajectory',
      subtitle: 'Income vs Expenses — last 6 months',
      trailing: Row(
        children: [
          _buildLegend('INCOME', Colors.green),
          const SizedBox(width: 16),
          _buildLegend('EXPENSES', Colors.red),
        ],
      ),
      child: _buildCashFlowChart(data),
    );
  }

  Widget _buildExpenseCategories(DashboardData data) {
    return _buildCardBase(
      title: 'Expense Categories',
      subtitle: 'Breakdown by classification (current period)',
      child: _buildExpenseChart(data),
    );
  }

  Widget _buildSiteStatus(DashboardData data) {
    return _buildCardBase(
      title: 'Site Status',
      subtitle: 'Work order breakdown',
      child: _buildSiteStatusChart(data),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
        const SizedBox(height: 12),
        _buildActionTile('New Quotation', 'Create & send', AppColors.primaryGold),
        const SizedBox(height: 8),
        _buildActionTile('New Receipt', 'Log a payment', Colors.green),
        const SizedBox(height: 8),
        _buildActionTile('Log Expense', 'Record a spend', Colors.red),
        const SizedBox(height: 8),
        _buildActionTile('Add Staff', 'HR management', Colors.indigo),
        const SizedBox(height: 8),
        _buildActionTile('Work Orders', 'Manage sites', Colors.indigo),
      ],
    );
  }

  Widget _buildActionTile(String title, String sub, Color borderCol) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: borderCol, width: 4)),
          ),
          child: Material(
            color: Colors.transparent,
            child: ListTile(
              title: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              subtitle: Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              trailing: Icon(LucideIcons.arrow_right, size: 16, color: Colors.grey[400]),
              onTap: () {},
              dense: true,
              visualDensity: VisualDensity.compact,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashFlowChart(DashboardData data) {
    // Group data by month
    final Map<String, _MonthData> months = {};
    for (int i = 5; i >= 0; i--) {
      final dt = DateTime(DateTime.now().year, DateTime.now().month - i, 1);
      final key = "\${dt.year}-\${dt.month.toString().padLeft(2, '0')}";
      months[key] = _MonthData(DateFormat('MMM').format(dt));
    }

    for (var r in data.receipts) {
      if (r['date'] != null && r['date'].length >= 7) {
        final m = r['date'].substring(0, 7);
        if (months.containsKey(m)) months[m]!.income += (double.tryParse(r['amountPaid']?.toString() ?? r['amount']?.toString() ?? '0') ?? 0);
      }
    }

    for (var e in data.expenses) {
      if (e['date'] != null && e['date'].length >= 7) {
        final m = e['date'].substring(0, 7);
        if (months.containsKey(m)) {
          final amt = double.tryParse(e['amount']?.toString() ?? '0') ?? 0;
          if (e['type'] == 'Bank Credit' || e['type'] == 'Credit') months[m]!.income += amt;
          else months[m]!.expense += amt;
        }
      }
    }

    for (var p in data.payroll) {
      final date = p['paymentDate'] ?? p['date'];
      if (date != null && date.length >= 7) {
        final m = date.substring(0, 7);
        if (months.containsKey(m)) {
          months[m]!.expense += double.tryParse(p['netPay']?.toString() ?? p['amount']?.toString() ?? '0') ?? 0;
        }
      }
    }

    final values = months.values.toList();
    if (values.isEmpty) return const SizedBox(height: 300, child: Center(child: Text('No data')));

    double maxY = 0;
    for (var v in values) {
      if (v.income > maxY) maxY = v.income;
      if (v.expense > maxY) maxY = v.expense;
    }
    maxY = maxY == 0 ? 10 : maxY * 1.2; // Avoid zero max

    return Container(
      height: 300,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true, 
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1, dashArray: [5, 5]),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value >= 1000 ? '₹\${(value/1000).toStringAsFixed(0)}k' : '₹\${value.toStringAsFixed(0)}', style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold));
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= values.length) return const Text('');
                  return Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Text(values[index].name, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.income)).toList(),
              isCurved: false,
              color: Colors.green,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expense)).toList(),
              isCurved: false,
              color: Colors.red,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteStatusChart(DashboardData data) {
    int completed = 0;
    for (var s in data.sites) {
      if (s['status'] == 'Completed') completed++;
    }

    final List<PieChartSectionData> sections = [];
    if (data.inProcessSites > 0) sections.add(PieChartSectionData(value: data.inProcessSites.toDouble(), color: Colors.blue, title: '\${data.inProcessSites}'));
    if (data.pendingWO > 0) sections.add(PieChartSectionData(value: data.pendingWO.toDouble(), color: Colors.orange, title: '\${data.pendingWO}'));
    if (completed > 0) sections.add(PieChartSectionData(value: completed.toDouble(), color: Colors.green, title: '\$completed'));

    if (sections.isEmpty) return SizedBox(height: 300, child: Center(child: Text('No site data', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold))));

    return Container(
      height: 300,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 60,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('In Progress', Colors.blue),
              const SizedBox(width: 16),
              _buildLegend('Pre-Construction', Colors.orange),
              const SizedBox(width: 16),
              _buildLegend('Completed', Colors.green),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildExpenseChart(DashboardData data) {
    final Map<String, double> cats = {};
    for (var e in data.expenses.where((e) => _inRange(e['date']) && e['type'] != 'Bank Credit' && e['type'] != 'Credit')) {
      final c = e['category'] ?? 'Other';
      cats[c] = (cats[c] ?? 0) + (double.tryParse(e['amount']?.toString() ?? '0') ?? 0);
    }
    for (var p in data.payroll.where((p) => _inRange(p['paymentDate'] ?? p['date']))) {
      cats['Payroll'] = (cats['Payroll'] ?? 0) + (double.tryParse(p['netPay']?.toString() ?? p['amount']?.toString() ?? '0') ?? 0);
    }

    final sortedCats = cats.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topCats = sortedCats.take(5).toList();

    if (topCats.isEmpty) return SizedBox(height: 300, child: Center(child: Text('No expense data for period', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold))));

    final double maxY = topCats.isEmpty ? 1000 : topCats.first.value * 1.2;

    return Container(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= topCats.length) return const Text('');
                  String text = topCats[index].key;
                  if (text.length > 8) text = text.substring(0, 8) + '...';
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(text, style: TextStyle(fontSize: 10, color: Colors.grey[600], fontWeight: FontWeight.bold)),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: topCats.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value,
                  color: Colors.indigo,
                  width: 32,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                )
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLegend(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black)),
      ],
    );
  }
}

class _MonthData {
  final String name;
  double income = 0;
  double expense = 0;
  _MonthData(this.name);
}

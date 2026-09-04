import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/dashboard_provider.dart';
import 'package:mona_interior/widgets/kpi_card.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:mona_interior/models/dashboard_data.dart';

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
      appBar: AppBar(
        title: const Text('Executive Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(dashboardProvider),
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) {
          // --- Calculate filtered KPIs ---
          double creditExpenses = 0;
          double debitExpenses = 0;
          for (var e in data.expenses.where((e) => _inRange(e['date']))) {
            final type = e['type'];
            final amount = double.tryParse(e['amount']?.toString() ?? '0') ?? 0;
            if (type == 'Bank Credit' || type == 'Credit') creditExpenses += amount;
            else debitExpenses += amount;
          }

          double receiptIncome = 0;
          for (var r in data.receipts.where((r) => _inRange(r['date']))) {
            receiptIncome += double.tryParse(r['amountPaid']?.toString() ?? r['amount']?.toString() ?? '0') ?? 0;
          }

          double totalPayroll = 0;
          for (var p in data.payroll.where((p) => _inRange(p['paymentDate'] ?? p['date']))) {
            totalPayroll += double.tryParse(p['netPay']?.toString() ?? p['amount']?.toString() ?? '0') ?? 0;
          }

          final totalIncome = receiptIncome + creditExpenses;
          final totalSpent = debitExpenses + totalPayroll;
          final netProfit = totalIncome - totalSpent;
          final profitPositive = netProfit >= 0;

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(dashboardProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildDateFilter(),
                const SizedBox(height: 24),
                const Text('Primary Financial KPIs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                KpiCard(
                  label: 'Total Income',
                  value: fmt(totalIncome),
                  icon: Icons.trending_up,
                  color: Colors.green,
                ),
                const SizedBox(height: 8),
                KpiCard(
                  label: 'Total Spent',
                  value: fmt(totalSpent),
                  icon: Icons.trending_down,
                  color: Colors.red,
                ),
                const SizedBox(height: 8),
                KpiCard(
                  label: 'Net Profit',
                  value: fmt(netProfit),
                  icon: Icons.account_balance_wallet,
                  color: profitPositive ? Colors.green : Colors.red,
                  sub: profitPositive ? 'Profitable' : 'Loss',
                ),
                const SizedBox(height: 24),
                const Text('Cash Flow Trajectory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildCashFlowChart(data),
                const SizedBox(height: 24),
                const Text('Site Status Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildSiteStatusChart(data),
                const SizedBox(height: 24),
                const Text('Top Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildExpenseChart(data),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _activePreset,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'this_month', child: Text('This Month')),
            DropdownMenuItem(value: 'last_month', child: Text('Last Month')),
            DropdownMenuItem(value: 'last_6_months', child: Text('Last 6 Months')),
            DropdownMenuItem(value: 'financial_year', child: Text('Financial Year')),
          ],
          onChanged: (val) => _setPreset(val ?? 'this_month'),
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
    if (values.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No data')));

    double maxY = 0;
    for (var v in values) {
      if (v.income > maxY) maxY = v.income;
      if (v.expense > maxY) maxY = v.expense;
    }
    maxY = maxY == 0 ? 1000 : maxY * 1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(value >= 1000 ? '\${(value/1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0), style: const TextStyle(fontSize: 10));
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
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(values[index].name, style: const TextStyle(fontSize: 10)),
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
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.green.withValues(alpha: 0.2)),
            ),
            LineChartBarData(
              spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.expense)).toList(),
              isCurved: true,
              color: Colors.red,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(show: true, color: Colors.red.withValues(alpha: 0.2)),
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

    if (sections.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No site data')));

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegend('In Progress', Colors.blue),
              const SizedBox(height: 8),
              _buildLegend('Pre-Construction', Colors.orange),
              const SizedBox(height: 8),
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

    if (topCats.isEmpty) return const SizedBox(height: 200, child: Center(child: Text('No expense data')));

    final double maxY = topCats.isEmpty ? 1000 : topCats.first.value * 1.2;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
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
                    child: Text(text, style: const TextStyle(fontSize: 10)),
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
                  color: Colors.purple,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
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
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 12)),
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

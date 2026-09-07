import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 24),
          _buildKPICards(isDark),
          const SizedBox(height: 24),
          _buildMainGrid(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(LucideIcons.activity, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reports & Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Generate comprehensive reports and monitor real-time business metrics.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[400])),
          ],
        ),),
        // const Spacer(),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
          ),
          child: const Icon(LucideIcons.bell, size: 18, color: Colors.blueGrey),
        ),
      ],
    );
  }

  Widget _buildKPICards(bool isDark) {
    return Row(
      children: [
        _buildKPICard('TOTAL INFLOW', '₹0.00L', Icons.trending_up, Colors.green, isDark),
        const SizedBox(width: 16),
        _buildKPICard('TOTAL OUTFLOW', '₹0.00L', Icons.trending_down, Colors.red, isDark),
        const SizedBox(width: 16),
        _buildKPICard('CRM LEADS', '0', LucideIcons.users, Colors.blueGrey[400]!, isDark),
        const SizedBox(width: 16),
        _buildKPICard('ACTIVE PROJECTS', '0', LucideIcons.clipboard, AppColors.primaryGold, isDark),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color iconColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
          boxShadow: [
            if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 12, color: iconColor),
                const SizedBox(width: 6),
                Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
              ],
            ),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF1F2937))),
          ],
        ),
      ),
    );
  }

  Widget _buildMainGrid(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column (Charts)
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildChartCard(
                title: 'CASHFLOW OVERVIEW (6 MONTHS)',
                icon: LucideIcons.activity,
                height: 300,
                isDark: isDark,
                child: _buildMockLineChart(isDark),
              ),
              const SizedBox(height: 16),
              _buildChartCard(
                title: 'CRM LEAD SOURCES',
                icon: Icons.pie_chart,
                height: 250,
                isDark: isDark,
                child: const SizedBox(), // empty state for pie chart
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Right Column (Generator)
        Expanded(
          flex: 3,
          child: _buildGeneratorPanel(isDark),
        ),
      ],
    );
  }

  Widget _buildChartCard({required String title, required IconData icon, required double height, required bool isDark, required Widget child}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primaryGold),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[800])),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildMockLineChart(bool isDark) {
    final yLabels = ['₹0.004k', '₹0.003k', '₹0.002k', '₹0.001k', '₹0k'];
    final xLabels = ['Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Y-axis labels
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: yLabels.map((l) => Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey[400]))).toList(),
        ),
        const SizedBox(width: 16),
        // Grid area
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Horizontal lines
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(5, (index) => Container(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200])),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // X-axis labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: xLabels.map((l) => Text(l, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey[400]))).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGeneratorPanel(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFC9A227), // Gold
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Report Generator', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('Select a dataset to compile into a downloadable document.', style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 32),
          Text('SELECT DATASET', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 8),
          Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Expanded(child: Text('Invoice History', style: TextStyle(fontSize: 12, color: Colors.white))),
                Icon(LucideIcons.chevron_down, size: 16, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildGeneratorAction('View Report', LucideIcons.file_text),
          const SizedBox(height: 12),
          _buildGeneratorAction('Download as PDF', LucideIcons.download),
          const SizedBox(height: 12),
          _buildGeneratorAction('Download as Excel', LucideIcons.file_spreadsheet),
        ],
      ),
    );
  }

  Widget _buildGeneratorAction(String text, IconData icon) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}

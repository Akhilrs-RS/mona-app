import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
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
          _buildTopNav(),
          const SizedBox(height: 24),
          _buildKPICards(isDark),
          const SizedBox(height: 16),
          _buildActionBar(isDark),
          const SizedBox(height: 16),
          _buildTableContainer(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(LucideIcons.users, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Attendance Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Track daily attendance, overtime, and export reports.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[400])),
          ],
        ),),
        // 
        _buildHeaderAction(LucideIcons.file_text, 'Export PDF', Colors.red),
        const SizedBox(width: 12),
        _buildHeaderAction(LucideIcons.file_spreadsheet, 'Export Excel', Colors.green),
        const SizedBox(width: 16),
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

  Widget _buildHeaderAction(IconData icon, String label, Color color) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTopNav() {
    return Row(
      children: [
        _buildNavItem('Daily Entry', LucideIcons.clock, true),
        const SizedBox(width: 32),
        _buildNavItem('Date History', LucideIcons.calendar, false),
        const SizedBox(width: 32),
        _buildNavItem('Weekly Summary', LucideIcons.calendar_days, false),
        const SizedBox(width: 32),
        _buildNavItem('Monthly Summary', Icons.bar_chart, false),
      ],
    );
  }

  Widget _buildNavItem(String label, IconData icon, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isActive ? AppColors.primaryGold : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: isActive ? AppColors.primaryGold : Colors.blueGrey[400]),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.primaryGold : Colors.blueGrey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICards(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
                Text('SELECTED DATE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(LucideIcons.calendar, size: 20, color: AppColors.primaryGold),
                    const SizedBox(width: 8),
                    Text('04/09/2026', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF1F2937))),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        _buildKPICard('PRESENT', '0', Colors.green, isDark),
        const SizedBox(width: 16),
        _buildKPICard('HALF DAY', '0', Colors.orange, isDark),
        const SizedBox(width: 16),
        _buildKPICard('ABSENT', '0', Colors.red, isDark),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, Color valueColor, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
            Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
            const SizedBox(height: 12),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(bool isDark) {
    return Row(
      children: [
        const Text('Mark All Present', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGold)),
        
        // Save Draft
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange[50],
            border: Border.all(color: isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange[200]!),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.file, size: 14, color: Colors.orange[800]),
              const SizedBox(width: 8),
              Text('Save Draft', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[800])),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Save & Lock
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primaryGold,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.lock, size: 14, color: Colors.white),
              SizedBox(width: 8),
              Text('Save & Lock', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableContainer(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
        boxShadow: [
          if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Search
                Container(
                  width: 300,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.search, size: 14, color: Colors.blueGrey[300]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by name or phone...',
                            hintStyle: TextStyle(fontSize: 12, color: Colors.blueGrey[300]),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(bottom: 2),
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Roles Dropdown
                _buildDropdown('ALL ROLES', isDark),

                // Status Dropdown
                _buildDropdown('ALL STATUS', isDark),
              ],
            ),
          ),
          
          // Table Headers
          Container(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildColHeader('STAFF DETAILS', flex: 3),
                _buildColHeader('ROLE', flex: 2),
                _buildColHeader('STATUS', flex: 2),
                _buildColHeader('OVERTIME (HRS)', flex: 2),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
          
          // Empty State Body
          Container(
            height: 300, 
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No staff found.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey[400])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, bool isDark) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          const SizedBox(width: 8),
          Icon(LucideIcons.chevron_down, size: 14, color: Colors.grey[500]),
        ],
      ),
    );
  }

  Widget _buildColHeader(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400]),
      ),
    );
  }
}

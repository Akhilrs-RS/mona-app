import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/widgets/forms/employee_form.dart';

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          _buildHeader(isDark),
          const SizedBox(height: 24),
          _buildKPICards(isDark),
          const SizedBox(height: 24),
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
            Text('Staff Directory', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Manage employee profiles, roles, and payroll setups.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[400])),
          ],
        ),),
        // 
        _buildHeaderAction(LucideIcons.file_text, 'PDF', Colors.red, isDark),
        const SizedBox(width: 12),
        _buildHeaderAction(LucideIcons.file_spreadsheet, 'Excel', Colors.green, isDark),
        const SizedBox(width: 12),
        InkWell(
          onTap: () {
            showDialog(context: context, builder: (_) => const EmployeeForm());
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primaryGold,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.plus, size: 14, color: Colors.white),
                SizedBox(width: 6),
                Text('Add Staff', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
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

  Widget _buildHeaderAction(IconData icon, String label, Color color, bool isDark) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
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

  Widget _buildKPICards(bool isDark) {
    return Row(
      children: [
        _buildKPICard('TOTAL STAFF', '0', isDark ? AppColors.textLight : const Color(0xFF1F2937), LucideIcons.users, isDark),
        const SizedBox(width: 16),
        _buildKPICard('ACTIVE', '0', Colors.green, null, isDark),
        const SizedBox(width: 16),
        _buildKPICard('INACTIVE', '0', Colors.red, null, isDark),
        const SizedBox(width: 16),
        _buildKPICard('MONTHLY PAYROLL', '₹0', AppColors.primaryGold, LucideIcons.wallet, isDark),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, Color valueColor, IconData? icon, bool isDark) {
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                const SizedBox(height: 12),
                Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: valueColor)),
              ],
            ),
            if (icon != null) Icon(icon, size: 16, color: Colors.blueGrey[300]),
          ],
        ),
      ),
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
                            hintText: 'Search by name, ID or phone...',
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

                // View Toggles
                Icon(LucideIcons.list, size: 18, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Icon(LucideIcons.layout_grid, size: 18, color: Colors.blueGrey[200]),
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
                _buildColHeader('EMPLOYEE', flex: 3),
                _buildColHeader('CONTACT', flex: 2),
                _buildColHeader('ROLE & STATUS', flex: 2),
                _buildColHeader('SALARY SETUP', flex: 2),
                _buildColHeader('ACTIONS', flex: 1, alignRight: true),
              ],
            ),
          ),
          Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
          
          // Empty State Body
          Container(
            height: 350, 
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('No employees match your search.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey[400])),
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

  Widget _buildColHeader(String text, {required int flex, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400]),
      ),
    );
  }
}

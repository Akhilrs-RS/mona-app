import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:mona_interior/widgets/forms/bulk_expense_form.dart';
import 'package:mona_interior/widgets/forms/credit_form.dart';
import 'package:mona_interior/widgets/forms/expense_form.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
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
          _buildTableContainer(isDark),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.request_quote, color: AppColors.primaryGold, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expenses Management', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Track client material costs & business overhead separately.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[400])),
          ],
        ),),
        // 
        // Monthly / Financial Year Toggle
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Monthly', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('Financial Year', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey[600])),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // Bulk Entry Button
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => const BulkExpenseForm(),
            );
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              border: Border.all(color: Colors.orange[200]!),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(LucideIcons.list, size: 14, color: Colors.orange[800]),
                const SizedBox(width: 8),
                Text('Bulk Entry', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange[800])),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Input Credit Button
        InkWell(
          onTap: () {
            showDialog(context: context, builder: (_) => const CreditForm());
          },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.trending_up, size: 14, color: Colors.white),
                SizedBox(width: 8),
                Text('Input Credit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Log Expense Button
        InkWell(
          onTap: () {
            showDialog(context: context, builder: (_) => const ExpenseForm());
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
                SizedBox(width: 8),
                Text('Log Expense', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
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

  Widget _buildKPICards(bool isDark) {
    return Row(
      children: [
        _buildKPICard(
          title: 'TOTAL EXPENSES',
          value: '₹0',
          valueColor: isDark ? AppColors.textLight : const Color(0xFF1F2937),
          subtitle: 'Monthly view',
          icon: LucideIcons.layers,
          iconColor: Colors.blueGrey[400],
          iconBg: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          border: false,
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        _buildKPICard(
          title: 'CLIENT EXPENSES',
          value: '₹0',
          valueColor: Colors.orange[700]!,
          subtitle: 'Materials & procurement',
          icon: LucideIcons.user,
          iconColor: Colors.orange[700],
          iconBg: isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange[50],
          border: true,
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        _buildKPICard(
          title: 'OVERHEAD EXPENSES',
          value: '₹0',
          valueColor: Colors.orange[700]!,
          subtitle: 'Rent, utilities & ops',
          icon: LucideIcons.building,
          iconColor: Colors.orange[700],
          iconBg: isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange[50],
          border: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required Color valueColor,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Color? iconBg,
    required bool border,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
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
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                const SizedBox(height: 12),
                Text(value, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: valueColor)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!border) ...[
                      Icon(icon, size: 12, color: Colors.blueGrey[400]),
                      const SizedBox(width: 4),
                    ],
                    Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[300])),
                  ],
                ),
              ],
            ),
            if (border)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor!.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              )
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
                // Type toggle
                _buildSegmentedToggle(['ALL', 'CLIENT', 'OVERHEAD', 'CREDIT'], 0, isDark),
                
                // Search
                Container(
                  width: 260,
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
                            hintText: 'Search expenses...',
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
                _buildColHeader('TYPE', flex: 2),
                _buildColHeader('DATE', flex: 2),
                _buildColHeader('DETAILS', flex: 4),
                _buildColHeader('CATEGORY / CLIENT', flex: 3),
                _buildColHeader('QTY / UNIT', flex: 2, alignRight: true),
                _buildColHeader('COST (₹)', flex: 2, alignRight: true),
                _buildColHeader('ACTIONS', flex: 2, alignRight: true),
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
                Icon(Icons.filter_alt_outlined, size: 48, color: Colors.blueGrey[100]),
                const SizedBox(height: 16),
                Text('NO EXPENSES FOUND FOR THE SELECTED FILTERS.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[300])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedToggle(List<String> items, int selectedIndex, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final isSelected = entry.key == selectedIndex;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryGold : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              entry.value,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.blueGrey[400],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildColHeader(String text, {required int flex, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400]),
      ),
    );
  }
}

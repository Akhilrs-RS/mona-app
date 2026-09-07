import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
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
        const Icon(Icons.account_balance, color: AppColors.primaryGold, size: 20), // landmark/university
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account Statement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Read-only balance sheet — auto-synced from all modules.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[400])),
          ],
        ),),
        // 
        _buildTag(LucideIcons.calendar, '4 Sept 2026', isDark),
        const SizedBox(width: 12),
        _buildTag(LucideIcons.clock, '14:56:37', isDark),
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

  Widget _buildTag(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange[100]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.orange[800]),
          const SizedBox(width: 6),
          Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange[800])),
        ],
      ),
    );
  }

  Widget _buildKPICards(bool isDark) {
    return Row(
      children: [
        _buildKPICard(
          title: 'MONTHLY NET BALANCE',
          value: '₹0',
          valueColor: Colors.green,
          subtitle: 'Surplus',
          icon: null,
          iconBg: null,
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        _buildKPICard(
          title: 'TOTAL INFLOW',
          value: '₹0',
          valueColor: Colors.green,
          subtitle: 'Credits (Income)',
          icon: Icons.arrow_upward,
          iconColor: Colors.green,
          iconBg: isDark ? Colors.green.withValues(alpha: 0.1) : Colors.green[50],
          isDark: isDark,
        ),
        const SizedBox(width: 24),
        _buildKPICard(
          title: 'TOTAL OUTFLOW',
          value: '₹0',
          valueColor: Colors.red,
          subtitle: 'Debits (Expenses)',
          icon: Icons.arrow_downward,
          iconColor: Colors.red,
          iconBg: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red[50],
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
    IconData? icon,
    Color? iconColor,
    Color? iconBg,
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
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: valueColor)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[300])),
              ],
            ),
            if (icon != null)
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
                // Time toggle
                _buildSegmentedToggle(['MONTHLY', 'LAST MONTH', 'FINANCIAL YEAR', 'CUSTOM'], 0, isDark),

                // Type toggle
                _buildSegmentedToggle(['ALL', 'CREDIT', 'DEBIT'], 0, isDark),

                // Dropdown
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(width: 8),
                      Icon(LucideIcons.chevron_down, size: 14, color: Colors.grey[500]),
                    ],
                  ),
                ),
                
                // Search
                Container(
                  width: 220,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Icon(LucideIcons.search, size: 14, color: Colors.blueGrey[300]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search statement...',
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

                // PDF Button
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.download, size: 12, color: Colors.white),
                      SizedBox(width: 6),
                      Text('PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),

                // Excel Button
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.orange.withValues(alpha: 0.1) : Colors.orange[50],
                    border: Border.all(color: isDark ? Colors.orange.withValues(alpha: 0.2) : Colors.orange[200]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.file_spreadsheet, size: 12, color: Colors.orange[800]),
                      const SizedBox(width: 6),
                      Text('Excel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.orange[800])),
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
                _buildColHeader('DATE', flex: 2),
                _buildColHeader('DESCRIPTION', flex: 3),
                _buildColHeader('CATEGORY', flex: 2),
                _buildColHeader('DEBIT', flex: 2, alignRight: true),
                _buildColHeader('CREDIT', flex: 2, alignRight: true),
                _buildColHeader('RUNNING BALANCE', flex: 2, alignRight: true),
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
                Text('NO TRANSACTIONS FOUND FOR THE SELECTED FILTERS.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[300])),
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

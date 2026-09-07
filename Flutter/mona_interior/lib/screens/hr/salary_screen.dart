import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class SalaryScreen extends ConsumerStatefulWidget {
  const SalaryScreen({super.key});

  @override
  ConsumerState<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends ConsumerState<SalaryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            _buildHeader(isDark),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLeftPanel(isDark),
                  const SizedBox(width: 24),
                  _buildRightPanel(isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(LucideIcons.wallet, color: Colors.purple[700], size: 16),
        ),
        const SizedBox(width: 8),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payroll & Advances', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF111827))),
            const SizedBox(height: 2),
            Text('Process regular salaries, manage daily wages, and track advances.', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.blueGrey[400])),
          ],
        ),),
        // const Spacer(),
        // Bulk WhatsApp
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border.all(color: Colors.green[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.message_circle, size: 14, color: Colors.green[700]),
              const SizedBox(width: 6),
              Text('Bulk WhatsApp', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green[700])),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Date selector
        Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: Colors.blueGrey[400]),
              const SizedBox(width: 8),
              Text('September', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF1F2937))),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevron_down, size: 14, color: Colors.blueGrey[400]),
              const SizedBox(width: 8),
              Text('2024', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF1F2937))),
              const SizedBox(width: 4),
              Icon(LucideIcons.chevron_down, size: 14, color: Colors.blueGrey[400]),
            ],
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

  Widget _buildLeftPanel(bool isDark) {
    return Expanded(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.users, size: 16, color: Colors.blueGrey[300]),
                      const SizedBox(width: 8),
                      Text('SELECT STAFF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[800])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(LucideIcons.search, size: 16, color: Colors.blueGrey[300]),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search staff...',
                              hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[300]),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.only(bottom: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
            Expanded(
              child: Center(
                child: Text('No employees found.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey[400])),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return Expanded(
      flex: 2,
      child: Column(
        children: [
          Row(
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
                      Text('TOTAL SALARY PAID (SEPTEMBER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.purple[700])),
                      const SizedBox(height: 12),
                      Text('₹0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF1F2937))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                      Text('ADVANCES GIVEN (SEPTEMBER)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.orange[700])),
                      const SizedBox(height: 12),
                      Text('₹0', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Theme.of(context).brightness == Brightness.dark ? AppColors.textLight : const Color(0xFF1F2937))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.purple[700]!, width: 2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text('SALARY LOGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.purple[700])),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!, width: 2),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text('ADVANCE LOGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: [
                        _buildColHeader('EMPLOYEE', flex: 3),
                        _buildColHeader('BASIC', flex: 2, alignRight: true),
                        _buildColHeader('OT PAY', flex: 2, alignRight: true),
                        _buildColHeader('DEDUCTED', flex: 2, alignRight: true),
                        _buildColHeader('NET PAY', flex: 2, alignRight: true),
                        _buildColHeader('ACTIONS', flex: 1, alignRight: true),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
                  Expanded(
                    child: Container(
                      color: isDark ? Colors.white.withValues(alpha: 0.02) : const Color(0xFFE5E7EB).withValues(alpha: 0.5),
                      alignment: Alignment.center,
                      child: Text('No salaries processed this month.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueGrey[500])),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

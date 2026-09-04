import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/models/finance_models.dart';

class SalaryScreen extends ConsumerWidget {
  const SalaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payroll / Salary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(financeProvider),
          )
        ],
      ),
      body: financeState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => _buildPayrollList(context, data.payroll),
      ),
    );
  }

  Widget _buildPayrollList(BuildContext context, List<PayrollRecord> payroll) {
    if (payroll.isEmpty) return const Center(child: Text('No payroll records found.'));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: payroll.length,
      itemBuilder: (context, index) {
        final record = payroll[index];
        final monthName = _getMonthName(record.month);
        
        return Card(
          child: ListTile(
            title: Text('Employee ID: ${record.employeeId} - $monthName ${record.year}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Base: ₹${record.baseSalary.toStringAsFixed(2)} | Deductions: ₹${record.deductions.toStringAsFixed(2)}\nStatus: ${record.status}'),
            trailing: Text(
              '₹${record.netPay.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return month.toString();
  }
}

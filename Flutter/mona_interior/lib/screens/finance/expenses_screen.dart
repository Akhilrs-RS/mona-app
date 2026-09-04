import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/widgets/forms/expense_form.dart';

class ExpensesScreen extends ConsumerWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses & Credits'),
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
        data: (data) => _buildExpensesList(data.expenses),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const ExpenseForm());
        },
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildExpensesList(List<Expense> expenses) {
    if (expenses.isEmpty) return const Center(child: Text('No expenses found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final exp = expenses[index];
        return Card(
          child: ListTile(
            title: Text(exp.category, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(exp.description, maxLines: 2, overflow: TextOverflow.ellipsis),
            trailing: Text(
              '-₹${exp.amount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            onTap: () {
              showDialog(context: context, builder: (_) => ExpenseForm(expense: exp));
            },
          ),
        );
      },
    );
  }
}

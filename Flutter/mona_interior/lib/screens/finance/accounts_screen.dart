import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/models/finance_models.dart';

class AccountsScreen extends ConsumerWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
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
        data: (data) => _buildLedgerList(data.ledger),
      ),
    );
  }

  Widget _buildLedgerList(List<LedgerEntry> ledger) {
    if (ledger.isEmpty) return const Center(child: Text('No ledger entries found.'));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ledger.length,
      itemBuilder: (context, index) {
        final entry = ledger[index];
        final isCredit = entry.type.toLowerCase() == 'credit';
        return Card(
          child: ListTile(
            leading: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
            ),
            title: Text(entry.description, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('${entry.date}\n${entry.category}'),
            trailing: Text(
              '${isCredit ? '+' : '-'}₹${entry.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

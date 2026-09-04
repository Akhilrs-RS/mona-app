import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/widgets/forms/receipt_form.dart';

class ReceiptsScreen extends ConsumerWidget {
  const ReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Receipts'),
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
        data: (data) => _buildReceiptsList(context, data.receipts),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const ReceiptForm());
        },
        tooltip: 'Add Receipt',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReceiptsList(BuildContext context, List<Receipt> receipts) {
    if (receipts.isEmpty) return const Center(child: Text('No receipts found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: receipts.length,
      itemBuilder: (context, index) {
        final rec = receipts[index];
        return Card(
          child: ListTile(
            title: Text(rec.receiptNo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${rec.clientName}\nPaid via: ${rec.paymentMode}'),
            trailing: Text(
              '+₹${rec.amountPaid.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            isThreeLine: true,
            onTap: () {
              showDialog(context: context, builder: (_) => ReceiptForm(receipt: rec));
            },
          ),
        );
      },
    );
  }
}

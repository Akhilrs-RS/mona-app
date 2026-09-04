import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/widgets/forms/invoice_form.dart';

class InvoicesScreen extends ConsumerWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeState = ref.watch(financeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History (Invoices)'),
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
        data: (data) => _buildInvoicesList(data.invoices),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const InvoiceForm());
        },
        tooltip: 'Add Invoice',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildInvoicesList(List<Invoice> invoices) {
    if (invoices.isEmpty) return const Center(child: Text('No invoices found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final inv = invoices[index];
        return Card(
          child: ListTile(
            title: Text(inv.invoiceNo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${inv.clientName}\nStatus: ${inv.status}'),
            trailing: Text(
              '₹${inv.total.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            isThreeLine: true,
            onTap: () {
              // TODO: Navigate to invoice details or edit form if needed
            },
          ),
        );
      },
    );
  }
}

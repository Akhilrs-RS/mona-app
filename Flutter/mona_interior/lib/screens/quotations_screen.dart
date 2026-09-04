import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/crm_provider.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/widgets/forms/quotation_form.dart';

class QuotationsScreen extends ConsumerWidget {
  const QuotationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crmState = ref.watch(crmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(crmProvider),
          )
        ],
      ),
      body: crmState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => _buildQuotationsList(data.quotations, context),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const QuotationForm());
        },
        tooltip: 'Add Quotation',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuotationsList(List<Quotation> quotations, BuildContext context) {
    if (quotations.isEmpty) return const Center(child: Text('No quotations found.'));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: quotations.length,
      itemBuilder: (context, index) {
        final q = quotations[index];
        return Card(
          child: ListTile(
            title: Text(q.quoteNo, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${q.clientName} - ${q.projectTitle}\nStatus: ${q.status}'),
            trailing: Text(
              '₹${q.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: q.status == 'Approved' ? Colors.green : Colors.blue,
              ),
            ),
            isThreeLine: true,
            onTap: () {
              showDialog(context: context, builder: (_) => QuotationForm(quotation: q));
            },
          ),
        );
      },
    );
  }
}

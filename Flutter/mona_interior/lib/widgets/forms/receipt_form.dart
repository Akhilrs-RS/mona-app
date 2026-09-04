import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/providers/finance_provider.dart';

class ReceiptForm extends ConsumerStatefulWidget {
  final Receipt? receipt;

  const ReceiptForm({super.key, this.receipt});

  @override
  ConsumerState<ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends ConsumerState<ReceiptForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _receiptNoController;
  late TextEditingController _clientNameController;
  late TextEditingController _totalAmountController;
  late TextEditingController _amountPaidController;
  late TextEditingController _dateController;

  String _status = 'Received';
  String _paymentMode = 'Bank Transfer';
  String _category = 'Sales';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _receiptNoController = TextEditingController(text: widget.receipt?.receiptNo ?? '');
    _clientNameController = TextEditingController(text: widget.receipt?.clientName ?? '');
    _totalAmountController = TextEditingController(text: widget.receipt?.totalAmount.toString() ?? '');
    _amountPaidController = TextEditingController(text: widget.receipt?.amountPaid.toString() ?? '');
    _dateController = TextEditingController(text: widget.receipt?.date ?? DateTime.now().toIso8601String().split('T').first);

    if (widget.receipt != null) {
      _status = widget.receipt!.status.isNotEmpty ? widget.receipt!.status : 'Received';
      _paymentMode = widget.receipt!.paymentMode.isNotEmpty ? widget.receipt!.paymentMode : 'Bank Transfer';
      _category = widget.receipt!.category.isNotEmpty ? widget.receipt!.category : 'Sales';
    }
  }

  @override
  void dispose() {
    _receiptNoController.dispose();
    _clientNameController.dispose();
    _totalAmountController.dispose();
    _amountPaidController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final totalAmount = double.tryParse(_totalAmountController.text) ?? 0.0;
    final amountPaid = double.tryParse(_amountPaidController.text) ?? 0.0;
    final remainingAmount = totalAmount - amountPaid;

    final receipt = Receipt(
      id: widget.receipt?.id ?? '',
      receiptNo: _receiptNoController.text,
      date: _dateController.text,
      clientName: _clientNameController.text,
      siteId: widget.receipt?.siteId ?? '',
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      remainingAmount: remainingAmount,
      status: _status,
      category: _category,
      paymentMode: _paymentMode,
    );

    try {
      if (widget.receipt == null) {
        await ref.read(financeProvider.notifier).addReceipt(receipt);
      } else {
        await ref.read(financeProvider.notifier).updateReceipt(receipt);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.receipt == null ? 'New Receipt' : 'Edit Receipt'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _receiptNoController,
                decoration: const InputDecoration(labelText: 'Receipt No', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _clientNameController,
                decoration: const InputDecoration(labelText: 'Client Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalAmountController,
                      decoration: const InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountPaidController,
                      decoration: const InputDecoration(labelText: 'Amount Paid', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Received', 'Pending'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _status = val ?? 'Received'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _paymentMode,
                      decoration: const InputDecoration(labelText: 'Payment Mode', border: OutlineInputBorder()),
                      items: ['Bank Transfer', 'Cash', 'Cheque', 'UPI'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _paymentMode = val ?? 'Bank Transfer'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.receipt != null)
          TextButton(
            onPressed: () async {
              setState(() => _isLoading = true);
              try {
                await ref.read(financeProvider.notifier).deleteReceipt(widget.receipt!.id);
                if (mounted) Navigator.of(context).pop();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          icon: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
          onPressed: _isLoading ? null : _save,
          label: const Text('Save'),
        ),
      ],
    );
  }
}

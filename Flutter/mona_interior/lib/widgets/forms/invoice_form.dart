import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/utils/pdf_generator.dart';

class InvoiceForm extends ConsumerStatefulWidget {
  final Invoice? invoice;

  const InvoiceForm({super.key, this.invoice});

  @override
  ConsumerState<InvoiceForm> createState() => _InvoiceFormState();
}

class _InvoiceFormState extends ConsumerState<InvoiceForm> {
  final _formKey = GlobalKey<FormState>();
  late String _invoiceNo;
  late String _invoiceDate;
  late String _clientName;
  late String _projectTitle;
  late String _status;
  late String _billType;
  late String _date;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _invoiceNo = widget.invoice?.invoiceNo ?? '';
    _invoiceDate = widget.invoice?.invoiceDate ?? DateTime.now().toIso8601String().split('T')[0];
    _clientName = widget.invoice?.clientName ?? '';
    _projectTitle = widget.invoice?.projectTitle ?? '';
    _status = widget.invoice?.status ?? 'Unpaid';
    _billType = widget.invoice?.billType ?? 'GST';
    _date = widget.invoice?.date ?? DateTime.now().toIso8601String().split('T')[0];
    
    if (widget.invoice != null && widget.invoice!.items.isNotEmpty) {
      _items = widget.invoice!.items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  }

  double get _subtotal {
    double total = 0;
    for (var item in _items) {
      total += double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  double get _tax => _billType == 'Non-GST' ? 0 : _subtotal * 0.18;
  double get _total => _subtotal + _tax;

  void _addItem() {
    setState(() {
      _items.add({
        'description': '',
        'area': '1',
        'unit': 'Sq.Ft',
        'rate': '0',
        'amount': '0',
      });
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _calculateItemAmount(int index) {
    final area = double.tryParse(_items[index]['area'].toString()) ?? 1;
    final rate = double.tryParse(_items[index]['rate'].toString()) ?? 0;
    setState(() {
      _items[index]['amount'] = (area * rate).toStringAsFixed(2);
    });
  }

  Invoice _buildInvoiceObj() {
    return Invoice(
      id: widget.invoice?.id ?? '',
      invoiceNo: _invoiceNo,
      invoiceDate: _invoiceDate,
      clientName: _clientName,
      projectTitle: _projectTitle,
      total: _total,
      status: _status,
      billType: _billType,
      date: _date,
      items: _items,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final invoice = _buildInvoiceObj();

    try {
      if (widget.invoice == null) {
        await ref.read(financeProvider.notifier).addInvoice(invoice);
      } else {
        await ref.read(financeProvider.notifier).updateInvoice(invoice);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice saved!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _generatePDF() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    PdfGenerator.generateAndShareInvoice(_buildInvoiceObj());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.invoice == null ? 'New Invoice' : 'Edit Invoice'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _invoiceNo,
                decoration: const InputDecoration(labelText: 'Invoice No.', border: OutlineInputBorder()),
                onSaved: (val) => _invoiceNo = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _clientName,
                decoration: const InputDecoration(labelText: 'Client Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _clientName = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _projectTitle,
                decoration: const InputDecoration(labelText: 'Project Title', border: OutlineInputBorder()),
                onSaved: (val) => _projectTitle = val ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Unpaid', 'Paid', 'Partial'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _status = val ?? 'Unpaid'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _billType,
                      decoration: const InputDecoration(labelText: 'Bill Type', border: OutlineInputBorder()),
                      items: ['GST', 'Non-GST'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _billType = val ?? 'GST'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Line Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: _addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Item'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ..._items.asMap().entries.map((entry) {
                int idx = entry.key;
                Map<String, dynamic> item = entry.value;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: item['description'],
                                decoration: const InputDecoration(labelText: 'Description', isDense: true),
                                onChanged: (val) => item['description'] = val,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeItem(idx),
                            )
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: item['area'],
                                decoration: const InputDecoration(labelText: 'Qty/Area', isDense: true),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item['area'] = val;
                                  _calculateItemAmount(idx);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                initialValue: item['unit'],
                                decoration: const InputDecoration(labelText: 'Unit', isDense: true),
                                onChanged: (val) => item['unit'] = val,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                initialValue: item['rate'],
                                decoration: const InputDecoration(labelText: 'Rate (₹)', isDense: true),
                                keyboardType: TextInputType.number,
                                onChanged: (val) {
                                  item['rate'] = val;
                                  _calculateItemAmount(idx);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Amount: ₹${item['amount']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text('₹${_subtotal.toStringAsFixed(2)}'),
                      ],
                    ),
                    if (_billType != 'Non-GST') ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('GST (18%)'),
                          Text('₹${_tax.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('₹${_total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          onPressed: _generatePDF,
          tooltip: 'Generate PDF',
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

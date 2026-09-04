import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/providers/crm_provider.dart';

import 'package:mona_interior/utils/pdf_generator.dart';

class QuotationForm extends ConsumerStatefulWidget {
  final Quotation? quotation;

  const QuotationForm({super.key, this.quotation});

  @override
  ConsumerState<QuotationForm> createState() => _QuotationFormState();
}

class _QuotationFormState extends ConsumerState<QuotationForm> {
  final _formKey = GlobalKey<FormState>();
  late String _quoteNo;
  late String _clientName;
  late String _projectTitle;
  late String _status;
  late String _date;
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _quoteNo = widget.quotation?.quoteNo ?? '';
    _clientName = widget.quotation?.clientName ?? '';
    _projectTitle = widget.quotation?.projectTitle ?? '';
    _status = widget.quotation?.status ?? 'Pending';
    _date = widget.quotation?.date ?? DateTime.now().toIso8601String().split('T')[0];
    
    if (widget.quotation != null && widget.quotation!.items.isNotEmpty) {
      _items = widget.quotation!.items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
  }

  double get _subtotal {
    double total = 0;
    for (var item in _items) {
      total += double.tryParse(item['amount']?.toString() ?? '0') ?? 0;
    }
    return total;
  }

  double get _tax => _subtotal * 0.18;
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

  Quotation _buildQuotationObj() {
    return Quotation(
      id: widget.quotation?.id ?? '',
      quoteNo: _quoteNo,
      clientName: _clientName,
      projectTitle: _projectTitle,
      total: _total,
      status: _status,
      date: _date,
      items: _items,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);
    final quotation = _buildQuotationObj();

    try {
      if (widget.quotation == null) {
        await ref.read(crmProvider.notifier).addQuotation(quotation);
      } else {
        await ref.read(crmProvider.notifier).updateQuotation(quotation);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Quotation saved!')));
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
    PdfGenerator.generateAndShareQuotation(_buildQuotationObj());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.quotation == null ? 'New Quotation' : 'Edit Quotation'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _quoteNo,
                decoration: const InputDecoration(labelText: 'Quotation No.', border: OutlineInputBorder()),
                onSaved: (val) => _quoteNo = val ?? '',
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
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Pending', 'Approved', 'Rejected'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val ?? 'Pending'),
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
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('GST (18%)'),
                        Text('₹${_tax.toStringAsFixed(2)}'),
                      ],
                    ),
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

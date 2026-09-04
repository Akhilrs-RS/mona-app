import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/providers/finance_provider.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  final Expense? expense;

  const ExpenseForm({super.key, this.expense});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  
  bool _isLoading = false;

  final List<String> _categories = ['Material', 'Labor', 'Travel', 'Office', 'Other'];

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController(text: widget.expense?.category ?? 'Material');
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.expense?.description ?? '');
    _dateController = TextEditingController(text: widget.expense?.date ?? DateTime.now().toIso8601String().split('T').first);
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedExpense = Expense(
      id: widget.expense?.id ?? '', 
      category: _categoryController.text.trim(),
      amount: double.tryParse(_amountController.text.trim()) ?? 0.0,
      description: _descriptionController.text.trim(),
      date: _dateController.text.trim(),
      clientId: widget.expense?.clientId ?? '',
      type: widget.expense?.type ?? 'Expense',
    );

    try {
      if (widget.expense == null) {
        await ref.read(financeProvider.notifier).addExpense(updatedExpense);
      } else {
        await ref.read(financeProvider.notifier).updateExpense(updatedExpense);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving expense: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expense == null ? 'Add Expense' : 'Edit Expense'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category)),
                      value: _categories.contains(_categoryController.text) ? _categoryController.text : 'Other',
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _categoryController.text = val;
                        }
                      },
                    ),
                    if (!_categories.contains(_categoryController.text) || _categoryController.text == 'Other') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Custom Category', prefixIcon: Icon(Icons.edit)),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ],
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(labelText: 'Amount (₹)', prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description)),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onTap: () async {
                        FocusScope.of(context).requestFocus(FocusNode());
                        final date = await showDatePicker(
                          context: context, 
                          initialDate: DateTime.now(), 
                          firstDate: DateTime(2000), 
                          lastDate: DateTime(2100)
                        );
                        if (date != null) {
                          _dateController.text = date.toIso8601String().split('T').first;
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        if (widget.expense != null)
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Expense?'),
                  content: const Text('Are you sure you want to delete this expense?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true), 
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                setState(() => _isLoading = true);
                try {
                  await ref.read(financeProvider.notifier).deleteExpense(widget.expense!.id);
                  if (mounted) Navigator.of(context).pop();
                } catch(e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                } finally {
                  if (mounted) setState(() => _isLoading = false);
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveExpense,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

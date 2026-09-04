import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/providers/site_provider.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class ExpenseForm extends ConsumerStatefulWidget {
  final Expense? expense;
  const ExpenseForm({super.key, this.expense});

  @override
  ConsumerState<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isClientExpense = true;

  // Client Expense Controllers
  String? _selectedWorkOrder;
  late TextEditingController _dateController;
  late TextEditingController _materialController;
  late TextEditingController _quantityController;
  late TextEditingController _costController;

  // Overhead Expense Controllers
  late TextEditingController _overheadCategoryController;
  late TextEditingController _overheadDescController;
  late TextEditingController _overheadAmountController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.expense?.date ?? DateTime.now().toIso8601String().split('T').first);
    
    _materialController = TextEditingController(text: widget.expense?.description ?? '');
    _quantityController = TextEditingController();
    _costController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    
    _overheadCategoryController = TextEditingController(text: widget.expense?.category ?? 'Office');
    _overheadDescController = TextEditingController(text: widget.expense?.description ?? '');
    _overheadAmountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
    
    if (widget.expense != null && widget.expense!.clientId.isEmpty) {
      _isClientExpense = false;
    } else {
      _selectedWorkOrder = widget.expense?.clientId.isNotEmpty == true ? widget.expense!.clientId : null;
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _materialController.dispose();
    _quantityController.dispose();
    _costController.dispose();
    _overheadCategoryController.dispose();
    _overheadDescController.dispose();
    _overheadAmountController.dispose();
    super.dispose();
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_isClientExpense && _selectedWorkOrder == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a work order.')));
      return;
    }

    setState(() => _isLoading = true);

    String description = _isClientExpense 
        ? (_quantityController.text.isNotEmpty ? "${_materialController.text.trim()} (Qty: ${_quantityController.text.trim()})" : _materialController.text.trim())
        : _overheadDescController.text.trim();

    final updatedExpense = Expense(
      id: widget.expense?.id ?? '', 
      category: _isClientExpense ? 'Project' : _overheadCategoryController.text.trim(),
      amount: double.tryParse(_isClientExpense ? _costController.text.trim() : _overheadAmountController.text.trim()) ?? 0.0,
      description: description,
      date: _dateController.text.trim(),
      clientId: _isClientExpense ? (_selectedWorkOrder ?? '') : '',
      type: 'Expense',
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
    final sites = ref.watch(sitesProvider);
    final workOrderItems = sites.valueOrNull?.map((s) => DropdownMenuItem(value: s.id.toString(), child: Text(s.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))))).toList() ?? [];

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(32),
        child: _isLoading 
            ? const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()))
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.expense == null ? 'Log New Expense' : 'Edit Expense', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                            const SizedBox(height: 4),
                            Text('Choose whether this is a client project cost or a business overhead.', style: TextStyle(fontSize: 12, color: Colors.blueGrey[400])),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.close, size: 20, color: Colors.blueGrey[300]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Toggle Buttons
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isClientExpense = true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _isClientExpense ? AppColors.primaryGold : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: _isClientExpense ? AppColors.primaryGold : Colors.grey[300]!),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.user, size: 16, color: _isClientExpense ? Colors.white : Colors.blueGrey[400]),
                                  const SizedBox(width: 8),
                                  Text('CLIENT EXPENSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: _isClientExpense ? Colors.white : Colors.blueGrey[600])),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _isClientExpense = false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_isClientExpense ? AppColors.primaryGold : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: !_isClientExpense ? AppColors.primaryGold : Colors.grey[300]!),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.building, size: 16, color: !_isClientExpense ? Colors.white : Colors.blueGrey[400]),
                                  const SizedBox(width: 8),
                                  Text('OVERHEAD EXPENSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: !_isClientExpense ? Colors.white : Colors.blueGrey[600])),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Form Fields
                    if (_isClientExpense) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('SELECT WORK ORDER *', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  value: _selectedWorkOrder,
                                  items: workOrderItems,
                                  onChanged: (val) {
                                    if (val != null) setState(() => _selectedWorkOrder = val);
                                  },
                                  decoration: _inputDecoration(hintText: '-- Select a Work Order --'),
                                  icon: const Icon(LucideIcons.chevron_down, size: 16),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: _inputDecoration(suffixIcon: LucideIcons.calendar),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                  onTap: () async {
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MATERIAL / ITEM', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _materialController,
                            decoration: _inputDecoration(hintText: 'e.g. Marine Plywood, Paint...'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('QUANTITY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _quantityController,
                                  decoration: _inputDecoration(hintText: 'e.g. 10 units'),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TOTAL COST (₹)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _costController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: _inputDecoration(hintText: '0.00'),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Overhead Expense Fields
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('CATEGORY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _overheadCategoryController,
                                  decoration: _inputDecoration(hintText: 'e.g. Office, Travel, Salaries...'),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                  validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: _inputDecoration(suffixIcon: LucideIcons.calendar),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                                  onTap: () async {
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DESCRIPTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _overheadDescController,
                            decoration: _inputDecoration(hintText: 'e.g. Monthly electricity bill...'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL COST (₹)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[400])),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _overheadAmountController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: _inputDecoration(hintText: '0.00'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                            validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Submit Button
                    Row(
                      children: [
                        if (widget.expense != null) ...[
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
                          const Spacer(),
                        ],
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _saveExpense,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGold,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              ),
                              child: Text(_isClientExpense ? 'SAVE CLIENT EXPENSE ENTRY' : 'SAVE OVERHEAD EXPENSE ENTRY', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({String? hintText, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[300], fontWeight: FontWeight.normal),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primaryGold),
      ),
      isDense: true,
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, size: 16, color: Colors.blueGrey[300]) : null,
    );
  }
}

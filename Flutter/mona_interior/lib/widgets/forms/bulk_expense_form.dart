import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/finance_models.dart';
import 'package:mona_interior/providers/finance_provider.dart';
import 'package:mona_interior/theme/app_colors.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

class BulkExpenseForm extends ConsumerStatefulWidget {
  const BulkExpenseForm({super.key});

  @override
  ConsumerState<BulkExpenseForm> createState() => _BulkExpenseFormState();
}

class _BulkExpenseFormState extends ConsumerState<BulkExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  
  final List<ExpenseEntryRow> _rows = [
    ExpenseEntryRow(),
  ];

  bool _isLoading = false;

  void _addRow() {
    setState(() {
      _rows.add(ExpenseEntryRow());
    });
  }

  void _removeRow(int index) {
    if (_rows.length > 1) {
      setState(() {
        _rows.removeAt(index);
      });
    }
  }

  Future<void> _saveAll() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      for (var row in _rows) {
        final expense = Expense(
          id: '',
          category: row.categoryController.text.trim(),
          amount: double.tryParse(row.amountController.text.trim()) ?? 0.0,
          description: row.descController.text.trim(),
          date: row.dateController.text.trim(),
          clientId: '',
          type: 'Expense',
        );
        await ref.read(financeProvider.notifier).addExpense(expense);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bulk expenses saved successfully!')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 900,
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
                            const Text('Bulk Expenses Entry', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                            const SizedBox(height: 4),
                            Text('Log multiple expenses quickly.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(LucideIcons.download, size: 14),
                              label: const Text('Download Template', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blueGrey[600],
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(LucideIcons.upload, size: 14),
                              label: const Text('Upload Excel', style: TextStyle(fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            const SizedBox(width: 24),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.close, size: 20, color: Colors.blueGrey[300]),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    
                    // Table Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          _buildColHeader('DATE (YYYY-MM-DD)', flex: 2),
                          const SizedBox(width: 16),
                          _buildColHeader('CATEGORY', flex: 2),
                          const SizedBox(width: 16),
                          _buildColHeader('AMOUNT (₹)', flex: 2),
                          const SizedBox(width: 16),
                          _buildColHeader('DESCRIPTION', flex: 3),
                          const SizedBox(width: 16),
                          _buildColHeader('ACTIONS', flex: 1, alignRight: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Rows
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 400),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _rows.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 2, child: _buildTextField(_rows[index].dateController, 'Date', required: true)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildTextField(_rows[index].categoryController, 'Category', required: true)),
                                const SizedBox(width: 16),
                                Expanded(flex: 2, child: _buildTextField(_rows[index].amountController, 'Amount', required: true, isNumber: true)),
                                const SizedBox(width: 16),
                                Expanded(flex: 3, child: _buildTextField(_rows[index].descController, 'Description')),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      icon: const Icon(LucideIcons.trash_2, size: 18, color: Colors.red),
                                      onPressed: () => _removeRow(index),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _addRow,
                      icon: const Icon(LucideIcons.plus, size: 16),
                      label: const Text('Add Row', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: TextButton.styleFrom(foregroundColor: AppColors.primaryGold),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: TextStyle(color: Colors.blueGrey[400], fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveAll,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text('SAVE ENTRIES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildColHeader(String text, {required int flex, bool alignRight = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.right : TextAlign.left,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[600]),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool required = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: required ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[300]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primaryGold),
        ),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
    );
  }
}

class ExpenseEntryRow {
  final TextEditingController dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T').first);
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descController = TextEditingController();
}

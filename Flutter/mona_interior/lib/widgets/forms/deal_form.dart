import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/providers/crm_provider.dart';

class DealForm extends ConsumerStatefulWidget {
  final Deal? deal;

  const DealForm({super.key, this.deal});

  @override
  ConsumerState<DealForm> createState() => _DealFormState();
}

class _DealFormState extends ConsumerState<DealForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _valueController;
  late TextEditingController _closeDateController;
  String? _selectedContactId;
  String _selectedStage = 'LEAD';

  bool _isLoading = false;

  final List<String> _stages = ['LEAD', 'CONTACTED', 'PROPOSAL', 'NEGOTIATION', 'WON', 'LOST'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.deal?.title ?? '');
    _valueController = TextEditingController(text: widget.deal?.value.toString() ?? '');
    _closeDateController = TextEditingController(text: widget.deal?.closeDate ?? '');
    _selectedContactId = widget.deal?.contactId;
    _selectedStage = widget.deal?.stage ?? 'LEAD';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _closeDateController.dispose();
    super.dispose();
  }

  Future<void> _saveDeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContactId == null || _selectedContactId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }

    setState(() => _isLoading = true);

    final updatedDeal = Deal(
      id: widget.deal?.id ?? '', 
      title: _titleController.text.trim(),
      value: double.tryParse(_valueController.text.trim()) ?? 0.0,
      contactId: _selectedContactId!,
      stage: _selectedStage,
      closeDate: _closeDateController.text.trim(),
    );

    try {
      if (widget.deal == null) {
        await ref.read(crmProvider.notifier).addDeal(updatedDeal);
      } else {
        await ref.read(crmProvider.notifier).updateDeal(updatedDeal);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving deal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final crmState = ref.watch(crmProvider);
    final contacts = crmState.value?.contacts ?? [];

    return AlertDialog(
      title: Text(widget.deal == null ? 'Add Deal' : 'Edit Deal'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Deal Title', prefixIcon: Icon(Icons.work)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _valueController,
                      decoration: const InputDecoration(labelText: 'Value (₹)', prefixIcon: Icon(Icons.attach_money)),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Client', prefixIcon: Icon(Icons.person)),
                      value: contacts.any((c) => c.id == _selectedContactId) ? _selectedContactId : null,
                      items: contacts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      onChanged: (val) => setState(() => _selectedContactId = val),
                      validator: (val) => val == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Stage', prefixIcon: Icon(Icons.flag)),
                      value: _selectedStage,
                      items: _stages.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedStage = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _closeDateController,
                      decoration: const InputDecoration(labelText: 'Close Date (YYYY-MM-DD)', prefixIcon: Icon(Icons.calendar_today)),
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
                          _closeDateController.text = date.toIso8601String().split('T').first;
                        }
                      },
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        if (widget.deal != null)
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Deal?'),
                  content: const Text('Are you sure you want to delete this deal?'),
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
                  await ref.read(crmProvider.notifier).deleteDeal(widget.deal!.id);
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
          onPressed: _saveDeal,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/providers/crm_provider.dart';

class ActivityForm extends ConsumerStatefulWidget {
  final Activity? activity;

  const ActivityForm({super.key, this.activity});

  @override
  ConsumerState<ActivityForm> createState() => _ActivityFormState();
}

class _ActivityFormState extends ConsumerState<ActivityForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _typeController;
  late TextEditingController _dateController;
  String? _selectedContactId;
  String _selectedStatus = 'Pending';

  bool _isLoading = false;

  final List<String> _statuses = ['Pending', 'Completed', 'Overdue'];
  final List<String> _activityTypes = ['Follow-up Call', 'Site Visit', 'Send Quotation', 'Meeting', 'Other'];

  @override
  void initState() {
    super.initState();
    _typeController = TextEditingController(text: widget.activity?.type ?? 'Follow-up Call');
    _dateController = TextEditingController(text: widget.activity?.date ?? DateTime.now().toIso8601String().split('T').first);
    _selectedContactId = widget.activity?.client;
    _selectedStatus = widget.activity?.status ?? 'Pending';
  }

  @override
  void dispose() {
    _typeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedContactId == null || _selectedContactId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a client')));
      return;
    }

    setState(() => _isLoading = true);

    final updatedActivity = Activity(
      id: widget.activity?.id ?? '', 
      type: _typeController.text.trim(),
      date: _dateController.text.trim(),
      client: _selectedContactId!,
      status: _selectedStatus,
    );

    try {
      if (widget.activity == null) {
        await ref.read(crmProvider.notifier).addActivity(updatedActivity);
      } else {
        await ref.read(crmProvider.notifier).updateActivity(updatedActivity);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving activity: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final crmState = ref.watch(crmProvider);
    final contacts = crmState.value?.contacts ?? [];

    return AlertDialog(
      title: Text(widget.activity == null ? 'Add Activity' : 'Edit Activity'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Activity Type', prefixIcon: Icon(Icons.task)),
                      value: _activityTypes.contains(_typeController.text) ? _typeController.text : 'Other',
                      items: _activityTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          _typeController.text = val;
                        }
                      },
                    ),
                    if (!_activityTypes.contains(_typeController.text) || _typeController.text == 'Other') ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(labelText: 'Custom Type', prefixIcon: Icon(Icons.edit)),
                        validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ],
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
                      decoration: const InputDecoration(labelText: 'Status', prefixIcon: Icon(Icons.flag)),
                      value: _selectedStatus,
                      items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _selectedStatus = val!),
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
        if (widget.activity != null)
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Activity?'),
                  content: const Text('Are you sure you want to delete this activity?'),
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
                  await ref.read(crmProvider.notifier).deleteActivity(widget.activity!.id);
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
          onPressed: _saveActivity,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

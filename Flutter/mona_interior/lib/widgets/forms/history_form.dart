import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/site_models.dart';
import 'package:mona_interior/providers/site_provider.dart';

class HistoryForm extends ConsumerStatefulWidget {
  final Site site;
  const HistoryForm({super.key, required this.site});

  @override
  ConsumerState<HistoryForm> createState() => _HistoryFormState();
}

class _HistoryFormState extends ConsumerState<HistoryForm> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _dateController = TextEditingController(text: DateTime.now().toIso8601String().split('T')[0]);
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final newHistory = {
        'id': 'h-\${DateTime.now().millisecondsSinceEpoch}',
        'date': _dateController.text,
        'desc': _descController.text,
      };

      final updatedHistory = [newHistory, ...widget.site.workHistory];

      await ref.read(sitesProvider.notifier).updateSiteProperty(
        widget.site.id,
        'workHistory',
        updatedHistory,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timeline entry added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: \$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Timeline Entry'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.4,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Date (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading ? const CircularProgressIndicator() : const Text('Add Entry'),
        ),
      ],
    );
  }
}

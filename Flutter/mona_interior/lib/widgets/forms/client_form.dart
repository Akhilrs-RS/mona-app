import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/providers/crm_provider.dart';

class ClientForm extends ConsumerStatefulWidget {
  final Contact? contact;

  const ClientForm({super.key, this.contact});

  @override
  ConsumerState<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends ConsumerState<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _projectController;
  late TextEditingController _sourceController;
  late TextEditingController _tagsController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _projectController = TextEditingController(text: widget.contact?.project ?? '');
    _sourceController = TextEditingController(text: widget.contact?.source ?? '');
    _tagsController = TextEditingController(text: widget.contact?.tags.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _projectController.dispose();
    _sourceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedContact = Contact(
      id: widget.contact?.id ?? '', // backend logic handles ID on empty if required
      name: _nameController.text.trim(),
      organizationName: widget.contact?.organizationName ?? '',
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      project: _projectController.text.trim(),
      address: widget.contact?.address ?? '',
      status: widget.contact?.status ?? 'Cold',
      source: _sourceController.text.trim(),
      tags: _tagsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      date: widget.contact?.date ?? DateTime.now().toIso8601String().split('T').first,
    );

    try {
      if (widget.contact == null) {
        await ref.read(crmProvider.notifier).addContact(updatedContact);
      } else {
        await ref.read(crmProvider.notifier).updateContact(updatedContact);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving client: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.contact == null ? 'Add Client' : 'Edit Client'),
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
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Client Name', prefixIcon: Icon(Icons.person)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _projectController,
                      decoration: const InputDecoration(labelText: 'Project Focus', prefixIcon: Icon(Icons.home_work)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _sourceController,
                      decoration: const InputDecoration(labelText: 'Lead Source', prefixIcon: Icon(Icons.share)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(labelText: 'Tags (comma separated)', prefixIcon: Icon(Icons.tag)),
                    ),
                  ],
                ),
              ),
      ),
      actions: [
        if (widget.contact != null)
          TextButton(
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Client?'),
                  content: const Text('Are you sure you want to delete this client?'),
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
                  await ref.read(crmProvider.notifier).deleteContact(widget.contact!.id);
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
          onPressed: _saveContact,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

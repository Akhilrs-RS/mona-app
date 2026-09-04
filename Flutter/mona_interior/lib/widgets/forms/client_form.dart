import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/crm_models.dart';
import 'package:mona_interior/providers/crm_provider.dart';
import 'package:mona_interior/theme/app_colors.dart';

class ClientForm extends ConsumerStatefulWidget {
  final Contact? contact;

  const ClientForm({super.key, this.contact});

  @override
  ConsumerState<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends ConsumerState<ClientForm> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _orgController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _projectController;
  late TextEditingController _addressController;
  late TextEditingController _sourceController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _orgController = TextEditingController(text: widget.contact?.organizationName ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
    _projectController = TextEditingController(text: widget.contact?.project ?? '');
    _addressController = TextEditingController(text: widget.contact?.address ?? '');
    _sourceController = TextEditingController(text: widget.contact?.source ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orgController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _projectController.dispose();
    _addressController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updatedContact = Contact(
      id: widget.contact?.id ?? '', 
      name: _nameController.text.trim(),
      organizationName: _orgController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      project: _projectController.text.trim(),
      address: _addressController.text.trim(),
      status: widget.contact?.status ?? 'Cold',
      source: _sourceController.text.trim(),
      tags: widget.contact?.tags ?? [],
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
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
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
                            const Text('Client Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                            const SizedBox(height: 4),
                            Text('Comprehensive details for your design client.', style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                          ],
                        ),
                        InkWell(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, size: 20, color: Colors.blueGrey[300]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.grey[200]),
                    const SizedBox(height: 16),
                    
                    // Row 1
                    Row(
                      children: [
                        Expanded(child: _buildFormField('FULL NAME', _nameController, required: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFormField('ORGANIZATION NAME (OPTIONAL)', _orgController, hintText: 'e.g. Acme Corp')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 2
                    Row(
                      children: [
                        Expanded(child: _buildFormField('PHONE NUMBER', _phoneController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildFormField('EMAIL ADDRESS', _emailController)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Row 3
                    _buildFormField('PROJECT FOCUS', _projectController),
                    const SizedBox(height: 16),
                    // Row 4
                    _buildFormField('PHYSICAL ADDRESS', _addressController),
                    const SizedBox(height: 16),
                    // Row 5
                    _buildFormField('LEAD SOURCE', _sourceController, hintText: 'e.g. Instagram'),
                    
                    const SizedBox(height: 24),
                    
                    // Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: TextStyle(color: Colors.blueGrey[400], fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _saveContact,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGold,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          ),
                          child: const Text('Save Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, {bool required = false, String? hintText}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.blueGrey[600]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: required ? (val) => val == null || val.isEmpty ? 'Required' : null : null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 13, color: Colors.blueGrey[300]),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}

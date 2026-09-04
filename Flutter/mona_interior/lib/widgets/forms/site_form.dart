import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/site_models.dart';
import 'package:mona_interior/providers/site_provider.dart';

class SiteForm extends ConsumerStatefulWidget {
  final Site? site;

  const SiteForm({super.key, this.site});

  @override
  ConsumerState<SiteForm> createState() => _SiteFormState();
}

class _SiteFormState extends ConsumerState<SiteForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _clientName;
  late String _organizationName;
  late String _assignedTeam;
  late String _address;
  late String _status;
  late String _startDate;
  late String _budget;
  late String _description;
  late bool _isNegotiated;
  late String _negotiationDetails;
  late bool _isArchived;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.site?.name ?? '';
    _clientName = widget.site?.clientName ?? '';
    _organizationName = widget.site?.organizationName ?? '';
    _assignedTeam = widget.site?.assignedTeam ?? '';
    _address = widget.site?.address ?? '';
    _status = widget.site?.status ?? 'Pre-Construction';
    _startDate = widget.site?.startDate ?? DateTime.now().toIso8601String().split('T')[0];
    _budget = widget.site?.budget.toString() ?? '0';
    _description = widget.site?.description ?? '';
    _isNegotiated = widget.site?.isNegotiated ?? false;
    _negotiationDetails = widget.site?.negotiationDetails ?? '';
    _isArchived = widget.site?.isArchived ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final site = Site(
      id: widget.site?.id ?? 0,
      name: _name,
      clientName: _clientName,
      organizationName: _organizationName,
      assignedTeam: _assignedTeam,
      address: _address,
      status: _status,
      startDate: _startDate,
      budget: double.tryParse(_budget) ?? 0.0,
      description: _description,
      isNegotiated: _isNegotiated,
      negotiationDetails: _negotiationDetails,
      isArchived: _isArchived,
      workHistory: widget.site?.workHistory ?? [],
      maintenance: widget.site?.maintenance ?? {},
      media: widget.site?.media ?? [],
    );

    try {
      if (widget.site == null) {
        await ref.read(sitesProvider.notifier).addSite(site);
      } else {
        await ref.read(sitesProvider.notifier).updateSite(site);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Site saved successfully!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.site == null ? 'New Site Project' : 'Edit Site Project'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Project Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _clientName,
                decoration: const InputDecoration(labelText: 'Client Name', border: OutlineInputBorder()),
                onSaved: (val) => _clientName = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _organizationName,
                decoration: const InputDecoration(labelText: 'Organization Name', border: OutlineInputBorder()),
                onSaved: (val) => _organizationName = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _assignedTeam,
                decoration: const InputDecoration(labelText: 'Assigned Team', border: OutlineInputBorder()),
                onSaved: (val) => _assignedTeam = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                maxLines: 2,
                onSaved: (val) => _address = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Pre-Construction', 'Currently working', 'Completed', 'Maintenance']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _status = val ?? 'Pre-Construction'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _startDate,
                decoration: const InputDecoration(labelText: 'Start Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                onSaved: (val) => _startDate = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _budget,
                decoration: const InputDecoration(labelText: 'Budget', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _budget = val ?? '0',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 3,
                onSaved: (val) => _description = val ?? '',
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Negotiated'),
                value: _isNegotiated,
                onChanged: (val) => setState(() => _isNegotiated = val),
              ),
              if (_isNegotiated)
                TextFormField(
                  initialValue: _negotiationDetails,
                  decoration: const InputDecoration(labelText: 'Negotiation Details', border: OutlineInputBorder()),
                  onSaved: (val) => _negotiationDetails = val ?? '',
                ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Is Archived'),
                value: _isArchived,
                onChanged: (val) => setState(() => _isArchived = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
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

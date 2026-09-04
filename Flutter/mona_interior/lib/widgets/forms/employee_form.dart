import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/hr_models.dart';
import 'package:mona_interior/providers/hr_provider.dart';

class EmployeeForm extends ConsumerStatefulWidget {
  final Employee? employee;

  const EmployeeForm({super.key, this.employee});

  @override
  ConsumerState<EmployeeForm> createState() => _EmployeeFormState();
}

class _EmployeeFormState extends ConsumerState<EmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late String _name, _role, _department, _phone, _email;
  late String _salary, _joinDate, _status, _address;
  late String _advanceBalance, _bankDetails, _govId, _salaryType, _workerId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.employee?.name ?? '';
    _role = widget.employee?.role ?? '';
    _department = widget.employee?.department ?? '';
    _phone = widget.employee?.phone ?? '';
    _email = widget.employee?.email ?? '';
    _salary = widget.employee?.salary.toString() ?? '0';
    _joinDate = widget.employee?.joinDate ?? DateTime.now().toIso8601String().split('T')[0];
    _status = widget.employee?.status ?? 'Active';
    _address = widget.employee?.address ?? '';
    _advanceBalance = widget.employee?.advanceBalance.toString() ?? '0';
    _bankDetails = widget.employee?.bankDetails ?? '';
    _govId = widget.employee?.govId ?? '';
    _salaryType = widget.employee?.salaryType ?? 'Monthly';
    _workerId = widget.employee?.workerId ?? '';
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final emp = Employee(
      id: widget.employee?.id ?? 0,
      name: _name,
      role: _role,
      department: _department,
      phone: _phone,
      email: _email,
      salary: double.tryParse(_salary) ?? 0.0,
      joinDate: _joinDate,
      status: _status,
      address: _address,
      advanceBalance: double.tryParse(_advanceBalance) ?? 0.0,
      bankDetails: _bankDetails,
      govId: _govId,
      salaryType: _salaryType,
      workerId: _workerId,
    );

    try {
      if (widget.employee == null) {
        await ref.read(hrProvider.notifier).addEmployee(emp);
      } else {
        await ref.read(hrProvider.notifier).updateEmployee(emp);
      }
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee saved successfully!')));
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
      title: Text(widget.employee == null ? 'New Employee' : 'Edit Employee'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _name = val ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _workerId,
                      decoration: const InputDecoration(labelText: 'Worker ID', border: OutlineInputBorder()),
                      onSaved: (val) => _workerId = val ?? '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                      items: ['Active', 'Inactive', 'On Leave'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _status = val ?? 'Active'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _role,
                decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                onSaved: (val) => _role = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _department,
                decoration: const InputDecoration(labelText: 'Department', border: OutlineInputBorder()),
                onSaved: (val) => _department = val ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _phone,
                      decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                      keyboardType: TextInputType.phone,
                      onSaved: (val) => _phone = val ?? '',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _email,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => _email = val ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _salary,
                      decoration: const InputDecoration(labelText: 'Salary', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                      onSaved: (val) => _salary = val ?? '0',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _salaryType,
                      decoration: const InputDecoration(labelText: 'Salary Type', border: OutlineInputBorder()),
                      items: ['Monthly', 'Daily', 'Hourly', 'Weekly'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (val) => setState(() => _salaryType = val ?? 'Monthly'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _joinDate,
                decoration: const InputDecoration(labelText: 'Join Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                onSaved: (val) => _joinDate = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder()),
                maxLines: 2,
                onSaved: (val) => _address = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _bankDetails,
                decoration: const InputDecoration(labelText: 'Bank Details', border: OutlineInputBorder()),
                maxLines: 2,
                onSaved: (val) => _bankDetails = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _govId,
                decoration: const InputDecoration(labelText: 'Govt ID', border: OutlineInputBorder()),
                onSaved: (val) => _govId = val ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _advanceBalance,
                decoration: const InputDecoration(labelText: 'Advance Balance', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _advanceBalance = val ?? '0',
              ),
              const SizedBox(height: 32),
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

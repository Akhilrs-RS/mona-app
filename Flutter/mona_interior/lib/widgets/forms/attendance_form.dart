import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/models/hr_models.dart';
import 'package:mona_interior/providers/hr_provider.dart';

class AttendanceForm extends ConsumerStatefulWidget {
  final List<Employee> employees;

  const AttendanceForm({super.key, required this.employees});

  @override
  ConsumerState<AttendanceForm> createState() => _AttendanceFormState();
}

class _AttendanceFormState extends ConsumerState<AttendanceForm> {
  final _formKey = GlobalKey<FormState>();
  int _employeeId = 0;
  late String _date;
  String _status = 'Present';
  String _overtime = '0';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.employees.isNotEmpty) {
      _employeeId = widget.employees.first.id;
    }
    _date = DateTime.now().toIso8601String().split('T')[0];
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final record = AttendanceRecord(
      id: 0,
      employeeId: _employeeId,
      date: _date,
      status: _status,
      overtime: double.tryParse(_overtime) ?? 0.0,
    );

    try {
      await ref.read(hrProvider.notifier).logAttendance(record);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Attendance logged!')));
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
    if (widget.employees.isEmpty) {
      return AlertDialog(
        title: const Text('Log Attendance'),
        content: const Text('No employees available to log attendance.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('Log Attendance'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<int>(
                value: _employeeId,
                decoration: const InputDecoration(labelText: 'Employee', border: OutlineInputBorder()),
                items: widget.employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                onChanged: (val) => setState(() => _employeeId = val ?? widget.employees.first.id),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _date,
                decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD)', border: OutlineInputBorder()),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                onSaved: (val) => _date = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['Present', 'Absent', 'Half-day', 'On Leave'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _status = val ?? 'Present'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _overtime,
                decoration: const InputDecoration(labelText: 'Overtime (Hours)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (val) => _overtime = val ?? '0',
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

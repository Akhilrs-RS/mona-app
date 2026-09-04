import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/hr_provider.dart';
import 'package:mona_interior/models/hr_models.dart';
import 'package:mona_interior/widgets/forms/employee_form.dart';

class EmployeesScreen extends ConsumerWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hrState = ref.watch(hrProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(hrProvider),
          )
        ],
      ),
      body: hrState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (data) => _buildEmployeesList(context, data.employees),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(context: context, builder: (_) => const EmployeeForm());
        },
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeesList(BuildContext context, List<Employee> employees) {
    if (employees.isEmpty) return const Center(child: Text('No employees found.'));
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: employees.length,
      itemBuilder: (context, index) {
        final emp = employees[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.withValues(alpha: 0.1),
              child: Text(
                emp.name.isNotEmpty ? emp.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.blue),
              ),
            ),
            title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${emp.role}\n${emp.workerId} - ${emp.phone}'),
            trailing: Chip(
              label: Text(emp.status, style: const TextStyle(fontSize: 10)),
              backgroundColor: emp.status.toLowerCase() == 'active' ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
            ),
            isThreeLine: true,
            onTap: () {
              showDialog(context: context, builder: (_) => EmployeeForm(employee: emp));
            },
          ),
        );
      },
    );
  }
}

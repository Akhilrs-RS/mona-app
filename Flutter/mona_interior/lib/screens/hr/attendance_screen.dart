import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/providers/hr_provider.dart';
import 'package:mona_interior/models/hr_models.dart';
import 'package:mona_interior/widgets/forms/attendance_form.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hrState = ref.watch(hrProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
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
        data: (data) => _buildAttendanceList(data.attendanceRecords, data.employees),
      ),
      floatingActionButton: hrState.maybeWhen(
        data: (data) => FloatingActionButton(
          onPressed: () {
            showDialog(context: context, builder: (_) => AttendanceForm(employees: data.employees));
          },
          tooltip: 'Log Attendance',
          child: const Icon(Icons.add),
        ),
        orElse: () => null,
      ),
    );
  }

  Widget _buildAttendanceList(List<AttendanceRecord> records, List<Employee> employees) {
    if (records.isEmpty) return const Center(child: Text('No attendance records found.'));
    
    // Group by date, descending
    records.sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final rec = records[index];
        final emp = employees.firstWhere(
          (e) => e.id == rec.employeeId,
          orElse: () => Employee(
            id: 0, name: 'Unknown', role: '', department: '', phone: '', email: '', 
            salary: 0, joinDate: '', status: '', address: '', advanceBalance: 0, 
            bankDetails: '', govId: '', salaryType: '', workerId: ''
          ),
        );

        Color statusColor = Colors.grey;
        if (rec.status == 'Present') statusColor = Colors.green;
        if (rec.status == 'Absent') statusColor = Colors.red;
        if (rec.status == 'Half-day') statusColor = Colors.orange;

        return Card(
          child: ListTile(
            leading: Icon(Icons.event_available, color: statusColor),
            title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Date: ${rec.date.split('T').first}\nOvertime: ${rec.overtime} hrs'),
            trailing: Text(
              rec.status,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}

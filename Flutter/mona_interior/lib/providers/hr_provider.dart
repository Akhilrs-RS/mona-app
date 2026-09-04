import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/api/api_client.dart';
import 'package:mona_interior/models/hr_models.dart';

class HrState {
  final List<Employee> employees;
  final List<AttendanceRecord> attendanceRecords;

  HrState({
    required this.employees,
    required this.attendanceRecords,
  });

  factory HrState.empty() => HrState(employees: [], attendanceRecords: []);
}

class HrNotifier extends AsyncNotifier<HrState> {
  @override
  Future<HrState> build() async {
    return _fetchData();
  }

  Future<HrState> _fetchData() async {
    final dio = ref.watch(dioProvider);
    try {
      final responses = await Future.wait([
        dio.get('/employees'),
        dio.get('/attendance'),
      ]);

      final employeesList = (responses[0].data as List<dynamic>?) ?? [];
      final attendanceList = (responses[1].data as List<dynamic>?) ?? [];

      return HrState(
        employees: employeesList.map((e) => Employee.fromJson(e as Map<String, dynamic>)).toList(),
        attendanceRecords: attendanceList.map((a) => AttendanceRecord.fromJson(a as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return HrState.empty();
    }
  }

  Future<void> addEmployee(Employee employee) async {
    final dio = ref.read(dioProvider);
    await dio.post('/employees', data: employee.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateEmployee(Employee employee) async {
    final dio = ref.read(dioProvider);
    await dio.put('/employees/${employee.id}', data: employee.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteEmployee(int id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/employees/$id');
    ref.invalidateSelf();
  }

  Future<void> logAttendance(AttendanceRecord record) async {
    final dio = ref.read(dioProvider);
    await dio.post('/attendance', data: record.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateAttendance(AttendanceRecord record) async {
    final dio = ref.read(dioProvider);
    await dio.put('/attendance/${record.id}', data: record.toJson());
    ref.invalidateSelf();
  }
}

final hrProvider = AsyncNotifierProvider<HrNotifier, HrState>(() {
  return HrNotifier();
});

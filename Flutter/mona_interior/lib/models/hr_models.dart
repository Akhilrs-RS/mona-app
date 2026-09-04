class Employee {
  final int id;
  final String name;
  final String role;
  final String department;
  final String phone;
  final String email;
  final double salary;
  final String joinDate;
  final String status;
  final String address;
  final double advanceBalance;
  final String bankDetails;
  final String govId;
  final String salaryType;
  final String workerId;

  Employee({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.phone,
    required this.email,
    required this.salary,
    required this.joinDate,
    required this.status,
    required this.address,
    required this.advanceBalance,
    required this.bankDetails,
    required this.govId,
    required this.salaryType,
    required this.workerId,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      department: json['department'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      salary: double.tryParse(json['salary']?.toString() ?? '0') ?? 0.0,
      joinDate: json['joinDate'] ?? '',
      status: json['status'] ?? '',
      address: json['address'] ?? '',
      advanceBalance: double.tryParse(json['advanceBalance']?.toString() ?? '0') ?? 0.0,
      bankDetails: json['bankDetails'] ?? '',
      govId: json['govId'] ?? '',
      salaryType: json['salaryType'] ?? '',
      workerId: json['workerId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'name': name,
      'role': role,
      'department': department,
      'phone': phone,
      'email': email,
      'salary': salary,
      'joinDate': joinDate,
      'status': status,
      'address': address,
      'advanceBalance': advanceBalance,
      'bankDetails': bankDetails,
      'govId': govId,
      'salaryType': salaryType,
      'workerId': workerId,
    };
  }
}

class AttendanceRecord {
  final int id;
  final int employeeId;
  final String date;
  final String status;
  final double overtime;

  AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    required this.overtime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      employeeId: json['employeeId'] is int ? json['employeeId'] : int.tryParse(json['employeeId']?.toString() ?? '0') ?? 0,
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      overtime: double.tryParse(json['overtime']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != 0) 'id': id,
      'employeeId': employeeId,
      'date': date,
      'status': status,
      'overtime': overtime,
    };
  }
}

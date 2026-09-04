class Invoice {
  final String id;
  final String invoiceNo;
  final String invoiceDate;
  final String clientName;
  final String projectTitle;
  final double total;
  final String status;
  final String billType;
  final String date;
  final List<dynamic> items;

  Invoice({
    required this.id,
    required this.invoiceNo,
    required this.invoiceDate,
    required this.clientName,
    required this.projectTitle,
    required this.total,
    required this.status,
    required this.billType,
    required this.date,
    required this.items,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id']?.toString() ?? '',
      invoiceNo: json['invoiceNo'] ?? '',
      invoiceDate: json['invoiceDate'] ?? '',
      clientName: json['clientName'] ?? '',
      projectTitle: json['projectTitle'] ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      billType: json['billType'] ?? '',
      date: json['date'] ?? '',
      items: json['items'] is List ? json['items'] : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'invoiceNo': invoiceNo,
      'invoiceDate': invoiceDate,
      'clientName': clientName,
      'projectTitle': projectTitle,
      'total': total,
      'status': status,
      'billType': billType,
      'date': date,
      'items': items,
    };
  }
}

class Receipt {
  final String id;
  final String receiptNo;
  final String date;
  final String siteId;
  final String clientName;
  final double totalAmount;
  final double amountPaid;
  final double remainingAmount;
  final String status;
  final String category;
  final String paymentMode;

  Receipt({
    required this.id,
    required this.receiptNo,
    required this.date,
    required this.siteId,
    required this.clientName,
    required this.totalAmount,
    required this.amountPaid,
    required this.remainingAmount,
    required this.status,
    required this.category,
    required this.paymentMode,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id']?.toString() ?? '',
      receiptNo: json['receiptNo'] ?? '',
      date: json['date'] ?? '',
      siteId: json['siteId']?.toString() ?? '',
      clientName: json['clientName'] ?? '',
      totalAmount: double.tryParse(json['totalAmount']?.toString() ?? '0') ?? 0.0,
      amountPaid: double.tryParse(json['amountPaid']?.toString() ?? '0') ?? 0.0,
      remainingAmount: double.tryParse(json['remainingAmount']?.toString() ?? '0') ?? 0.0,
      status: json['status'] ?? '',
      category: json['category'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'receiptNo': receiptNo,
      'date': date,
      'siteId': siteId,
      'clientName': clientName,
      'totalAmount': totalAmount,
      'amountPaid': amountPaid,
      'remainingAmount': remainingAmount,
      'status': status,
      'category': category,
      'paymentMode': paymentMode,
    };
  }
}

class Expense {
  final String id;
  final String date;
  final String category;
  final String description;
  final double amount;
  final String clientId;
  final String type;

  Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
    required this.clientId,
    required this.type,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      clientId: json['clientId']?.toString() ?? '',
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'date': date,
      'category': category,
      'description': description,
      'amount': amount,
      'clientId': clientId,
      'type': type,
    };
  }
}

class LedgerEntry {
  final String id;
  final String date;
  final String type; // "Credit" or "Debit"
  final String category;
  final String description;
  final double amount;

  LedgerEntry({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> json) {
    return LedgerEntry(
      id: json['id']?.toString() ?? '',
      date: json['date'] ?? '',
      type: json['type'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class PayrollRecord {
  final String id;
  final int employeeId;
  final int month;
  final int year;
  final double baseSalary;
  final double deductions;
  final double netPay;
  final String paidDate;
  final String status;
  final dynamic attendanceBreakdown;

  PayrollRecord({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.deductions,
    required this.netPay,
    required this.paidDate,
    required this.status,
    required this.attendanceBreakdown,
  });

  factory PayrollRecord.fromJson(Map<String, dynamic> json) {
    return PayrollRecord(
      id: json['id']?.toString() ?? '',
      employeeId: int.tryParse(json['employeeId']?.toString() ?? '0') ?? 0,
      month: int.tryParse(json['month']?.toString() ?? '0') ?? 1,
      year: int.tryParse(json['year']?.toString() ?? '0') ?? 2024,
      baseSalary: double.tryParse(json['baseSalary']?.toString() ?? '0') ?? 0.0,
      deductions: double.tryParse(json['deductions']?.toString() ?? '0') ?? 0.0,
      netPay: double.tryParse(json['netPay']?.toString() ?? '0') ?? 0.0,
      paidDate: json['paidDate'] ?? '',
      status: json['status'] ?? '',
      attendanceBreakdown: json['attendanceBreakdown'],
    );
  }
}

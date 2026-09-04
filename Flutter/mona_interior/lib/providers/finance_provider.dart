import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mona_interior/api/api_client.dart';
import 'package:mona_interior/models/finance_models.dart';

class FinanceState {
  final List<Invoice> invoices;
  final List<Receipt> receipts;
  final List<Expense> expenses;
  final List<LedgerEntry> ledger;
  final List<PayrollRecord> payroll;

  FinanceState({
    required this.invoices,
    required this.receipts,
    required this.expenses,
    required this.ledger,
    required this.payroll,
  });

  factory FinanceState.empty() => FinanceState(invoices: [], receipts: [], expenses: [], ledger: [], payroll: []);
}

class FinanceNotifier extends AsyncNotifier<FinanceState> {
  @override
  Future<FinanceState> build() async {
    return _fetchData();
  }

  Future<FinanceState> _fetchData() async {
    final dio = ref.watch(dioProvider);
    try {
      final responses = await Future.wait([
        dio.get('/finance/invoices'),
        dio.get('/finance/receipts'),
        dio.get('/finance/expenses'),
        dio.get('/finance/accounts'),
        dio.get('/finance/payroll'),
      ]);

      final invoicesList = (responses[0].data as List<dynamic>?) ?? [];
      final receiptsList = (responses[1].data as List<dynamic>?) ?? [];
      final expensesList = (responses[2].data as List<dynamic>?) ?? [];
      final ledgerList = (responses[3].data as List<dynamic>?) ?? [];
      final payrollList = (responses[4].data as List<dynamic>?) ?? [];

      return FinanceState(
        invoices: invoicesList.map((i) => Invoice.fromJson(i as Map<String, dynamic>)).toList(),
        receipts: receiptsList.map((r) => Receipt.fromJson(r as Map<String, dynamic>)).toList(),
        expenses: expensesList.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList(),
        ledger: ledgerList.map((l) => LedgerEntry.fromJson(l as Map<String, dynamic>)).toList(),
        payroll: payrollList.map((p) => PayrollRecord.fromJson(p as Map<String, dynamic>)).toList(),
      );
    } catch (e) {
      return FinanceState.empty();
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    final dio = ref.read(dioProvider);
    await dio.post('/finance/invoices', data: invoice.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateInvoice(Invoice invoice) async {
    final dio = ref.read(dioProvider);
    await dio.put('/finance/invoices/${invoice.id}', data: invoice.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteInvoice(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/finance/invoices/$id');
    ref.invalidateSelf();
  }

  Future<void> addReceipt(Receipt receipt) async {
    final dio = ref.read(dioProvider);
    await dio.post('/finance/receipts', data: receipt.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateReceipt(Receipt receipt) async {
    final dio = ref.read(dioProvider);
    await dio.put('/finance/receipts/${receipt.id}', data: receipt.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteReceipt(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/finance/receipts/$id');
    ref.invalidateSelf();
  }

  Future<void> addExpense(Expense expense) async {
    final dio = ref.read(dioProvider);
    await dio.post('/finance/expenses', data: expense.toJson());
    ref.invalidateSelf();
  }

  Future<void> updateExpense(Expense expense) async {
    final dio = ref.read(dioProvider);
    await dio.put('/finance/expenses/${expense.id}', data: expense.toJson());
    ref.invalidateSelf();
  }

  Future<void> deleteExpense(String id) async {
    final dio = ref.read(dioProvider);
    await dio.delete('/finance/expenses/$id');
    ref.invalidateSelf();
  }
}

final financeProvider = AsyncNotifierProvider<FinanceNotifier, FinanceState>(() {
  return FinanceNotifier();
});

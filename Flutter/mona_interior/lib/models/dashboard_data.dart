class DashboardData {
  final double totalIncome;
  final double totalSpent;
  final double netProfit;
  final double totalWOValue;
  final int pendingQuotes;
  final int inProcessSites;
  final int pendingWO;
  final double totalPayroll;
  final double totalAdvances;
  final int presentToday;
  final List<dynamic> receipts;
  final List<dynamic> expenses;
  final List<dynamic> payroll;
  final List<dynamic> sites;

  DashboardData({
    required this.totalIncome,
    required this.totalSpent,
    required this.netProfit,
    required this.totalWOValue,
    required this.pendingQuotes,
    required this.inProcessSites,
    required this.pendingWO,
    required this.totalPayroll,
    required this.totalAdvances,
    required this.presentToday,
    required this.receipts,
    required this.expenses,
    required this.payroll,
    required this.sites,
  });

  bool get profitPositive => netProfit >= 0;

  factory DashboardData.empty() {
    return DashboardData(
      totalIncome: 0,
      totalSpent: 0,
      netProfit: 0,
      totalWOValue: 0,
      pendingQuotes: 0,
      inProcessSites: 0,
      pendingWO: 0,
      totalPayroll: 0,
      totalAdvances: 0,
      presentToday: 0,
      receipts: [],
      expenses: [],
      payroll: [],
      sites: [],
    );
  }
}

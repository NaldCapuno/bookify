import 'financial_item.dart';

class IncomeStatement {
  final String businessName;
  final DateTime periodStart;
  final DateTime periodEnd;

  // Categorized based on your 400-800 code migration
  final List<FinancialItem> revenues; // 400s
  final List<FinancialItem> costOfSales; // 500s
  final List<FinancialItem> operatingExpenses; // 600s
  final List<FinancialItem> otherExpenses; // 700s
  final List<FinancialItem> taxExpenses; // 800s

  final double totalRevenue;
  final double totalExpenses;
  final double netIncome;

  const IncomeStatement({
    required this.businessName,
    required this.periodStart,
    required this.periodEnd,
    required this.revenues,
    required this.costOfSales,
    required this.operatingExpenses,
    required this.otherExpenses,
    required this.taxExpenses,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netIncome,
  });

  double get totalCostOfSales =>
      costOfSales.fold(0, (sum, item) => sum + item.amount);
  double get grossProfit => totalRevenue - totalCostOfSales;

  String get netIncomeLabel => netIncome >= 0 ? "NET INCOME" : "NET LOSS";
}

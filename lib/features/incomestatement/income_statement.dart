import 'financial_item.dart';

class IncomeStatement {
  final String businessName;
  final DateTime periodStart;
  final DateTime periodEnd;

  // Revenue
  final List<FinancialItem> revenues;
  final double totalRevenue;

  // Expenses grouped by Account Code series
  final List<FinancialItem> costOfSales; // 500s
  final List<FinancialItem> operatingExpenses; // 600s
  final List<FinancialItem> otherExpenses; // 700s
  final List<FinancialItem> taxExpenses; // 800s
  final double totalExpenses;

  // Bottom Line
  final double netIncome;

  const IncomeStatement({
    required this.businessName,
    required this.periodStart,
    required this.periodEnd,
    required this.revenues,
    required this.totalRevenue,
    required this.costOfSales,
    required this.operatingExpenses,
    required this.otherExpenses,
    required this.taxExpenses,
    required this.totalExpenses,
    required this.netIncome,
  });

  bool get hasNoRevenues => revenues.isEmpty;

  // Check if ALL expenses are empty
  bool get hasNoExpenses =>
      costOfSales.isEmpty &&
      operatingExpenses.isEmpty &&
      otherExpenses.isEmpty &&
      taxExpenses.isEmpty;

  // Dynamic Label based on your logic
  String get netIncomeLabel {
    if (netIncome < 0) {
      return "NET INCOME (LOSS)";
    } else {
      return "NET INCOME (GAIN)"; // You can also just return "NET INCOME" if you prefer
    }
  }
}

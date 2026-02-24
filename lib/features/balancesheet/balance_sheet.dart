import 'package:bookkeeping/features/incomestatement/financial_item.dart';

class BalanceSheet {
  final String businessName;
  final DateTime date;

  // Left Column: Assets (100s)
  final List<FinancialItem> currentAssets;
  final List<FinancialItem> nonCurrentAssets;

  // Right Column: Liabilities (200s) & Equity (300s)
  final List<FinancialItem> currentLiabilities;
  final List<FinancialItem> nonCurrentLiabilities;
  final List<FinancialItem> equityItems;
  final double netIncome; // balancing figure from Income Statement

  const BalanceSheet({
    required this.businessName,
    required this.date,
    required this.currentAssets,
    required this.nonCurrentAssets,
    required this.currentLiabilities,
    required this.nonCurrentLiabilities,
    required this.equityItems,
    required this.netIncome,
  });

  // FIX: Use 0.0 instead of 0 to ensure the fold function expects a double
  double get totalCurrentAssets =>
      currentAssets.fold(0.0, (sum, i) => sum + i.amount);
  double get totalNonCurrentAssets =>
      nonCurrentAssets.fold(0.0, (sum, i) => sum + i.amount);
  double get totalAssets => totalCurrentAssets + totalNonCurrentAssets;

  double get totalCurrentLiabilities =>
      currentLiabilities.fold(0.0, (sum, i) => sum + i.amount);
  double get totalNonCurrentLiabilities =>
      nonCurrentLiabilities.fold(0.0, (sum, i) => sum + i.amount);
  double get totalLiabilities =>
      totalCurrentLiabilities + totalNonCurrentLiabilities;

  // FIX: Applied 0.0 here as well to fix the type mismatch error
  double get totalOwnerEquity =>
      equityItems.fold(0.0, (sum, i) => sum + i.amount) + netIncome;

  double get totalLiabilitiesAndEquity => totalLiabilities + totalOwnerEquity;

  // Helper to check if the statement is technically balanced
  bool get isBalanced => (totalAssets - totalLiabilitiesAndEquity).abs() < 0.01;
}

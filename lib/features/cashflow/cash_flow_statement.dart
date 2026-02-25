import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';

class CashFlowStatement {
  final String businessName;
  final DateTime startDate;
  final DateTime endDate;

  final IncomeStatement incomeStatement;
  final BalanceSheet beginningBalanceSheet;
  final BalanceSheet endingBalanceSheet;

  const CashFlowStatement({
    required this.businessName,
    required this.startDate,
    required this.endDate,
    required this.incomeStatement,
    required this.beginningBalanceSheet,
    required this.endingBalanceSheet,
  });

  // ==========================================
  // 1. OPERATING ACTIVITIES
  // ==========================================
  double get netIncome => incomeStatement.netIncome;

  // Find Depreciation Expense from the Income Statement to add it back
  double get depreciationExpense {
    final allExpenses = [
      ...incomeStatement.operatingExpenses,
      ...incomeStatement.otherExpenses,
    ];
    return allExpenses
        .where((e) => e.name.toLowerCase().contains('depreciation'))
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // Changes in Current Assets (EXCLUDING Cash itself)
  // Formula: Beginning - Ending (Because asset increase = cash decrease)
  List<FinancialItem> get operatingAssetChanges {
    return _calculateChanges(
      beginningBalanceSheet.currentAssets,
      endingBalanceSheet.currentAssets,
      invertRule: true, // Inverse relationship to cash
      excludeNames: [
        'cash',
        'bank',
        'cash in bank',
      ], // Never include cash here!
    );
  }

  // Changes in Current Liabilities
  // Formula: Ending - Beginning (Because liability increase = cash increase)
  List<FinancialItem> get operatingLiabilityChanges {
    return _calculateChanges(
      beginningBalanceSheet.currentLiabilities,
      endingBalanceSheet.currentLiabilities,
      invertRule: false,
    );
  }

  double get netCashFromOperating =>
      netIncome +
      depreciationExpense +
      operatingAssetChanges.fold(0.0, (s, e) => s + e.amount) +
      operatingLiabilityChanges.fold(0.0, (s, e) => s + e.amount);

  // ==========================================
  // 2. INVESTING ACTIVITIES
  // ==========================================
  // Changes in Long-Term Assets (e.g., buying equipment)
  List<FinancialItem> get investingActivities {
    return _calculateChanges(
      beginningBalanceSheet.nonCurrentAssets,
      endingBalanceSheet.nonCurrentAssets,
      invertRule: true,
      excludeNames: ['accumulated depreciation'], // Handled in operating
    );
  }

  double get netCashFromInvesting =>
      investingActivities.fold(0.0, (s, e) => s + e.amount);

  // ==========================================
  // 3. FINANCING ACTIVITIES
  // ==========================================
  // Changes in Long-Term Liabilities
  List<FinancialItem> get financingLiabilities {
    return _calculateChanges(
      beginningBalanceSheet.nonCurrentLiabilities,
      endingBalanceSheet.nonCurrentLiabilities,
      invertRule: false,
    );
  }

  // Changes in Equity (EXCLUDING Net Income, as that's already at the top!)
  List<FinancialItem> get financingEquity {
    return _calculateChanges(
      beginningBalanceSheet.equityItems,
      endingBalanceSheet.equityItems,
      invertRule: false,
      excludeNames: ['retained earnings', 'net income'],
    );
  }

  double get netCashFromFinancing =>
      financingLiabilities.fold(0.0, (s, e) => s + e.amount) +
      financingEquity.fold(0.0, (s, e) => s + e.amount);

  // ==========================================
  // NET CASH INCREASE/DECREASE
  // ==========================================
  double get netIncreaseInCash =>
      netCashFromOperating + netCashFromInvesting + netCashFromFinancing;

  double get beginningCashBalance =>
      _getCashBalance(beginningBalanceSheet.currentAssets);
  double get endingCashBalance =>
      _getCashBalance(endingBalanceSheet.currentAssets);

  // Checks if our math matches the actual balance sheet (It always should!)
  bool get isBalanced =>
      (beginningCashBalance + netIncreaseInCash - endingCashBalance).abs() <
      0.01;

  // ==========================================
  // PRIVATE HELPERS
  // ==========================================

  // FIX: Use .any() to catch "Cash on Hand" or "Cash in Bank"
  double _getCashBalance(List<FinancialItem> assets) {
    return assets
        .where(
          (e) => [
            'cash',
            'bank',
          ].any((term) => e.name.toLowerCase().contains(term)),
        )
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<FinancialItem> _calculateChanges(
    List<FinancialItem> beginning,
    List<FinancialItem> ending, {
    required bool invertRule,
    List<String> excludeNames = const [],
  }) {
    List<FinancialItem> changes = [];
    final allNames = {
      ...beginning.map((e) => e.name),
      ...ending.map((e) => e.name),
    };

    for (var name in allNames) {
      // FIX: Use .any() so it catches substrings correctly and skips them
      bool isExcluded = excludeNames.any(
        (ex) => name.toLowerCase().contains(ex),
      );
      if (isExcluded) continue;

      double begAmount = beginning
          .firstWhere(
            (e) => e.name == name,
            orElse: () => const FinancialItem(name: '', amount: 0),
          )
          .amount;
      double endAmount = ending
          .firstWhere(
            (e) => e.name == name,
            orElse: () => const FinancialItem(name: '', amount: 0),
          )
          .amount;

      double difference = invertRule
          ? (begAmount - endAmount)
          : (endAmount - begAmount);

      if (difference != 0) {
        changes.add(FinancialItem(name: name, amount: difference));
      }
    }
    return changes;
  }
}

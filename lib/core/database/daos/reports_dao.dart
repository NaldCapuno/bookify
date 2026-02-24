import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/journal_table.dart';
import 'package:bookkeeping/core/database/tables/transactions_table.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'reports_dao.g.dart';

@DriftAccessor(tables: [Accounts, Transactions, Journals])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(AppDatabase db) : super(db);

  Future<IncomeStatement> getIncomeStatement({
    required DateTime startDate,
    required DateTime endDate,
    required String businessName,
  }) async {
    // 1. Define the aggregate columns
    final debitSum = db.transactions.debit.sum();
    final creditSum = db.transactions.credit.sum();

    // 2. Build the base query with joins
    final query = db.select(db.accounts).join([
      innerJoin(
        db.transactions,
        db.transactions.accountId.equalsExp(db.accounts.id),
      ),
      innerJoin(
        db.journals,
        db.journals.id.equalsExp(db.transactions.journalId),
      ),
    ]);

    // 3. Add filters and group by
    query.where(db.journals.date.isBetweenValues(startDate, endDate));
    query.where(db.journals.isVoid.equals(false));
    query.groupBy([db.accounts.id]);

    // 4. FIX: Add columns first (this returns void), THEN call get()
    query.addColumns([debitSum, creditSum]); // This modifies the query in place
    final List<TypedResult> results = await query
        .get(); // Now execute the query

    // --- Data Processing ---
    List<FinancialItem> revenues = [];
    List<FinancialItem> costOfSales = [];
    List<FinancialItem> operatingExpenses = [];
    List<FinancialItem> otherExpenses = [];
    List<FinancialItem> taxExpenses = [];

    double totalRev = 0;
    double totalExp = 0;

    for (var row in results) {
      final account = row.readTable(db.accounts);
      final totalDebit = row.read(debitSum) ?? 0.0;
      final totalCredit = row.read(creditSum) ?? 0.0;

      double balance = 0;

      // Logic based on COA: 400s (Revenue) are Credit-normal. 500-800s (Expenses) are Debit-normal.
      if (account.code >= 400 && account.code < 500) {
        balance = totalCredit - totalDebit;
      } else {
        balance = totalDebit - totalCredit;
      }

      if (balance == 0) continue;

      final item = FinancialItem(name: account.name, amount: balance);

      if (account.code >= 400 && account.code < 500) {
        revenues.add(item);
        totalRev += balance;
      } else if (account.code >= 500 && account.code < 600) {
        costOfSales.add(item);
        totalExp += balance;
      } else if (account.code >= 600 && account.code < 700) {
        operatingExpenses.add(item);
        totalExp += balance;
      } else if (account.code >= 700 && account.code < 800) {
        otherExpenses.add(item);
        totalExp += balance;
      } else if (account.code >= 800 && account.code < 900) {
        taxExpenses.add(item);
        totalExp += balance;
      }
    }

    return IncomeStatement(
      businessName: businessName,
      periodStart: startDate,
      periodEnd: endDate,
      revenues: revenues,
      costOfSales: costOfSales,
      operatingExpenses: operatingExpenses,
      otherExpenses: otherExpenses,
      taxExpenses: taxExpenses,
      totalRevenue: totalRev,
      totalExpenses: totalExp,
      netIncome: totalRev - totalExp,
    );
  }

  // Inside ReportsDao
  Future<BalanceSheet> getBalanceSheet({
    required DateTime date,
    required String businessName,
  }) async {
    final debitSum = db.transactions.debit.sum();
    final creditSum = db.transactions.credit.sum();

    // 1. Get balances for Assets, Liabilities, and Equity
    final query =
        db.select(db.accounts).join([
            innerJoin(
              db.transactions,
              db.transactions.accountId.equalsExp(db.accounts.id),
            ),
            innerJoin(
              db.journals,
              db.journals.id.equalsExp(db.transactions.journalId),
            ),
          ])
          ..where(db.journals.date.isSmallerOrEqualValue(date))
          ..where(db.journals.isVoid.equals(false))
          ..groupBy([db.accounts.id]);

    query.addColumns([debitSum, creditSum]);
    final results = await query.get();

    // 2. Fetch Net Income for the same period to balance
    // We reuse your Income Statement logic but for a 0-start-date range
    final incomeStatement = await getIncomeStatement(
      startDate: DateTime(1900), // All time revenue/expenses
      endDate: date,
      businessName: businessName,
    );

    List<FinancialItem> curAssets = [];
    List<FinancialItem> nonCurAssets = [];
    List<FinancialItem> curLiab = [];
    List<FinancialItem> nonCurLiab = [];
    List<FinancialItem> equity = [];

    for (var row in results) {
      final account = row.readTable(db.accounts);
      final d = row.read(debitSum) ?? 0.0;
      final c = row.read(creditSum) ?? 0.0;

      // Assets: Debit - Credit | Liab/Equity: Credit - Debit
      double amount = (account.code < 200) ? d - c : c - d;
      if (amount == 0) continue;

      final item = FinancialItem(name: account.name, amount: amount);

      // Map to your migration categories (11, 12, 21, 22, 31)
      switch (account.categoryId) {
        case 11:
          curAssets.add(item);
          break;
        case 12:
          nonCurAssets.add(item);
          break;
        case 21:
          curLiab.add(item);
          break;
        case 22:
          nonCurLiab.add(item);
          break;
        case 31:
          equity.add(item);
          break;
      }
    }

    return BalanceSheet(
      businessName: businessName,
      date: date,
      currentAssets: curAssets,
      nonCurrentAssets: nonCurAssets,
      currentLiabilities: curLiab,
      nonCurrentLiabilities: nonCurLiab,
      equityItems: equity,
      netIncome: incomeStatement.netIncome,
    );
  }
}

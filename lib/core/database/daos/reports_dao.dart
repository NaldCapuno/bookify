import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/journal_table.dart';
import 'package:bookkeeping/core/database/tables/transactions_table.dart'; // Ensure this is imported
import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_statement.dart';
import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';

part 'reports_dao.g.dart';

@DriftAccessor(tables: [Accounts, Transactions, Journals, Users])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(AppDatabase db) : super(db);

  // Helper to get dynamic business name from the Users table
  Future<String> _getDynamicBusinessName() async {
    final user =
        await (db.select(db.users)
              ..where((u) => u.isActive.equals(true))
              ..limit(1))
            .getSingleOrNull();
    return user?.business ?? "My Business";
  }

  Future<IncomeStatement> getIncomeStatement({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final businessName = await _getDynamicBusinessName();
    final debitSum = db.transactions.debit.sum();
    final creditSum = db.transactions.credit.sum();

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

    query.where(db.journals.date.isBetweenValues(startDate, endDate));
    query.where(db.journals.isVoid.equals(false));
    query.groupBy([db.accounts.id]);
    query.addColumns([debitSum, creditSum]);

    final List<TypedResult> results = await query.get();

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

      double balance = (account.code >= 400 && account.code < 500)
          ? totalCredit - totalDebit
          : totalDebit - totalCredit;

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

  Future<BalanceSheet> getBalanceSheet({required DateTime date}) async {
    final businessName = await _getDynamicBusinessName();
    final debitSum = db.transactions.debit.sum();
    final creditSum = db.transactions.credit.sum();

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

    final incomeStatement = await getIncomeStatement(
      startDate: DateTime(1900),
      endDate: date,
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

      double amount = (account.code < 200) ? d - c : c - d;
      if (amount == 0) continue;

      final item = FinancialItem(name: account.name, amount: amount);

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

  Future<CashFlowStatement> getCashFlowStatement({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 1. Fetch the Income Statement for the period
    final incomeStatement = await getIncomeStatement(
      startDate: startDate,
      endDate: endDate,
    );

    // 2. Fetch the Balance Sheet exactly 1 day before the period started
    final beginningDate = startDate.subtract(const Duration(seconds: 1));
    final beginningBalanceSheet = await getBalanceSheet(date: beginningDate);

    // 3. Fetch the Balance Sheet at the end of the period
    final endingBalanceSheet = await getBalanceSheet(date: endDate);

    // 4. Pass them all to our smart model!
    return CashFlowStatement(
      businessName: incomeStatement.businessName,
      startDate: startDate,
      endDate: endDate,
      incomeStatement: incomeStatement,
      beginningBalanceSheet: beginningBalanceSheet,
      endingBalanceSheet: endingBalanceSheet,
    );
  }
}

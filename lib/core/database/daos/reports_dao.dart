import 'package:drift/drift.dart';
import '../app_database.dart';

import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/journal_table.dart';
import 'package:bookkeeping/core/database/tables/transactions_table.dart';

import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';

part 'reports_dao.g.dart';

@DriftAccessor(tables: [Accounts, AccountCategories, Journals, Transactions])
class ReportsDao extends DatabaseAccessor<AppDatabase> with _$ReportsDaoMixin {
  ReportsDao(super.db);

  /// Generates the Income Statement for a specific date range, structured
  /// strictly by Revenue, Cost of Sales, OPEX, Other Expenses, and Taxes.
  Future<IncomeStatement> getIncomeStatement({
    required DateTime startDate,
    required DateTime endDate,
    String businessName = "My Business",
  }) async {
    // Prepare the lists to hold our line items
    List<FinancialItem> revenues = [];
    List<FinancialItem> costOfSales = []; // 500s
    List<FinancialItem> operatingExpenses = []; // 600s
    List<FinancialItem> otherExpenses = []; // 700s
    List<FinancialItem> taxExpenses = []; // 800s

    double totalRevenue = 0.0;
    double totalExpenses = 0.0;

    // 1. Query the database
    // Join transactions with journals, accounts, and categories.
    // Filter by the date range AND ensure the journal is not voided.
    final query =
        select(transactions).join([
          innerJoin(journals, journals.id.equalsExp(transactions.journalId)),
          innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
          innerJoin(
            accountCategories,
            accountCategories.id.equalsExp(accounts.categoryId),
          ),
        ])..where(
          journals.date.isBetweenValues(startDate, endDate) &
              journals.isVoid.equals(false),
        );

    final results = await query.get();

    // 2. Aggregate the balances grouped by Account ID
    // We store the account's code so we can easily group the expenses later.
    final Map<int, Map<String, dynamic>> accountBalances = {};

    for (final row in results) {
      final account = row.readTable(accounts);
      final category = row.readTable(accountCategories);
      final transaction = row.readTable(transactions);

      // Check if the category or its parent is 4 (Revenue) or 5 (Expense)
      final isRevenue = category.id == 4 || category.parent == 4;
      final isExpense = category.id == 5 || category.parent == 5;

      // Skip Assets (1), Liabilities (2), and Equity (3)
      if (!isRevenue && !isExpense) continue;

      if (!accountBalances.containsKey(account.id)) {
        accountBalances[account.id] = {
          'name': account.name,
          'code': account.code, // <-- Crucial for grouping the 500s/600s
          'isRevenue': isRevenue,
          'balance': 0.0,
        };
      }

      // 3. Calculate the running balance using your NormalBalance enum
      double amount = 0.0;
      if (category.normalBalance == NormalBalance.credit) {
        // Normal Balance Credit: Credits increase it, Debits decrease it
        amount = transaction.credit - transaction.debit;
      } else if (category.normalBalance == NormalBalance.debit) {
        // Normal Balance Debit: Debits increase it, Credits decrease it
        amount = transaction.debit - transaction.credit;
      }

      accountBalances[account.id]!['balance'] += amount;
    }

    // 4. Distribute the aggregated balances into their proper UI categories
    accountBalances.forEach((id, data) {
      final balance = data['balance'] as double;
      final name = data['name'] as String;
      final code = data['code'] as int;
      final isRevenue = data['isRevenue'] as bool;

      // Ignore accounts that had a net-zero balance for this period
      if (balance != 0) {
        if (isRevenue) {
          revenues.add(FinancialItem(name: name, amount: balance));
          totalRevenue += balance;
        } else {
          // Group the expenses by the hundreds series (e.g., 501 ~/ 100 = 5)
          int series = code ~/ 100;

          if (series == 5) {
            costOfSales.add(FinancialItem(name: name, amount: balance));
          } else if (series == 6) {
            operatingExpenses.add(FinancialItem(name: name, amount: balance));
          } else if (series == 7) {
            otherExpenses.add(FinancialItem(name: name, amount: balance));
          } else if (series == 8) {
            taxExpenses.add(FinancialItem(name: name, amount: balance));
          } else {
            // Fallback for any unexpected expense codes (e.g. if someone adds a 900 account)
            otherExpenses.add(FinancialItem(name: name, amount: balance));
          }

          totalExpenses += balance;
        }
      }
    });

    // 5. Sort all lists alphabetically for a clean presentation
    revenues.sort((a, b) => a.name.compareTo(b.name));
    costOfSales.sort((a, b) => a.name.compareTo(b.name));
    operatingExpenses.sort((a, b) => a.name.compareTo(b.name));
    otherExpenses.sort((a, b) => a.name.compareTo(b.name));
    taxExpenses.sort((a, b) => a.name.compareTo(b.name));

    // 6. Calculate the Bottom Line
    final netIncome = totalRevenue - totalExpenses;

    // 7. Return the neatly packaged UI Model
    return IncomeStatement(
      businessName: businessName,
      periodStart: startDate,
      periodEnd: endDate,
      revenues: revenues,
      totalRevenue: totalRevenue,
      costOfSales: costOfSales,
      operatingExpenses: operatingExpenses,
      otherExpenses: otherExpenses,
      taxExpenses: taxExpenses,
      totalExpenses: totalExpenses,
      netIncome: netIncome,
    );
  }
}

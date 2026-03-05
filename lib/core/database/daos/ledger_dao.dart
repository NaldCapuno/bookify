import 'package:drift/drift.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/database/tables/journal_table.dart';
import 'package:bookkeeping/core/database/tables/transactions_table.dart';

part 'ledger_dao.g.dart';

class LedgerEntry {
  final Account account;
  final AccountCategory category;
  final double balance;
  final int transactionCount;

  LedgerEntry({
    required this.account,
    required this.category,
    required this.balance,
    required this.transactionCount,
  });
}

@DriftAccessor(tables: [Accounts, AccountCategories, Journals, Transactions])
class LedgerDao extends DatabaseAccessor<AppDatabase> with _$LedgerDaoMixin {
  LedgerDao(super.db);

  Stream<List<LedgerEntry>> watchLedgerEntries() {
    // Only aggregate transactions from non-voided journals (soft-delete).
    final nonVoidFilter = journals.id.isNotNull();
    final debitSum = transactions.debit.sum(filter: nonVoidFilter);
    final creditSum = transactions.credit.sum(filter: nonVoidFilter);
    final txCount = transactions.id.count(filter: nonVoidFilter);

    final query = select(accounts).join([
      innerJoin(
        accountCategories,
        accountCategories.id.equalsExp(accounts.categoryId),
      ),
      leftOuterJoin(
        transactions,
        transactions.accountId.equalsExp(accounts.id),
      ),
      leftOuterJoin(
        journals,
        journals.id.equalsExp(transactions.journalId) &
            journals.isVoid.equals(false),
      ),
    ]);

    // Add aggregate columns to the selection so row.read(debitSum) etc. work
    query.addColumns([debitSum, creditSum, txCount]);

    query.groupBy([accounts.id]);

    return query.watch().map((rows) {
      return rows.map((row) {
        final accountData = row.readTable(accounts);
        final categoryData = row.readTable(accountCategories);

        final totalDebit = row.read(debitSum) ?? 0.0;
        final totalCredit = row.read(creditSum) ?? 0.0;
        final count = row.read(txCount) ?? 0;

        // Balance calculation logic based on your NormalBalance enum
        double calculatedBalance;
        if (categoryData.normalBalance == NormalBalance.debit) {
          calculatedBalance = totalDebit - totalCredit;
        } else {
          calculatedBalance = totalCredit - totalDebit;
        }

        return LedgerEntry(
          account: accountData,
          category: categoryData,
          balance: calculatedBalance,
          transactionCount: count,
        );
      }).toList();
    });
  }

  /// Stream of balance for a single account by code (e.g. 101 Cash, 102 Bank).
  /// Use for quick action screens to show current balance and insufficient balance checks.
  Stream<double> watchBalanceForAccountCode(int code) {
    return watchLedgerEntries().map((list) {
      for (final e in list) {
        if (e.account.code == code) return e.balance;
      }
      return 0.0;
    });
  }

  /// Stream of balances for multiple account codes.
  /// Returns a map: code -> balance (0.0 when not found).
  Stream<Map<int, double>> watchBalancesForAccountCodes(Set<int> codes) {
    return watchLedgerEntries().map((list) {
      final Map<int, double> out = {for (final c in codes) c: 0.0};
      for (final e in list) {
        final code = e.account.code;
        if (out.containsKey(code)) out[code] = e.balance;
      }
      return out;
    });
  }

  /// Stream of transactions for one account, joined with journal (date, description).
  /// Excludes voided journal entries (soft-delete) so they are hidden in the ledger.
  Stream<List<TypedResult>> watchTransactionsForAccount(int accountId) {
    final query = select(transactions).join([
      innerJoin(journals, journals.id.equalsExp(transactions.journalId)),
    ]);
    query.where(
      transactions.accountId.equals(accountId) &
          journals.isVoid.equals(false),
    );
    query.orderBy([OrderingTerm.asc(journals.date)]);
    return query.watch();
  }
}

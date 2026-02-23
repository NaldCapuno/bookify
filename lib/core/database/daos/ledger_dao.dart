import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/account_categories_table.dart';
import '../tables/journal_table.dart';
import '../tables/transactions_table.dart';

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
  LedgerDao(AppDatabase db) : super(db);

  Stream<List<LedgerEntry>> watchLedgerEntries() {
    final debitSum = transactions.debit.sum();
    final creditSum = transactions.credit.sum();
    final txCount = transactions.id.count();

    final query = select(accounts).join([
      innerJoin(
        accountCategories,
        accountCategories.id.equalsExp(accounts.categoryId),
      ),
      leftOuterJoin(
        transactions,
        transactions.accountId.equalsExp(accounts.id),
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

  /// Stream of transactions for one account, joined with journal (date, description).
  /// Used by the ledger card expanded view for "read per account in journal+transaction".
  Stream<List<TypedResult>> watchTransactionsForAccount(int accountId) {
    final query = select(transactions).join([
      innerJoin(journals, journals.id.equalsExp(transactions.journalId)),
    ]);
    query.where(transactions.accountId.equals(accountId));
    query.orderBy([OrderingTerm.asc(journals.date)]);
    return query.watch();
  }
}

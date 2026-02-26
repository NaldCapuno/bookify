import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/journal_table.dart';
import '../tables/transactions_table.dart';
import '../tables/accounts_table.dart';
// import '../tables/account_categories_table.dart';

part 'journal_entry_daos.g.dart';

class JournalSummary {
  final Journal journal;
  final int accountCount;
  final double totalAmount;
  final List<TransactionWithAccount> details;

  JournalSummary({
    required this.journal,
    required this.accountCount,
    required this.totalAmount,
    required this.details,
  });
}

class AccountWithCategory {
  final Account account;
  final AccountCategory category;

  AccountWithCategory({required this.account, required this.category});
}

class TransactionWithAccount {
  final Transaction transactionLine;
  final Account account;

  TransactionWithAccount({
    required this.transactionLine,
    required this.account,
  });
}

@DriftAccessor(tables: [Journals, Transactions, Accounts])
class JournalEntryDao extends DatabaseAccessor<AppDatabase>
    with _$JournalEntryDaoMixin {
  JournalEntryDao(super.db);

  Stream<List<JournalSummary>> watchJournalSummaries() {
    final query = select(journals).join([
      innerJoin(transactions, transactions.journalId.equalsExp(journals.id)),
      innerJoin(accounts, accounts.id.equalsExp(transactions.accountId)),
    ]);

    query.orderBy([
      OrderingTerm.desc(journals.date),
      OrderingTerm.desc(journals.createdAt),
    ]);

    return query.watch().map((rows) {
      final groupedData = <Journal, List<TransactionWithAccount>>{};

      for (final row in rows) {
        final journal = row.readTable(journals);
        final detail = TransactionWithAccount(
          transactionLine: row.readTable(transactions),
          account: row.readTable(accounts),
        );

        groupedData.putIfAbsent(journal, () => []).add(detail);
      }

      return groupedData.entries.map((entry) {
        final journal = entry.key;
        final detailsList = entry.value;

        final accountCount = detailsList.length;
        final totalAmount = detailsList.fold<double>(
          0.0,
          (sum, item) => sum + item.transactionLine.debit,
        );

        return JournalSummary(
          journal: journal,
          accountCount: accountCount,
          totalAmount: totalAmount,
          details: detailsList,
        );
      }).toList();
    });
  }

  Future<List<AccountWithCategory>> getAccountsWithCategories() async {
    final query =
        select(accounts).join([
          innerJoin(
            accountCategories,
            accountCategories.id.equalsExp(accounts.categoryId),
          ),
        ])..where(
          accounts.isActive.equals(true) & accounts.isArchived.equals(false),
        );

    final rows = await query.get();

    return rows.map((row) {
      return AccountWithCategory(
        account: row.readTable(accounts),
        category: row.readTable(accountCategories),
      );
    }).toList();
  }

  Future<List<Account>> getActiveAccounts() {
    return (select(accounts)..where((a) => a.isActive.equals(true))).get();
  }

  Future<void> insertFullJournalEntry({
    required DateTime date,
    required String description,
    String? referenceNo,
    required List<TransactionsCompanion> lines,
  }) async {
    await transaction(() async {
      // 1. Insert the main Journal record
      final journalId = await into(journals).insert(
        JournalsCompanion.insert(
          date: date,
          description: description,
          referenceNo: Value(referenceNo),
        ),
      );

      // 2. Insert all the transaction lines
      for (var line in lines) {
        await into(
          transactions,
        ).insert(line.copyWith(journalId: Value(journalId)));
      }

      // 3. Extract the unique account IDs involved in this transaction
      final accountIds = lines
          .map((line) => line.accountId.value)
          .toSet()
          .toList();

      // 4. Lock the accounts (only if they aren't already locked)
      await (update(accounts)
            ..where((a) => a.id.isIn(accountIds) & a.isLocked.equals(false)))
          .write(const AccountsCompanion(isLocked: Value(true)));
    });
  }

  Stream<List<Journal>> watchAllJournals() {
    return (select(
      journals,
    )..orderBy([(t) => OrderingTerm.desc(t.date)])).watch();
  }

  Future<void> markJournalAsVoided(int journalId) async {
    await (update(journals)..where((j) => j.id.equals(journalId))).write(
      const JournalsCompanion(isVoid: Value(true)),
    );
  }

  Future<void> voidJournalEntry(int journalId) async {
    await (update(journals)..where((j) => j.id.equals(journalId))).write(
      const JournalsCompanion(isVoid: Value(true)),
    );
  }
}

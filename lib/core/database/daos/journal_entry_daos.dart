import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/journal_table.dart';
import '../tables/transactions_table.dart';
import '../tables/accounts_table.dart';

part 'journal_entry_daos.g.dart';

// 1. Add this class at the top of your DAO file (outside the main class)
class JournalSummary {
  final Journal journal;
  final int accountCount;
  final double totalAmount;

  JournalSummary({
    required this.journal,
    required this.accountCount,
    required this.totalAmount,
  });
}

class AccountWithCategory {
  final Account account;
  final AccountCategory category;

  AccountWithCategory({required this.account, required this.category});
}

@DriftAccessor(tables: [Journals, Transactions, Accounts])
class JournalEntryDao extends DatabaseAccessor<AppDatabase>
    with _$JournalEntryDaoMixin {
  JournalEntryDao(super.db);

  Stream<List<JournalSummary>> watchJournalSummaries() {
    // Define our SQL aggregate functions
    final accountCount = transactions.accountId.count();
    final totalAmount = transactions.debit.sum();

    // Create the joined query
    final query = select(journals).join([
      innerJoin(transactions, transactions.journalId.equalsExp(journals.id)),
    ]);

    // Group by the Journal ID so we don't get duplicate rows
    query.groupBy([journals.id]);

    // Order from newest to oldest
    query.orderBy([OrderingTerm.desc(journals.createdAt)]);

    // Tell Drift to calculate our Count and Sum
    query.addColumns([accountCount, totalAmount]);

    // Watch the stream and map the SQL rows to our new JournalSummary class
    return query.watch().map((rows) {
      return rows.map((row) {
        return JournalSummary(
          journal: row.readTable(journals),
          accountCount: row.read(accountCount) ?? 0,
          totalAmount: row.read(totalAmount) ?? 0.0,
        );
      }).toList();
    });
  }

  Future<List<AccountWithCategory>> getAccountsWithCategories() async {
    final query = select(accounts).join([
      innerJoin(
        accountCategories,
        accountCategories.id.equalsExp(accounts.categoryId),
      ),
    ])..where(accounts.isActive.equals(true)); // Only fetch active accounts

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
    // Using a transaction block ensures that if saving a line fails,
    // the whole journal entry is rolled back. No orphaned data!
    await transaction(() async {
      // A. Insert the main Journal record
      final journalId = await into(journals).insert(
        JournalsCompanion.insert(
          date: date,
          description: description,
          referenceNo: Value(referenceNo),
        ),
      );

      // B. Insert all the transaction lines attached to that new Journal ID
      for (var line in lines) {
        await into(transactions).insert(
          // We use copyWith to inject the newly generated journalId
          line.copyWith(journalId: Value(journalId)),
        );
      }
    });
  }

  Stream<List<Journal>> watchAllJournals() {
    return (select(
      journals,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  /// Soft-delete: mark a journal entry as voided. Ledger and reports exclude voided entries.
  Future<void> voidJournalEntry(int journalId) async {
    await (update(journals)..where((j) => j.id.equals(journalId)))
        .write(JournalsCompanion(isVoid: Value(true)));
  }
}

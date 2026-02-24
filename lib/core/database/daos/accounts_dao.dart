import 'package:drift/drift.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';

part 'accounts_dao.g.dart';

// Data class to combine Account and Category info
class AccountRow {
  final Account account;
  final AccountCategory category; // e.g., "Current Asset"
  final AccountCategory? type; // e.g., "Asset"

  AccountRow({required this.account, required this.category, this.type});
}

@DriftAccessor(tables: [Accounts, AccountCategories])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.attachedDatabase);

  // Logic: Stream that groups accounts by their category using a JOIN
  Stream<List<AccountRow>> watchAccountsGrouped() {
    // Alias for joining the category table to itself (to get the Parent Type)
    final parentCategories = alias(accountCategories, 'parent');

    final query = select(accounts).join([
      innerJoin(
        accountCategories,
        accountCategories.id.equalsExp(accounts.categoryId),
      ),
      leftOuterJoin(
        parentCategories,
        parentCategories.id.equalsExp(accountCategories.parent),
      ),
    ]);

    // Order by Category ID (11, 12, 21...) and then by Account Code (101, 102...)
    query.orderBy([
      OrderingTerm.asc(accountCategories.id),
      OrderingTerm.asc(accounts.code),
    ]);

    return query.watch().map((rows) {
      return rows.map((row) {
        return AccountRow(
          account: row.readTable(accounts),
          category: row.readTable(accountCategories),
          type: row.readTableOrNull(parentCategories),
        );
      }).toList();
    });
  }
}

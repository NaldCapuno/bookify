import 'package:drift/drift.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';

part 'accounts_dao.g.dart';


class AccountRow {
  final Account account;
  final AccountCategory category;
  final AccountCategory? type;

  AccountRow({required this.account, required this.category, this.type});
}

@DriftAccessor(tables: [Accounts, AccountCategories])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.attachedDatabase);

  Stream<List<AccountRow>> watchAccountsGrouped() {
    final parentCategories = alias(accountCategories, 'parent');

    final query = select(accounts).join([
      innerJoin(accountCategories, accountCategories.id.equalsExp(accounts.categoryId)),
      leftOuterJoin(parentCategories, parentCategories.id.equalsExp(accountCategories.parent)),
    ]);

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

  Future<int> addAccount(AccountsCompanion entry) => into(accounts).insert(entry);

  Future<List<AccountCategory>> getAllCategories() => 
      (select(accountCategories)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();

  Future<void> archiveAccount(int id, bool archive) => 
      (update(accounts)..where((t) => t.id.equals(id))).write(AccountsCompanion(isArchived: Value(archive)));

  Future<void> deleteAccount(int id) => (delete(accounts)..where((t) => t.id.equals(id))).go();

  Future<bool> isCodeTaken(int codeValue) async {
    final query = select(accounts)..where((t) => t.code.equals(codeValue));
    return (await query.getSingleOrNull()) != null;
  }
}
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_dao.dart';

// ignore_for_file: type=lint
mixin _$LedgerDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountCategoriesTable get accountCategories =>
      attachedDatabase.accountCategories;
  $SystemTagsTable get systemTags => attachedDatabase.systemTags;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $JournalsTable get journals => attachedDatabase.journals;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  LedgerDaoManager get managers => LedgerDaoManager(this);
}

class LedgerDaoManager {
  final _$LedgerDaoMixin _db;
  LedgerDaoManager(this._db);
  $$AccountCategoriesTableTableManager get accountCategories =>
      $$AccountCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.accountCategories,
      );
  $$SystemTagsTableTableManager get systemTags =>
      $$SystemTagsTableTableManager(_db.attachedDatabase, _db.systemTags);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}

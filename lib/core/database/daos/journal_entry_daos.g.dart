// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_entry_daos.dart';

// ignore_for_file: type=lint
mixin _$JournalEntryDaoMixin on DatabaseAccessor<AppDatabase> {
  $JournalsTable get journals => attachedDatabase.journals;
  $AccountCategoriesTable get accountCategories =>
      attachedDatabase.accountCategories;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  JournalEntryDaoManager get managers => JournalEntryDaoManager(this);
}

class JournalEntryDaoManager {
  final _$JournalEntryDaoMixin _db;
  JournalEntryDaoManager(this._db);
  $$JournalsTableTableManager get journals =>
      $$JournalsTableTableManager(_db.attachedDatabase, _db.journals);
  $$AccountCategoriesTableTableManager get accountCategories =>
      $$AccountCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.accountCategories,
      );
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}

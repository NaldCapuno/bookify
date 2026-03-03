// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_dao.dart';

// ignore_for_file: type=lint
mixin _$ReportsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountCategoriesTable get accountCategories =>
      attachedDatabase.accountCategories;
  $SystemTagsTable get systemTags => attachedDatabase.systemTags;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $JournalsTable get journals => attachedDatabase.journals;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $UsersTable get users => attachedDatabase.users;
  ReportsDaoManager get managers => ReportsDaoManager(this);
}

class ReportsDaoManager {
  final _$ReportsDaoMixin _db;
  ReportsDaoManager(this._db);
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
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
}

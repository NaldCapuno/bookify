// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_dao.dart';

// ignore_for_file: type=lint
mixin _$AccountsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountCategoriesTable get accountCategories =>
      attachedDatabase.accountCategories;
  $AccountsTable get accounts => attachedDatabase.accounts;
  AccountsDaoManager get managers => AccountsDaoManager(this);
}

class AccountsDaoManager {
  final _$AccountsDaoMixin _db;
  AccountsDaoManager(this._db);
  $$AccountCategoriesTableTableManager get accountCategories =>
      $$AccountCategoriesTableTableManager(
        _db.attachedDatabase,
        _db.accountCategories,
      );
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
}

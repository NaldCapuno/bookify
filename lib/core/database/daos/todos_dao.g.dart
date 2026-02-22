// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todos_dao.dart';

// ignore_for_file: type=lint
mixin _$TodosDaoMixin on DatabaseAccessor<AppDatabase> {
  $UsersTable get users => attachedDatabase.users;
  $TodosTable get todos => attachedDatabase.todos;
  TodosDaoManager get managers => TodosDaoManager(this);
}

class TodosDaoManager {
  final _$TodosDaoMixin _db;
  TodosDaoManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db.attachedDatabase, _db.users);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db.attachedDatabase, _db.todos);
}

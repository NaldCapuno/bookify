import 'package:app_example/core/database/tables/users_table.dart';
import 'package:drift/drift.dart';

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 255)();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get userId => integer().references(Users, #id)();
}
import 'package:drift/drift.dart';
import 'account_categories_table.dart'; 

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get code => integer().unique()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get categoryId => integer().references(AccountCategories, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
}
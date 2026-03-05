import 'package:drift/drift.dart';
import 'account_categories_table.dart';

enum NormalBalance { debit, credit }

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get code => integer().unique()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().withLength(max: 1024).nullable()();
  IntColumn get categoryId => integer().references(AccountCategories, #id)();
  TextColumn get normalBalance => textEnum<NormalBalance>()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

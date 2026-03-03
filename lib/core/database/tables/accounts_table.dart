import 'package:bookkeeping/core/database/tables/system_tags_table.dart';
import 'package:drift/drift.dart';
import 'account_categories_table.dart';

class Accounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get code => integer().unique()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().withLength(max: 1024).nullable()();
  IntColumn get categoryId => integer().references(AccountCategories, #id)();
  IntColumn get systemTagId => integer().nullable().references(SystemTags, #id)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
}

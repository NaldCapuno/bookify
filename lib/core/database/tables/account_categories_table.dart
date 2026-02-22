import 'package:drift/drift.dart';

// Enum for Debit/Credit
enum NormalBalance { debit, credit }

class AccountCategories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  IntColumn get parent => integer().nullable().references(AccountCategories, #id)(); // FK to itself
  TextColumn get normalBalance => textEnum<NormalBalance>()();
}
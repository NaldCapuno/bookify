import 'package:drift/drift.dart';
import 'journal_table.dart';
import 'accounts_table.dart';

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get journalId => integer().references(Journals, #id)();
  IntColumn get accountId => integer().references(Accounts, #id)();
  RealColumn get debit => real().withDefault(const Constant(0.0))();
  RealColumn get credit => real().withDefault(const Constant(0.0))();
}
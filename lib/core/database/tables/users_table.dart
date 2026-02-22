import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
}
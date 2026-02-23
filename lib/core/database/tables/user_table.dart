import 'package:drift/drift.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 1, max: 255)();
  TextColumn get email => text().withLength(min: 1, max: 255)();
  TextColumn get business => text().nullable().withLength(min: 0, max: 255)();
  TextColumn get businessAddress => text().nullable().withLength(min: 0, max: 255)();
  TextColumn get contactNumber => text().nullable().withLength(min: 0, max: 255)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
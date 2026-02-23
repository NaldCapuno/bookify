import 'package:drift/drift.dart';

class Journals extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  TextColumn get referenceNo => text().nullable()();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isVoid => boolean().withDefault(const Constant(false))();

}

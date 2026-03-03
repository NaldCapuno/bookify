import 'package:drift/drift.dart';

@DataClassName('SystemTag')
class SystemTags extends Table {
  IntColumn get id => integer().autoIncrement()();
  
  TextColumn get code => text().withLength(min: 1, max: 20).unique()();
  TextColumn get displayName => text().withLength(min: 1, max: 50)();
  TextColumn get description => text().nullable()();
}
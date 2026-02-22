import 'package:bookkeeping/core/database/db_migration.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// TODO: Import the tables here
import 'tables/account_categories_table.dart';
import 'tables/accounts_table.dart';

part 'app_database.g.dart';

@DriftDatabase(
  // TODO: Register the tables and DAOs here
  tables: [AccountCategories, Accounts],
  // daos: [AccountCategoriesDao, AccountsDao], // ! Uncomment when ready !
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_db'));

  @override
  int get schemaVersion => 1; // TODO: Don't forget to increase this.

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}

final appDb = AppDatabase();
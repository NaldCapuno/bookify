import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:bookkeeping/core/database/db_migration.dart';

// tables
import 'package:bookkeeping/core/database/tables/transactions_table.dart';
import 'package:bookkeeping/core/database/tables/journal_table.dart';
import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/database/tables/accounts_table.dart';

// daos
import 'package:bookkeeping/core/database/daos/users_dao.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/database/daos/reports_dao.dart';
import 'package:bookkeeping/core/database/daos/accounts_dao.dart';
import 'package:bookkeeping/core/database/daos/ledger_dao.dart';

// TODO: Import the tables here

part 'app_database.g.dart';

@DriftDatabase(
  // TODO: Register the tables and DAOs here
  tables: [AccountCategories, Accounts, Journals, Transactions, Users],
  daos: [UsersDao, JournalEntryDao, ReportsDao, AccountsDao, LedgerDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'app_db'));

  @override
  int get schemaVersion => 14; // TODO: Don't forget to increase this. (int only)

  @override
  MigrationStrategy get migration => buildMigrationStrategy(this);
}

final appDb = AppDatabase();

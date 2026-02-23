import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables/account_categories_table.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      // 1. Create all tables
      await m.createAll();

      // 2. Populate the accountCategories table
      await db.batch((batch) {
        batch.insertAll(db.accountCategories, [
          // --- ROOT CATEGORIES (Types) ---
          AccountCategoriesCompanion.insert(
            id: const Value(1),
            name: 'Asset',
            normalBalance: NormalBalance.debit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(2),
            name: 'Liability',
            normalBalance: NormalBalance.credit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(3),
            name: 'Equity',
            normalBalance: NormalBalance.credit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(4),
            name: 'Revenue',
            normalBalance: NormalBalance.credit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(5),
            name: 'Expense',
            normalBalance: NormalBalance.debit,
          ),

          // --- SUBTYPES (Categories) ---
          // Assets (Parent -> 1)
          AccountCategoriesCompanion.insert(
            id: const Value(11),
            name: 'Current Asset',
            parent: const Value(1),
            normalBalance: NormalBalance.debit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(12),
            name: 'Non-current Asset',
            parent: const Value(1),
            normalBalance: NormalBalance.debit,
          ),

          // Liabilities (Parent -> 2)
          AccountCategoriesCompanion.insert(
            id: const Value(21),
            name: 'Current Liability',
            parent: const Value(2),
            normalBalance: NormalBalance.credit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(22),
            name: 'Non-current Liability',
            parent: const Value(2),
            normalBalance: NormalBalance.credit,
          ),

          // Equity (Parent -> 3)
          AccountCategoriesCompanion.insert(
            id: const Value(31),
            name: 'Owner\'s Equity',
            parent: const Value(3),
            normalBalance: NormalBalance.credit,
          ),

          // Revenue (Parent -> 4)
          AccountCategoriesCompanion.insert(
            id: const Value(41),
            name: 'Operating Revenue',
            parent: const Value(4),
            normalBalance: NormalBalance.credit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(42),
            name: 'Other Income',
            parent: const Value(4),
            normalBalance: NormalBalance.credit,
          ),

          // Expenses (Parent -> 5)
          AccountCategoriesCompanion.insert(
            id: const Value(51),
            name: 'Costs of Sale',
            parent: const Value(5),
            normalBalance: NormalBalance.debit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(52),
            name: 'Operating Expense',
            parent: const Value(5),
            normalBalance: NormalBalance.debit,
          ),
          AccountCategoriesCompanion.insert(
            id: const Value(53),
            name: 'Other Expense',
            parent: const Value(5),
            normalBalance: NormalBalance.debit,
          ),
        ]);
      });

      // 3. Seed one "Cash" account so Mock Detail can be tested without manual setup
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(code: 1000, name: 'Cash', categoryId: 11),
          );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future schema updates here
    },
    beforeOpen: (details) async {
      // Enforce foreign key constraints
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

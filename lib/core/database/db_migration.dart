import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';
import 'tables/account_categories_table.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // 1. Populate the accountCategories table
      await db.batch((batch) {
        batch.insertAll(db.accountCategories, [
          AccountCategoriesCompanion.insert(id: const Value(1), name: 'Asset', normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(2), name: 'Liability', normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(3), name: 'Equity', normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(4), name: 'Revenue', normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(5), name: 'Expense', normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(11), name: 'Current Asset', parent: const Value(1), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(12), name: 'Non-current Asset', parent: const Value(1), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(21), name: 'Current Liability', parent: const Value(2), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(22), name: 'Non-current Liability', parent: const Value(2), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(31), name: 'Owner\'s Equity', parent: const Value(3), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(41), name: 'Operating Revenue', parent: const Value(4), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(51), name: 'Costs of Sale', parent: const Value(5), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(52), name: 'Operating Expense', parent: const Value(5), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(53), name: 'Other Expense', parent: const Value(5), normalBalance: NormalBalance.debit),
        ]);
      });

      // 2. Populate the accounts table (Filtered & Locked)
      await db.batch((batch) {
        batch.insertAll(db.accounts, [
          // ASSETS
          AccountsCompanion.insert(code: 101, name: 'Cash on Hand', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 102, name: 'Cash in Bank', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 110, name: 'Accounts Receivable', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 120, name: 'Inventory - Raw Materials', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 121, name: 'Inventory - Finished Goods', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 130, name: 'Supplies', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 150, name: 'Equipment', categoryId: 12, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 160, name: 'Furniture and Fixtures', categoryId: 12, isLocked: const Value(true)),
          // LIABILITIES
          AccountsCompanion.insert(code: 201, name: 'Accounts Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 215, name: 'Sales Tax Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 230, name: 'Long-Term Loans', categoryId: 22, isLocked: const Value(true)),
          // CAPITAL
          AccountsCompanion.insert(code: 340, name: 'Owner\'s Capital', categoryId: 31, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 341, name: 'Owner\'s Drawings', categoryId: 31, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 310, name: 'Retained Earnings', categoryId: 31, isLocked: const Value(true)),
          // INCOME
          AccountsCompanion.insert(code: 401, name: 'Sales Revenue', categoryId: 41, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 402, name: 'Sales Returns and Allowances', categoryId: 41, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 403, name: 'Sales Discounts', categoryId: 41, isLocked: const Value(true)),
          // COST OF SALES
          AccountsCompanion.insert(code: 520, name: 'Cost of Goods Sold (COGS)', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 501, name: 'Raw Materials Used', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 502, name: 'Direct Labor', categoryId: 51, isLocked: const Value(true)),
          // EXPENSES
          AccountsCompanion.insert(code: 612, name: 'Rent Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 611, name: 'Utilities Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 610, name: 'Supplies Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 601, name: 'Salaries and Wages Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 655, name: 'Marketing Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 621, name: 'Bank Fees', categoryId: 53, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 701, name: 'Interest Expense', categoryId: 53, isLocked: const Value(true)),
        ]);
      });

      // Default User Detail
      await db.into(db.users).insert(UsersCompanion.insert(
        username: 'Juan Dela Cruz',
        email: 'juan@example.com',
        businessType: BusinessType.soleProprietorship,
        business: const Value('JDC General Merchandising'),
        businessAddress: const Value('123 Rizal Avenue, Puerto Princesa City, Palawan'),
        contactNumber: const Value('+63 912 345 6789'),
      ));
    },
    onUpgrade: (Migrator m, int from, int to) async {},
    beforeOpen: (details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
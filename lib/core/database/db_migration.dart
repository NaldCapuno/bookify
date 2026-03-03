import 'package:bookkeeping/core/database/tables/user_table.dart';
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
          AccountCategoriesCompanion.insert(id: const Value(1), name: 'Asset', normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(2), name: 'Liability', normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(3), name: 'Equity', normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(4), name: 'Revenue', normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(5), name: 'Expense', normalBalance: NormalBalance.debit),

          // --- SUBTYPES (Categories) ---
          // Assets (Parent -> 1)
          AccountCategoriesCompanion.insert(id: const Value(11), name: 'Current Asset', parent: const Value(1), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(12), name: 'Non-current Asset', parent: const Value(1), normalBalance: NormalBalance.debit),

          // Liabilities (Parent -> 2)
          AccountCategoriesCompanion.insert(id: const Value(21), name: 'Current Liability', parent: const Value(2), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(22), name: 'Non-current Liability', parent: const Value(2), normalBalance: NormalBalance.credit),

          // Equity (Parent -> 3)
          AccountCategoriesCompanion.insert(id: const Value(31), name: 'Owner\'s Equity', parent: const Value(3), normalBalance: NormalBalance.credit),

          // Revenue (Parent -> 4)
          AccountCategoriesCompanion.insert(id: const Value(41), name: 'Operating Revenue', parent: const Value(4), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(42), name: 'Other Income', parent: const Value(4), normalBalance: NormalBalance.credit),

          // Expenses (Parent -> 5)
          AccountCategoriesCompanion.insert(id: const Value(51), name: 'Costs of Sale', parent: const Value(5), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(52), name: 'Operating Expense', parent: const Value(5), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(53), name: 'Other Expense', parent: const Value(5), normalBalance: NormalBalance.debit),


          // --- SUB-CATEGORIES ---
          // Parent -> 11 (Current Assets)
          AccountCategoriesCompanion.insert(id: const Value(111), name: 'Cash', parent: const Value(11), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(112), name: 'Bank', parent: const Value(11), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(113), name: 'Supplies', parent: const Value(11), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(114), name: 'Receivable', parent: const Value(11), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(115), name: 'Prepaid', parent: const Value(11), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(116), name: 'Raw Material', parent: const Value(11), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(117), name: 'Inventory For Sale', parent: const Value(11), normalBalance: NormalBalance.debit),

          
          // Parent -> 12 (Current Assets)
          AccountCategoriesCompanion.insert(id: const Value(121), name: 'Property', parent: const Value(12), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(122), name: 'Equipment', parent: const Value(12), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(123), name: 'Furniture and Fixtures', parent: const Value(12), normalBalance: NormalBalance.debit),

          // Parent -> 21 (Current Liability)
          AccountCategoriesCompanion.insert(id: const Value(211), name: 'Payable', parent: const Value(21), normalBalance: NormalBalance.credit),

          // Parent -> 22 (Non-current Liability)
          AccountCategoriesCompanion.insert(id: const Value(221), name: 'Loan', parent: const Value(22), normalBalance: NormalBalance.credit),

          // Parent -> 31 (Owner's Equity)
          AccountCategoriesCompanion.insert(id: const Value(311), name: 'Capital', parent: const Value(31), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(312), name: 'Drawing', parent: const Value(31), normalBalance: NormalBalance.credit),

          // Parent -> 41 (Operating Revenue)
          AccountCategoriesCompanion.insert(id: const Value(411), name: 'Sales', parent: const Value(41), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(412), name: 'Discount', parent: const Value(41), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(413), name: 'Returns and Allowances', parent: const Value(41), normalBalance: NormalBalance.debit),

          // Parent -> 42 (Other Income)
          AccountCategoriesCompanion.insert(id: const Value(421), name: 'Interest Income', parent: const Value(42), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(422), name: 'Gain From Asset', parent: const Value(42), normalBalance: NormalBalance.credit),

          // Parent -> 51 (Costs of Sale)
          AccountCategoriesCompanion.insert(id: const Value(511), name: 'Labor', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(512), name: 'Factory Overhead', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(513), name: 'Raw Materials Used', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(514), name: 'Cost of Goods', parent: const Value(51), normalBalance: NormalBalance.debit),

          // Parent -> 52 (Operating Expense)
          AccountCategoriesCompanion.insert(id: const Value(521), name: 'Selling Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(522), name: 'Administrative Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(523), name: 'General Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(524), name: 'Maintenance Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(525), name: 'Professional Fees', parent: const Value(52), normalBalance: NormalBalance.debit),

          // Parent -> 53 (Other Expense)
          AccountCategoriesCompanion.insert(id: const Value(531), name: 'Financial Expense', parent: const Value(53), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(532), name: 'Tax Expense', parent: const Value(53), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(533), name: 'Losses on Asset', parent: const Value(53), normalBalance: NormalBalance.debit),
        ]);
      });

      // 3. Populate the accounts table
      await db.batch((batch) {
   batch.insertAll(db.accounts, [
          // ==============================
          // ASSETS (100-199)
          // ==============================
          // Current Assets
          AccountsCompanion.insert(code: 111, name: 'Cash on Hand', description: const Value(''), categoryId: 111, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 112, name: 'Cash in Bank', description: const Value(''), categoryId: 112),
          AccountsCompanion.insert(code: 1131, name: 'Factory Supplies Inventory', description: const Value(''), categoryId: 113),
          AccountsCompanion.insert(code: 1132, name: 'Office Supplies Inventory', description: const Value(''), categoryId: 113),
          AccountsCompanion.insert(code: 114, name: 'Accounts Receivable', description: const Value(''), categoryId: 114),
          AccountsCompanion.insert(code: 115, name: 'Prepaid Rent', description: const Value(''), categoryId: 115),
          AccountsCompanion.insert(code: 116, name: 'Raw Materials Inventory', description: const Value(''), categoryId: 116),
          AccountsCompanion.insert(code: 117, name: 'Finished Goods Inventory', description: const Value(''), categoryId: 117),

          // Non-Current Assets
          AccountsCompanion.insert(code: 1211, name: 'Land', description: const Value(''), categoryId: 121),
          AccountsCompanion.insert(code: 1212, name: 'Building', description: const Value(''), categoryId: 121),
          AccountsCompanion.insert(code: 1221, name: 'Factory Equipment', description: const Value(''), categoryId: 122),
          AccountsCompanion.insert(code: 1222, name: 'Machinery', description: const Value(''), categoryId: 122),
          AccountsCompanion.insert(code: 1223, name: 'Office Equipment', description: const Value(''), categoryId: 122),
          AccountsCompanion.insert(code: 1231, name: 'Furniture and Fixtures', description: const Value(''), categoryId: 123),

          // ==============================
          // LIABILITIES (200-299)
          // ==============================
          AccountsCompanion.insert(code: 211, name: 'Accounts Payable', description: const Value(''), categoryId: 211),
          AccountsCompanion.insert(code: 222, name: 'Bank Loan', description: const Value(''), categoryId: 222),

          // ==============================
          // EQUITY (300-399)
          // ==============================
          AccountsCompanion.insert(code: 311, name: 'Owner\'s Capital', description: const Value(''), categoryId: 311),
          AccountsCompanion.insert(code: 312, name: 'Owner\'s Drawings', description: const Value(''), categoryId: 312),

          // ==============================
          // REVENUE (400-499)
          // ==============================
          AccountsCompanion.insert(code: 411, name: 'Sales Revenue', description: const Value(''), categoryId: 411),
          AccountsCompanion.insert(code: 412, name: 'Sales Discounts', description: const Value(''), categoryId: 412),
          AccountsCompanion.insert(code: 413, name: 'Sales Returns and Allowances', description: const Value(''), categoryId: 413),
          AccountsCompanion.insert(code: 421, name: 'Interest Income', description: const Value(''), categoryId: 421),
          AccountsCompanion.insert(code: 4221, name: 'Income from Selling Furniture', description: const Value(''), categoryId: 422),
          AccountsCompanion.insert(code: 4222, name: 'Income from Selling Equipment', description: const Value(''), categoryId: 422),

          // ==============================
          // EXPENSES (500-899)
          // ==============================
          // Costs of Sale
          AccountsCompanion.insert(code: 511, name: 'Direct Labor', description: const Value(''), categoryId: 511),
          AccountsCompanion.insert(code: 513, name: 'Raw Materials Used', description: const Value(''), categoryId: 513),
          AccountsCompanion.insert(code: 514, name: 'Cost of Goods Sold', description: const Value(''), categoryId: 514),

          // Operating Expense (600 range)
          AccountsCompanion.insert(code: 611, name: 'Freight Out', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 612, name: 'Advertising Expense', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 613, name: 'Sales Commission Expense', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 614, name: 'Sales Salaries Expense', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 615, name: 'Marketing Expense', description: const Value(''), categoryId: 521),
          
          AccountsCompanion.insert(code: 621, name: 'Salaries and Wages Expense', description: const Value(''), categoryId: 522),

          AccountsCompanion.insert(code: 631, name: 'Transportation Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 632, name: 'Insurance Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 633, name: 'Office Supplies Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 634, name: 'Utilities Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 635, name: 'Rent Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 636, name: 'Miscellaneous Expense', description: const Value(''), categoryId: 523),

          AccountsCompanion.insert(code: 641, name: 'Repairs and Maintenance Expense ', description: const Value(''), categoryId: 524),
          AccountsCompanion.insert(code: 651, name: 'Professional Fees', description: const Value(''), categoryId: 525),

          // Other Expense (700-800 range)
          AccountsCompanion.insert(code: 711, name: 'Interest Expense', description: const Value(''), categoryId: 531),
          AccountsCompanion.insert(code: 811, name: 'Income Tax Expense', description: const Value(''), categoryId: 532),
          AccountsCompanion.insert(code: 721, name: 'Loss on Sale of Assets', description: const Value(''), categoryId: 533),
        ]);
      });
      // Default User Detail
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(username: 'Juan Dela Cruz', email: 'juan@example.com', businessType: BusinessType.soleProprietorship, business: const Value('JDC General Merchandising'), businessAddress: const Value('123 Rizal Avenue, Puerto Princesa City, Palawan'), contactNumber: const Value('+63 912 345 6789')),
        ]);
      });
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
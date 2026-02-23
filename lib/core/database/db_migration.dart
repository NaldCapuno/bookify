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
        ]);
      });




      // 3. Populate the accounts table
      await db.batch((batch) {
        batch.insertAll(db.accounts, [
          // ==============================
          // ASSETS
          // ==============================
          // Current Assets (11)
          AccountsCompanion.insert(code: 101, name: 'Cash on Hand', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 102, name: 'Cash in Bank - Checking', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 103, name: 'Cash in Bank - Savings', categoryId: 11),
          AccountsCompanion.insert(code: 104, name: 'Petty Cash Fund', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 110, name: 'Accounts Receivable - Trade', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 111, name: 'Allowance for Doubtful Accounts', categoryId: 11),
          AccountsCompanion.insert(code: 112, name: 'Notes Receivable', categoryId: 11),
          AccountsCompanion.insert(code: 113, name: 'Advances to Employees', categoryId: 11),
          AccountsCompanion.insert(code: 114, name: 'Advances to Suppliers', categoryId: 11),
          AccountsCompanion.insert(code: 120, name: 'Raw Materials Inventory', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 121, name: 'Work in Process Inventory', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 122, name: 'Finished Goods Inventory', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 123, name: 'Factory Supplies Inventory', categoryId: 11),
          AccountsCompanion.insert(code: 124, name: 'Office Supplies Inventory', categoryId: 11),
          AccountsCompanion.insert(code: 130, name: 'Prepaid Insurance', categoryId: 11),
          AccountsCompanion.insert(code: 131, name: 'Prepaid Rent', categoryId: 11),
          AccountsCompanion.insert(code: 132, name: 'Prepaid Taxes', categoryId: 11),
          AccountsCompanion.insert(code: 133, name: 'Input VAT', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 134, name: 'Creditable Withholding Tax', categoryId: 11, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 140, name: 'Short-term Investments', categoryId: 11),
          AccountsCompanion.insert(code: 169, name: 'Accounts Receivable - Kyle Engreso', categoryId: 11),
          
          // Non-Current Assets (12)
          AccountsCompanion.insert(code: 150, name: 'Land', categoryId: 12),
          AccountsCompanion.insert(code: 151, name: 'Building', categoryId: 12),
          AccountsCompanion.insert(code: 152, name: 'Accumulated Depreciation - Building', categoryId: 12),
          AccountsCompanion.insert(code: 153, name: 'Factory Equipment', categoryId: 12, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 154, name: 'Accumulated Depreciation - Factory Equipment', categoryId: 12, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 155, name: 'Machinery', categoryId: 12, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 156, name: 'Accumulated Depreciation - Machinery', categoryId: 12, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 157, name: 'Office Equipment', categoryId: 12),
          AccountsCompanion.insert(code: 158, name: 'Accumulated Depreciation - Office Equipment', categoryId: 12),
          AccountsCompanion.insert(code: 159, name: 'Furniture and Fixtures', categoryId: 12),
          AccountsCompanion.insert(code: 160, name: 'Accumulated Depreciation - Furniture and Fixtures', categoryId: 12),
          AccountsCompanion.insert(code: 161, name: 'Delivery Equipment', categoryId: 12),
          AccountsCompanion.insert(code: 162, name: 'Accumulated Depreciation - Delivery Equipment', categoryId: 12),
          AccountsCompanion.insert(code: 163, name: 'Tools and Dies', categoryId: 12),
          AccountsCompanion.insert(code: 164, name: 'Accumulated Depreciation - Tools and Dies', categoryId: 12),
          AccountsCompanion.insert(code: 165, name: 'Leasehold Improvements', categoryId: 12),
          AccountsCompanion.insert(code: 166, name: 'Accumulated Amortization - Leasehold Improvements', categoryId: 12),
          AccountsCompanion.insert(code: 170, name: 'Long-term Investments', categoryId: 12),
          AccountsCompanion.insert(code: 180, name: 'Goodwill', categoryId: 12),
          AccountsCompanion.insert(code: 181, name: 'Patents', categoryId: 12),
          AccountsCompanion.insert(code: 182, name: 'Trademarks', categoryId: 12),

          // ==============================
          // LIABILITIES
          // ==============================
          // Current Liabilities (21)
          AccountsCompanion.insert(code: 201, name: 'Accounts Payable - Trade', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 202, name: 'Notes Payable', categoryId: 21),
          AccountsCompanion.insert(code: 203, name: 'Accrued Salaries and Wages', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 204, name: 'Accrued Utilities', categoryId: 21),
          AccountsCompanion.insert(code: 205, name: 'Accrued Interest Payable', categoryId: 21),
          AccountsCompanion.insert(code: 210, name: 'SSS Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 211, name: 'PhilHealth Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 212, name: 'Pag-IBIG Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 213, name: 'Withholding Tax Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 214, name: 'Expanded Withholding Tax Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 215, name: 'Output VAT', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 216, name: 'Income Tax Payable', categoryId: 21, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 220, name: 'Advances from Customers', categoryId: 21),
          AccountsCompanion.insert(code: 221, name: 'Unearned Revenue', categoryId: 21),
          AccountsCompanion.insert(code: 230, name: 'Current Portion of Long-term Debt', categoryId: 21),
          AccountsCompanion.insert(code: 240, name: 'Dividends Payable', categoryId: 21),

          // Non-Current Liabilities (22)
          AccountsCompanion.insert(code: 250, name: 'Bank Loan Payable', categoryId: 22),
          AccountsCompanion.insert(code: 251, name: 'Mortgage Payable', categoryId: 22),
          AccountsCompanion.insert(code: 252, name: 'Bonds Payable', categoryId: 22),
          AccountsCompanion.insert(code: 253, name: 'Deferred Tax Liability', categoryId: 22),

          // ==============================
          // EQUITY
          // ==============================
          // Owner's Equity (31)
          AccountsCompanion.insert(code: 301, name: 'Capital Stock - Common', categoryId: 31, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 302, name: 'Capital Stock - Preferred', categoryId: 31),
          AccountsCompanion.insert(code: 303, name: 'Additional Paid-in Capital', categoryId: 31),
          AccountsCompanion.insert(code: 304, name: 'Subscribed Capital Stock', categoryId: 31),
          AccountsCompanion.insert(code: 305, name: 'Subscription Receivable', categoryId: 31),
          AccountsCompanion.insert(code: 310, name: 'Retained Earnings', categoryId: 31, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 311, name: 'Retained Earnings - Appropriated', categoryId: 31),
          AccountsCompanion.insert(code: 320, name: 'Treasury Stock', categoryId: 31),
          AccountsCompanion.insert(code: 330, name: 'Other Comprehensive Income', categoryId: 31),
          AccountsCompanion.insert(code: 340, name: 'Owner\'s Capital', categoryId: 31),
          AccountsCompanion.insert(code: 341, name: 'Owner\'s Drawings', categoryId: 31),

          // ==============================
          // REVENUE
          // ==============================
          // Operating Revenue (41)
          AccountsCompanion.insert(code: 401, name: 'Sales Revenue', categoryId: 41, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 402, name: 'Sales Returns and Allowances', categoryId: 41, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 403, name: 'Sales Discounts', categoryId: 41, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 410, name: 'Service Revenue', categoryId: 41),
          
          // Other Income (42)
          AccountsCompanion.insert(code: 420, name: 'Interest Income', categoryId: 42),
          AccountsCompanion.insert(code: 421, name: 'Dividend Income', categoryId: 42),
          AccountsCompanion.insert(code: 422, name: 'Rental Income', categoryId: 42),
          AccountsCompanion.insert(code: 423, name: 'Gain on Sale of Assets', categoryId: 42),
          AccountsCompanion.insert(code: 424, name: 'Foreign Exchange Gain', categoryId: 42),
          AccountsCompanion.insert(code: 425, name: 'Miscellaneous Income', categoryId: 42),

          // ==============================
          // EXPENSES
          // ==============================
          // Costs of Sale (51)
          AccountsCompanion.insert(code: 501, name: 'Raw Materials Used', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 502, name: 'Direct Labor', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 510, name: 'Factory Overhead - Indirect Materials', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 511, name: 'Factory Overhead - Indirect Labor', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 512, name: 'Factory Overhead - Utilities', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 513, name: 'Factory Overhead - Rent', categoryId: 51),
          AccountsCompanion.insert(code: 514, name: 'Factory Overhead - Depreciation', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 515, name: 'Factory Overhead - Insurance', categoryId: 51),
          AccountsCompanion.insert(code: 516, name: 'Factory Overhead - Repairs and Maintenance', categoryId: 51, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 517, name: 'Factory Overhead - Supplies', categoryId: 51),
          AccountsCompanion.insert(code: 518, name: 'Factory Overhead - Other', categoryId: 51),
          AccountsCompanion.insert(code: 520, name: 'Cost of Goods Sold', categoryId: 51, isLocked: const Value(true)),

          // Operating Expense (52)
          AccountsCompanion.insert(code: 601, name: 'Salaries and Wages Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 602, name: 'SSS Contribution Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 603, name: 'PhilHealth Contribution Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 604, name: 'Pag-IBIG Contribution Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 605, name: '13th Month Pay Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 606, name: 'Employee Benefits Expense', categoryId: 52),
          AccountsCompanion.insert(code: 610, name: 'Office Supplies Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 611, name: 'Utilities Expense - Office', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 612, name: 'Rent Expense - Office', categoryId: 52),
          AccountsCompanion.insert(code: 613, name: 'Insurance Expense', categoryId: 52),
          AccountsCompanion.insert(code: 614, name: 'Depreciation Expense - Office', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 615, name: 'Repairs and Maintenance Expense - Office', categoryId: 52),
          AccountsCompanion.insert(code: 616, name: 'Communication Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 617, name: 'Transportation Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 618, name: 'Professional Fees', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 619, name: 'Legal Fees', categoryId: 52),
          AccountsCompanion.insert(code: 620, name: 'Audit Fees', categoryId: 52),
          AccountsCompanion.insert(code: 621, name: 'Bank Charges', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 622, name: 'Taxes and Licenses', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 623, name: 'Representation Expense', categoryId: 52),
          AccountsCompanion.insert(code: 624, name: 'Training and Development Expense', categoryId: 52),
          AccountsCompanion.insert(code: 625, name: 'Security Services Expense', categoryId: 52),
          AccountsCompanion.insert(code: 626, name: 'Janitorial Services Expense', categoryId: 52),
          AccountsCompanion.insert(code: 627, name: 'Bad Debts Expense', categoryId: 52),
          AccountsCompanion.insert(code: 628, name: 'Miscellaneous Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 651, name: 'Advertising Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 652, name: 'Sales Commission Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 653, name: 'Delivery Expense', categoryId: 52, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 654, name: 'Sales Salaries Expense', categoryId: 52),
          AccountsCompanion.insert(code: 655, name: 'Marketing Expense', categoryId: 52),
          AccountsCompanion.insert(code: 656, name: 'Trade Show Expense', categoryId: 52),
          AccountsCompanion.insert(code: 657, name: 'Freight Out', categoryId: 52, isLocked: const Value(true)),

          // Other Expense (53)
          AccountsCompanion.insert(code: 701, name: 'Interest Expense', categoryId: 53, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 702, name: 'Loss on Sale of Assets', categoryId: 53),
          AccountsCompanion.insert(code: 703, name: 'Foreign Exchange Loss', categoryId: 53),
          AccountsCompanion.insert(code: 704, name: 'Penalties and Surcharges', categoryId: 53),
          AccountsCompanion.insert(code: 801, name: 'Income Tax Expense', categoryId: 53, isLocked: const Value(true)),
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
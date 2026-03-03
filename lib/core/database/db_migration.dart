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
          AccountCategoriesCompanion.insert(id: const Value(11), name: 'Current Asset', parent: const Value(1), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(12), name: 'Non-current Asset', parent: const Value(1), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(21), name: 'Current Liability', parent: const Value(2), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(22), name: 'Non-current Liability', parent: const Value(2), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(31), name: 'Owner\'s Equity', parent: const Value(3), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(41), name: 'Operating Revenue', parent: const Value(4), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(42), name: 'Other Income', parent: const Value(4), normalBalance: NormalBalance.credit),
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
          
          // Parent -> 12 (Non-Current Assets)
          AccountCategoriesCompanion.insert(id: const Value(121), name: 'Property', parent: const Value(12), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(122), name: 'Equipment', parent: const Value(12), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(123), name: 'Furniture and Fixtures', parent: const Value(12), normalBalance: NormalBalance.debit),

          // Parent -> 21 & 22 (Liabilities)
          AccountCategoriesCompanion.insert(id: const Value(211), name: 'Payable', parent: const Value(21), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(221), name: 'Loan', parent: const Value(22), normalBalance: NormalBalance.credit),

          // Parent -> 31 (Owner's Equity)
          AccountCategoriesCompanion.insert(id: const Value(311), name: 'Capital', parent: const Value(31), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(312), name: 'Drawing', parent: const Value(31), normalBalance: NormalBalance.credit),

          // Parent -> 41 & 42 (Revenue)
          AccountCategoriesCompanion.insert(id: const Value(411), name: 'Sales', parent: const Value(41), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(412), name: 'Discount', parent: const Value(41), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(413), name: 'Returns and Allowances', parent: const Value(41), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(421), name: 'Interest Income', parent: const Value(42), normalBalance: NormalBalance.credit),
          AccountCategoriesCompanion.insert(id: const Value(422), name: 'Gain From Asset', parent: const Value(42), normalBalance: NormalBalance.credit),

          // Parent -> 51, 52 & 53 (Expenses)
          AccountCategoriesCompanion.insert(id: const Value(511), name: 'Labor', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(512), name: 'Factory Overhead', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(513), name: 'Raw Materials Used', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(514), name: 'Cost of Goods', parent: const Value(51), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(521), name: 'Selling Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(522), name: 'Administrative Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(523), name: 'General Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(524), name: 'Maintenance Expense', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(525), name: 'Professional Fees', parent: const Value(52), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(531), name: 'Financial Expense', parent: const Value(53), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(532), name: 'Tax Expense', parent: const Value(53), normalBalance: NormalBalance.debit),
          AccountCategoriesCompanion.insert(id: const Value(533), name: 'Losses on Asset', parent: const Value(53), normalBalance: NormalBalance.debit),
        ]);
      });

      // 3. Populate the accounts table
      // 3. Populate the accounts table
      await db.batch((batch) {
        batch.insertAll(db.accounts, [
          // ==============================
          // ASSETS (1000-1999)
          // ==============================
          // Current Assets
          AccountsCompanion.insert(code: 1110, name: 'Cash on Hand', description: const Value(''), categoryId: 111, isLocked: const Value(true)),
          AccountsCompanion.insert(code: 1111, name: 'Petty Cash Fund', description: const Value('Small bills for daily minor expenses'), categoryId: 111),
          AccountsCompanion.insert(code: 1112, name: 'GCash Wallet', description: const Value('Business GCash account for receiving payments'), categoryId: 111),
          AccountsCompanion.insert(code: 1113, name: 'Maya Wallet', description: const Value('Business Maya account'), categoryId: 111),
          
          AccountsCompanion.insert(code: 1120, name: 'Cash in Bank', description: const Value(''), categoryId: 112),
          AccountsCompanion.insert(code: 1121, name: 'BDO Checking Account', description: const Value('Issuance of post-dated checks'), categoryId: 112),
          AccountsCompanion.insert(code: 1122, name: 'BPI Savings Account', description: const Value('Main depository account'), categoryId: 112),
          
          AccountsCompanion.insert(code: 1131, name: 'Factory Supplies Inventory', description: const Value(''), categoryId: 113),
          AccountsCompanion.insert(code: 1132, name: 'Office Supplies Inventory', description: const Value(''), categoryId: 113),
          
          AccountsCompanion.insert(code: 1140, name: 'Accounts Receivable', description: const Value(''), categoryId: 114),
          AccountsCompanion.insert(code: 1141, name: 'Advances to Employees', description: const Value('Employee vales or salary advances'), categoryId: 114),
          
          AccountsCompanion.insert(code: 1150, name: 'Prepaid Rent', description: const Value(''), categoryId: 115),
          AccountsCompanion.insert(code: 1151, name: 'Input VAT', description: const Value('VAT from purchases to be offset'), categoryId: 115),
          AccountsCompanion.insert(code: 1152, name: 'Creditable Withholding Tax (CWT)', description: const Value('Form 2307 from clients'), categoryId: 115),
          
          AccountsCompanion.insert(code: 1160, name: 'Raw Materials Inventory', description: const Value(''), categoryId: 116),
          AccountsCompanion.insert(code: 1161, name: 'Meat & Poultry Inventory', description: const Value('Raw meat for curing/processing'), categoryId: 116),
          AccountsCompanion.insert(code: 1162, name: 'Sugar & Dairy Inventory', description: const Value('Condensed milk, sugar, and base ingredients'), categoryId: 116),
          AccountsCompanion.insert(code: 1163, name: 'Packaging Materials Inventory', description: const Value('Jars, seals, labels, and vacuum bags'), categoryId: 116),
          
          AccountsCompanion.insert(code: 1170, name: 'Finished Goods Inventory', description: const Value(''), categoryId: 117),
          AccountsCompanion.insert(code: 1171, name: 'Consigned Goods Inventory', description: const Value('Products placed in local pasalubong centers or stores'), categoryId: 117),

          // Non-Current Assets
          AccountsCompanion.insert(code: 1211, name: 'Land', description: const Value(''), categoryId: 121),
          AccountsCompanion.insert(code: 1212, name: 'Building', description: const Value(''), categoryId: 121),
          AccountsCompanion.insert(code: 1221, name: 'Factory Equipment', description: const Value(''), categoryId: 122),
          AccountsCompanion.insert(code: 1222, name: 'Machinery', description: const Value(''), categoryId: 122),
          AccountsCompanion.insert(code: 1223, name: 'Office Equipment', description: const Value(''), categoryId: 122),
          AccountsCompanion.insert(code: 1231, name: 'Furniture and Fixtures', description: const Value(''), categoryId: 123),

          // ==============================
          // LIABILITIES (2000-2999)
          // ==============================
          AccountsCompanion.insert(code: 2110, name: 'Accounts Payable', description: const Value(''), categoryId: 211),
          AccountsCompanion.insert(code: 2111, name: 'SSS Premium Payable', description: const Value('Employee and Employer SSS contributions'), categoryId: 211),
          AccountsCompanion.insert(code: 2112, name: 'PhilHealth Premium Payable', description: const Value('Health contributions'), categoryId: 211),
          AccountsCompanion.insert(code: 2113, name: 'Pag-IBIG Premium Payable', description: const Value('HDMF contributions'), categoryId: 211),
          AccountsCompanion.insert(code: 2114, name: 'Withholding Tax Expanded (EWT)', description: const Value('Taxes withheld from rent or professionals (Form 0619-E)'), categoryId: 211),
          AccountsCompanion.insert(code: 2115, name: 'Output VAT', description: const Value('VAT collected from sales'), categoryId: 211),
          
          AccountsCompanion.insert(code: 2210, name: 'Bank Loan', description: const Value(''), categoryId: 221),
          AccountsCompanion.insert(code: 2211, name: 'Vehicle Auto Loan', description: const Value('Long term loan for delivery trike/van'), categoryId: 221),

          // ==============================
          // EQUITY (3000-3999)
          // ==============================
          AccountsCompanion.insert(code: 3110, name: 'Owner\'s Capital', description: const Value(''), categoryId: 311),
          AccountsCompanion.insert(code: 3120, name: 'Owner\'s Drawings', description: const Value(''), categoryId: 312),

          // ==============================
          // REVENUE (4000-4999)
          // ==============================
          AccountsCompanion.insert(code: 4110, name: 'Sales Revenue', description: const Value(''), categoryId: 411),
          AccountsCompanion.insert(code: 4111, name: 'Wholesale Revenue', description: const Value('Bulk orders to resellers'), categoryId: 411),
          AccountsCompanion.insert(code: 4112, name: 'Retail Revenue', description: const Value('Direct to consumer sales'), categoryId: 411),
          AccountsCompanion.insert(code: 4113, name: 'Delivery Fees Collected', description: const Value('Shipping fees charged to customers'), categoryId: 411),
          
          AccountsCompanion.insert(code: 4120, name: 'Sales Discounts', description: const Value(''), categoryId: 412),
          AccountsCompanion.insert(code: 4121, name: 'Senior Citizen / PWD Discount', description: const Value('Mandated 20% discount'), categoryId: 412),
          AccountsCompanion.insert(code: 4122, name: 'Trade Discounts', description: const Value('Volume discounts for resellers'), categoryId: 412),
          
          AccountsCompanion.insert(code: 4130, name: 'Sales Returns and Allowances', description: const Value(''), categoryId: 413),
          
          AccountsCompanion.insert(code: 4210, name: 'Interest Income', description: const Value(''), categoryId: 421),
          AccountsCompanion.insert(code: 4221, name: 'Income from Selling Furniture', description: const Value(''), categoryId: 422),
          AccountsCompanion.insert(code: 4222, name: 'Income from Selling Equipment', description: const Value(''), categoryId: 422),

          // ==============================
          // EXPENSES (5000-5999)
          // ==============================
          // Costs of Sale
          AccountsCompanion.insert(code: 5110, name: 'Direct Labor', description: const Value(''), categoryId: 511),
          AccountsCompanion.insert(code: 5111, name: 'Piece-rate / Pakyaw Labor', description: const Value('Labor paid per batch or per jar/pack produced'), categoryId: 511),
          
          AccountsCompanion.insert(code: 5130, name: 'Raw Materials Used', description: const Value(''), categoryId: 513),
          AccountsCompanion.insert(code: 5140, name: 'Cost of Goods Sold', description: const Value(''), categoryId: 514),

          // Operating Expense (52xx range)
          AccountsCompanion.insert(code: 5211, name: 'Freight Out', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 5212, name: 'Advertising Expense', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 5213, name: 'Sales Commission Expense', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 5214, name: 'Sales Salaries Expense', description: const Value(''), categoryId: 521),
          AccountsCompanion.insert(code: 5215, name: 'Marketing Expense', description: const Value(''), categoryId: 521),
          
          AccountsCompanion.insert(code: 5220, name: 'Salaries and Wages Expense', description: const Value(''), categoryId: 522),
          AccountsCompanion.insert(code: 5221, name: '13th Month Pay Expense', description: const Value('Mandatory year-end bonus'), categoryId: 522),
          AccountsCompanion.insert(code: 5222, name: 'Employer Contributions', description: const Value('Employer share of SSS, PhilHealth, Pag-IBIG'), categoryId: 522),
          AccountsCompanion.insert(code: 5223, name: 'Representation Expense', description: const Value('Meals and meetings with clients'), categoryId: 522),

          AccountsCompanion.insert(code: 5231, name: 'Transportation Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 5232, name: 'Insurance Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 5233, name: 'Office Supplies Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 5234, name: 'Utilities Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 5235, name: 'Rent Expense', description: const Value(''), categoryId: 523),
          AccountsCompanion.insert(code: 5236, name: 'Miscellaneous Expense', description: const Value(''), categoryId: 523),

          AccountsCompanion.insert(code: 5240, name: 'Repairs and Maintenance Expense', description: const Value(''), categoryId: 524),
          AccountsCompanion.insert(code: 5241, name: 'Vehicle Maintenance', description: const Value('Repairs and oil changes for delivery trike/van'), categoryId: 524),
          
          AccountsCompanion.insert(code: 5250, name: 'Professional Fees', description: const Value(''), categoryId: 525),
          AccountsCompanion.insert(code: 5251, name: 'Retainer Fee - Bookkeeper', description: const Value('Monthly accounting services'), categoryId: 525),
          AccountsCompanion.insert(code: 5252, name: 'Notarial Fees', description: const Value('Notary for contracts and sworn statements'), categoryId: 525),

          // Other Expense (53xx range)
          AccountsCompanion.insert(code: 5310, name: 'Interest Expense', description: const Value(''), categoryId: 531),
          AccountsCompanion.insert(code: 5311, name: 'Bank & Remittance Charges', description: const Value('Transfer fees, Palawan Pawnshop fees, checkbook reorders'), categoryId: 531),
          
          AccountsCompanion.insert(code: 5320, name: 'Income Tax Expense', description: const Value(''), categoryId: 532),
          AccountsCompanion.insert(code: 5321, name: 'Taxes and Licenses', description: const Value('Mayors Permit, Barangay Clearance, BIR Annual Reg'), categoryId: 532),
          
          AccountsCompanion.insert(code: 5330, name: 'Loss on Sale of Assets', description: const Value(''), categoryId: 533),
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
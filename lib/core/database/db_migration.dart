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

      // 3. Populate the accounts table
      await db.batch((batch) {
        batch.insertAll(db.accounts, [
          // ==============================
          // ASSETS
          // ==============================
          // Current Assets (11)
          AccountsCompanion.insert(
            code: 101,
            name: 'Cash on Hand',
            description: const Value(
              'Currencies, coins, and checks currently in the physical possession of the business.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 102,
            name: 'Cash in Bank - Checking',
            description: const Value(
              'Funds held in a business checking account for daily operational payments.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 103,
            name: 'Cash in Bank - Savings',
            description: const Value(
              'Interest-bearing funds held in a bank savings account for future use.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 104,
            name: 'Petty Cash Fund',
            description: const Value(
              'A small amount of discretionary funds kept on-site for minor business expenses.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 110,
            name: 'Accounts Receivable',
            description: const Value(
              'Amounts owed to the business by customers for goods sold or services rendered on credit.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 111,
            name: 'Allowance for Doubtful Accounts',
            description: const Value(
              'A contra-asset account representing the estimated amount of receivables that may not be collected.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 112,
            name: 'Notes Receivable',
            description: const Value(
              'Claims for which formal instruments of credit (promissory notes) are issued as evidence of debt.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 113,
            name: 'Advances to Employees',
            description: const Value(
              'Short-term loans or salary advances provided to employees.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 114,
            name: 'Advances to Suppliers',
            description: const Value(
              'Down payments or deposits made to vendors before goods or services are received.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 120,
            name: 'Raw Materials Inventory',
            description: const Value(
              'Cost of direct materials that have not yet entered the production process.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 121,
            name: 'Work in Process Inventory',
            description: const Value(
              'Goods currently in the production cycle that are partially completed.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 122,
            name: 'Finished Goods Inventory',
            description: const Value(
              'Completed products ready for sale to customers.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 123,
            name: 'Factory Supplies Inventory',
            description: const Value(
              'Indirect materials used in the production process, such as lubricants or cleaning supplies.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 124,
            name: 'Office Supplies Inventory',
            description: const Value(
              'Consumable items used in office administration, like paper, ink, and stationery.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 130,
            name: 'Prepaid Insurance',
            description: const Value(
              'Insurance premiums paid in advance, to be expensed over the coverage period.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 131,
            name: 'Prepaid Rent',
            description: const Value(
              'Rent paid in advance for future use of facilities.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 132,
            name: 'Prepaid Taxes',
            description: const Value(
              'Taxes paid in advance or overpayments to be applied to future tax liabilities.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 133,
            name: 'Input VAT',
            description: const Value(
              'Value-added tax paid on purchases that can be offset against Output VAT.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 134,
            name: 'Creditable Withholding Tax',
            description: const Value(
              'Taxes withheld by customers from payments to the business, creditable against income tax.',
            ),
            categoryId: 11,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 140,
            name: 'Short-term Investments',
            description: const Value(
              'Liquid assets like stocks or bonds intended to be sold within one year.',
            ),
            categoryId: 11,
          ),
          AccountsCompanion.insert(
            code: 169,
            name: 'Accounts Receivable',
            description: const Value(
              'Specific receivable account for trade transactions and outstanding customer balances.',
            ),
            categoryId: 11,
          ),

          // Non-Current Assets (12)
          AccountsCompanion.insert(
            code: 150,
            name: 'Land',
            description: const Value(
              'Real estate property owned for business operations; not subject to depreciation.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 151,
            name: 'Building',
            description: const Value(
              'Structures owned and used for office, factory, or warehouse operations.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 152,
            name: 'Accumulated Depreciation - Building',
            description: const Value(
              'Total depreciation expensed against the building since acquisition.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 153,
            name: 'Factory Equipment',
            description: const Value(
              'Heavy machinery and tools used directly in the manufacturing process.',
            ),
            categoryId: 12,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 154,
            name: 'Accumulated Depreciation - Factory Equipment',
            description: const Value(
              'Total depreciation expensed against factory equipment.',
            ),
            categoryId: 12,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 155,
            name: 'Machinery',
            description: const Value(
              'Mechanical devices used in business operations.',
            ),
            categoryId: 12,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 156,
            name: 'Accumulated Depreciation - Machinery',
            description: const Value(
              'Total depreciation expensed against machinery.',
            ),
            categoryId: 12,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 157,
            name: 'Office Equipment',
            description: const Value(
              'Tangible assets like computers, printers, and copiers used in the office.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 158,
            name: 'Accumulated Depreciation - Office Equipment',
            description: const Value(
              'Total depreciation expensed against office equipment.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 159,
            name: 'Furniture and Fixtures',
            description: const Value(
              'Desks, chairs, shelving, and other movable furniture used by the business.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 160,
            name: 'Accumulated Depreciation - Furniture and Fixtures',
            description: const Value(
              'Total depreciation expensed against furniture and fixtures.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 161,
            name: 'Delivery Equipment',
            description: const Value(
              'Vehicles such as trucks or vans used for transporting goods.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 162,
            name: 'Accumulated Depreciation - Delivery Equipment',
            description: const Value(
              'Total depreciation expensed against delivery vehicles.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 163,
            name: 'Tools and Dies',
            description: const Value(
              'Specialized tools and molds used in manufacturing operations.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 164,
            name: 'Accumulated Depreciation - Tools and Dies',
            description: const Value(
              'Total depreciation expensed against tools and dies.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 165,
            name: 'Leasehold Improvements',
            description: const Value(
              'Enhancements made to a leased property by the business.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 166,
            name: 'Accumulated Amortization - Leasehold Improvements',
            description: const Value(
              'Total amortization expensed against leasehold improvements.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 170,
            name: 'Long-term Investments',
            description: const Value(
              'Investments in securities or property held for more than one year.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 180,
            name: 'Goodwill',
            description: const Value(
              'Intangible asset representing the value of the business reputation and customer base.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 181,
            name: 'Patents',
            description: const Value(
              'Exclusive rights granted for an invention.',
            ),
            categoryId: 12,
          ),
          AccountsCompanion.insert(
            code: 182,
            name: 'Trademarks',
            description: const Value(
              'Recognized symbols, logos, or names protected by law.',
            ),
            categoryId: 12,
          ),

          // ==============================
          // LIABILITIES
          // ==============================
          // Current Liabilities (21)
          AccountsCompanion.insert(
            code: 201,
            name: 'Accounts Payable - Trade',
            description: const Value(
              'Amounts owed to suppliers for goods or services purchased on credit.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 202,
            name: 'Notes Payable',
            description: const Value(
              'Short-term formal promissory notes issued to creditors.',
            ),
            categoryId: 21,
          ),
          AccountsCompanion.insert(
            code: 203,
            name: 'Accrued Salaries and Wages',
            description: const Value(
              'Employee earnings that have been incurred but not yet paid.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 204,
            name: 'Accrued Utilities',
            description: const Value(
              'Utility costs (electricity, water) consumed but not yet billed or paid.',
            ),
            categoryId: 21,
          ),
          AccountsCompanion.insert(
            code: 205,
            name: 'Accrued Interest Payable',
            description: const Value(
              'Interest expense incurred on loans that has not yet been paid.',
            ),
            categoryId: 21,
          ),
          AccountsCompanion.insert(
            code: 210,
            name: 'SSS Payable',
            description: const Value(
              'Social Security System contributions withheld and owed to the government.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 211,
            name: 'PhilHealth Payable',
            description: const Value(
              'Health insurance contributions withheld and owed to PhilHealth.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 212,
            name: 'Pag-IBIG Payable',
            description: const Value(
              'Housing fund contributions withheld and owed to Pag-IBIG.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 213,
            name: 'Withholding Tax Payable',
            description: const Value(
              'Income taxes withheld from employee wages owed to the BIR.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 214,
            name: 'Expanded Withholding Tax Payable',
            description: const Value(
              'Taxes withheld from payments to suppliers or contractors owed to the BIR.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 215,
            name: 'Output VAT',
            description: const Value(
              'Value-added tax collected from customers on sales of goods or services.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 216,
            name: 'Income Tax Payable',
            description: const Value(
              'Estimated income taxes owed by the business for the current period.',
            ),
            categoryId: 21,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 220,
            name: 'Advances from Customers',
            description: const Value(
              'Payments received from customers before the delivery of goods or services.',
            ),
            categoryId: 21,
          ),
          AccountsCompanion.insert(
            code: 221,
            name: 'Unearned Revenue',
            description: const Value(
              'Revenue received for services not yet performed or goods not yet delivered.',
            ),
            categoryId: 21,
          ),
          AccountsCompanion.insert(
            code: 230,
            name: 'Current Portion of Long-term Debt',
            description: const Value(
              'The part of a long-term loan that is due for payment within one year.',
            ),
            categoryId: 21,
          ),
          AccountsCompanion.insert(
            code: 240,
            name: 'Dividends Payable',
            description: const Value(
              'Earnings declared by the board of directors to be paid out to shareholders.',
            ),
            categoryId: 21,
          ),

          // Non-Current Liabilities (22)
          AccountsCompanion.insert(
            code: 250,
            name: 'Bank Loan Payable',
            description: const Value(
              'Principal amount of long-term loans from banking institutions.',
            ),
            categoryId: 22,
          ),
          AccountsCompanion.insert(
            code: 251,
            name: 'Mortgage Payable',
            description: const Value(
              'Long-term debt secured by real estate property.',
            ),
            categoryId: 22,
          ),
          AccountsCompanion.insert(
            code: 252,
            name: 'Bonds Payable',
            description: const Value(
              'Long-term debt securities issued by the business to investors.',
            ),
            categoryId: 22,
          ),
          AccountsCompanion.insert(
            code: 253,
            name: 'Deferred Tax Liability',
            description: const Value(
              'Taxes to be paid in future periods due to temporary differences in accounting.',
            ),
            categoryId: 22,
          ),

          // ==============================
          // EQUITY
          // ==============================
          // Owner's Equity (31)
          AccountsCompanion.insert(
            code: 301,
            name: 'Capital Stock - Common',
            description: const Value(
              'The par value of common shares issued to shareholders.',
            ),
            categoryId: 31,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 302,
            name: 'Capital Stock - Preferred',
            description: const Value(
              'The par value of preferred shares issued, usually with dividend priority.',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 303,
            name: 'Additional Paid-in Capital',
            description: const Value(
              'Amounts received from shareholders in excess of the par value of shares.',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 304,
            name: 'Subscribed Capital Stock',
            description: const Value(
              'Shares that investors have committed to purchase but not yet fully paid.',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 305,
            name: 'Subscription Receivable',
            description: const Value(
              'A contra-equity account representing amounts owed by shareholders for subscribed shares.',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 310,
            name: 'Retained Earnings',
            description: const Value(
              'Cumulative net income of the business that has not been distributed as dividends.',
            ),
            categoryId: 31,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 311,
            name: 'Retained Earnings - Appropriated',
            description: const Value(
              'Retained earnings set aside for a specific purpose (e.g., expansion).',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 320,
            name: 'Treasury Stock',
            description: const Value(
              'Shares of the business’s own stock that it has repurchased from the market.',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 330,
            name: 'Other Comprehensive Income',
            description: const Value(
              'Gains and losses excluded from net income (e.g., unrealized gains on investments).',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 340,
            name: 'Owner\'s Capital',
            description: const Value(
              'Equity account representing the owner\'s net investment in the business.',
            ),
            categoryId: 31,
          ),
          AccountsCompanion.insert(
            code: 341,
            name: 'Owner\'s Drawings',
            description: const Value(
              'Withdrawals of cash or other assets from the business by the owner for personal use.',
            ),
            categoryId: 31,
          ),

          // ==============================
          // REVENUE
          // ==============================
          // Operating Revenue (41)
          AccountsCompanion.insert(
            code: 401,
            name: 'Sales Revenue',
            description: const Value(
              'Gross income from the sale of goods in the ordinary course of business.',
            ),
            categoryId: 41,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 402,
            name: 'Sales Returns and Allowances',
            description: const Value(
              'A contra-revenue account for goods returned by customers or price reductions granted.',
            ),
            categoryId: 41,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 403,
            name: 'Sales Discounts',
            description: const Value(
              'Reductions in the selling price offered to customers for prompt payment.',
            ),
            categoryId: 41,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 410,
            name: 'Service Revenue',
            description: const Value(
              'Income earned from providing professional services to clients.',
            ),
            categoryId: 41,
          ),

          // Other Income (42)
          AccountsCompanion.insert(
            code: 420,
            name: 'Interest Income',
            description: const Value(
              'Earnings from interest on bank accounts, loans, or investments.',
            ),
            categoryId: 42,
          ),
          AccountsCompanion.insert(
            code: 421,
            name: 'Dividend Income',
            description: const Value(
              'Earnings from dividends on stocks owned by the business.',
            ),
            categoryId: 42,
          ),
          AccountsCompanion.insert(
            code: 422,
            name: 'Rental Income',
            description: const Value(
              'Income earned from leasing or renting out business-owned property.',
            ),
            categoryId: 42,
          ),
          AccountsCompanion.insert(
            code: 423,
            name: 'Gain on Sale of Assets',
            description: const Value(
              'Profit made when a long-term asset is sold for more than its book value.',
            ),
            categoryId: 42,
          ),
          AccountsCompanion.insert(
            code: 424,
            name: 'Foreign Exchange Gain',
            description: const Value(
              'Profit resulting from favorable changes in currency exchange rates.',
            ),
            categoryId: 42,
          ),
          AccountsCompanion.insert(
            code: 425,
            name: 'Miscellaneous Income',
            description: const Value(
              'Small or irregular income sources not categorized elsewhere.',
            ),
            categoryId: 42,
          ),

          // ==============================
          // EXPENSES
          // ==============================
          // Costs of Sale (51)
          AccountsCompanion.insert(
            code: 501,
            name: 'Raw Materials Used',
            description: const Value(
              'Cost of materials that have been consumed in the production process.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 502,
            name: 'Direct Labor',
            description: const Value(
              'Wages of employees directly involved in converting raw materials into finished goods.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 510,
            name: 'Factory Overhead - Indirect Materials',
            description: const Value(
              'Materials used in production that cannot be easily traced to specific units.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 511,
            name: 'Factory Overhead - Indirect Labor',
            description: const Value(
              'Wages of factory personnel not directly involved in production (e.g., supervisors).',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 512,
            name: 'Factory Overhead - Utilities',
            description: const Value(
              'Utility costs specifically incurred for factory operations.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 513,
            name: 'Factory Overhead - Rent',
            description: const Value('Rental cost for factory facilities.'),
            categoryId: 51,
          ),
          AccountsCompanion.insert(
            code: 514,
            name: 'Factory Overhead - Depreciation',
            description: const Value(
              'Depreciation of factory building and equipment.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 515,
            name: 'Factory Overhead - Insurance',
            description: const Value(
              'Insurance premiums specifically for factory assets and operations.',
            ),
            categoryId: 51,
          ),
          AccountsCompanion.insert(
            code: 516,
            name: 'Factory Overhead - Repairs and Maintenance',
            description: const Value(
              'Maintenance costs for keeping factory assets in working condition.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 517,
            name: 'Factory Overhead - Supplies',
            description: const Value(
              'Consumable supplies used within the factory environment.',
            ),
            categoryId: 51,
          ),
          AccountsCompanion.insert(
            code: 518,
            name: 'Factory Overhead - Other',
            description: const Value(
              'Miscellaneous manufacturing overhead costs.',
            ),
            categoryId: 51,
          ),
          AccountsCompanion.insert(
            code: 520,
            name: 'Cost of Goods Sold',
            description: const Value(
              'Total cost of products sold to customers during the period.',
            ),
            categoryId: 51,
            isLocked: const Value(true),
          ),

          // Operating Expense (52)
          AccountsCompanion.insert(
            code: 601,
            name: 'Salaries and Wages Expense',
            description: const Value(
              'Remuneration for office and administrative staff.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 602,
            name: 'SSS Contribution Expense',
            description: const Value(
              'The employer\'s share of Social Security System contributions.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 603,
            name: 'PhilHealth Contribution Expense',
            description: const Value(
              'The employer\'s share of PhilHealth contributions.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 604,
            name: 'Pag-IBIG Contribution Expense',
            description: const Value(
              'The employer\'s share of Pag-IBIG fund contributions.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 605,
            name: '13th Month Pay Expense',
            description: const Value(
              'Mandatory year-end bonus for employees as per Philippine law.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 606,
            name: 'Employee Benefits Expense',
            description: const Value(
              'Costs related to employee perks, health plans, and other non-wage benefits.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 610,
            name: 'Office Supplies Expense',
            description: const Value(
              'Cost of office supplies consumed during the period.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 611,
            name: 'Utilities Expense - Office',
            description: const Value(
              'Electricity, water, and waste costs for office administrative areas.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 612,
            name: 'Rent Expense - Office',
            description: const Value('Rental cost for office space.'),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 613,
            name: 'Insurance Expense',
            description: const Value(
              'Insurance premiums for office-related coverage.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 614,
            name: 'Depreciation Expense - Office',
            description: const Value(
              'Depreciation of office-related fixed assets.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 615,
            name: 'Repairs and Maintenance Expense - Office',
            description: const Value(
              'Costs to maintain office equipment and facilities.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 616,
            name: 'Communication Expense',
            description: const Value(
              'Costs for telephone, internet, and postage services.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 617,
            name: 'Transportation Expense',
            description: const Value(
              'Travel costs and vehicle fuel for administrative staff.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 618,
            name: 'Professional Fees',
            description: const Value(
              'Fees paid to consultants, accountants, and other professionals.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 619,
            name: 'Legal Fees',
            description: const Value(
              'Costs for legal advice and representation.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 620,
            name: 'Audit Fees',
            description: const Value(
              'Cost for external audit services of the business records.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 621,
            name: 'Bank Charges',
            description: const Value(
              'Fees charged by banks for account maintenance and transactions.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 622,
            name: 'Taxes and Licenses',
            description: const Value(
              'Business permits, licenses, and other government fees.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 623,
            name: 'Representation Expense',
            description: const Value(
              'Costs for entertaining clients and business associates.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 624,
            name: 'Training and Development Expense',
            description: const Value(
              'Costs for employee seminars, workshops, and educational courses.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 625,
            name: 'Security Services Expense',
            description: const Value(
              'Fees for private security or alarm monitoring services.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 626,
            name: 'Janitorial Services Expense',
            description: const Value(
              'Fees for cleaning and maintenance services.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 627,
            name: 'Bad Debts Expense',
            description: const Value(
              'The amount of Accounts Receivable written off as uncollectible.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 628,
            name: 'Miscellaneous Expense',
            description: const Value(
              'Incidental administrative expenses not elsewhere classified.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 651,
            name: 'Advertising Expense',
            description: const Value(
              'Costs for promoting products or services through various media.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 652,
            name: 'Sales Commission Expense',
            description: const Value(
              'Incentives paid to sales staff based on performance.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 653,
            name: 'Delivery Expense',
            description: const Value(
              'Costs incurred in delivering goods to customers.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 654,
            name: 'Sales Salaries Expense',
            description: const Value(
              'Salaries specifically for sales department personnel.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 655,
            name: 'Marketing Expense',
            description: const Value(
              'Costs for market research, branding, and promotional strategy.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 656,
            name: 'Trade Show Expense',
            description: const Value(
              'Costs associated with participating in exhibitions or trade shows.',
            ),
            categoryId: 52,
          ),
          AccountsCompanion.insert(
            code: 657,
            name: 'Freight Out',
            description: const Value(
              'Transportation cost of selling and delivering goods to customers.',
            ),
            categoryId: 52,
            isLocked: const Value(true),
          ),

          // Other Expense (53)
          AccountsCompanion.insert(
            code: 701,
            name: 'Interest Expense',
            description: const Value(
              'The cost of borrowing money on loans and other debts.',
            ),
            categoryId: 53,
            isLocked: const Value(true),
          ),
          AccountsCompanion.insert(
            code: 702,
            name: 'Loss on Sale of Assets',
            description: const Value(
              'The deficit incurred when an asset is sold for less than its book value.',
            ),
            categoryId: 53,
          ),
          AccountsCompanion.insert(
            code: 703,
            name: 'Foreign Exchange Loss',
            description: const Value(
              'Loss resulting from unfavorable changes in currency exchange rates.',
            ),
            categoryId: 53,
          ),
          AccountsCompanion.insert(
            code: 704,
            name: 'Penalties and Surcharges',
            description: const Value(
              'Fees incurred due to late payments or non-compliance with regulations.',
            ),
            categoryId: 53,
          ),
          AccountsCompanion.insert(
            code: 801,
            name: 'Income Tax Expense',
            description: const Value(
              'The total income tax incurred for the current reporting period.',
            ),
            categoryId: 53,
            isLocked: const Value(true),
          ),
        ]);
      });
      // Default User Detail
      await db.batch((batch) {
        batch.insertAll(db.users, [
          UsersCompanion.insert(
            username: 'Juan Dela Cruz',
            email: 'juan@example.com',
            businessType: BusinessType.soleProprietorship,
            business: const Value('JDC General Merchandising'),
            businessAddress: const Value(
              '123 Rizal Avenue, Puerto Princesa City, Palawan',
            ),
            contactNumber: const Value('+63 912 345 6789'),
          ),
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

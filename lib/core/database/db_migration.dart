import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // --- 1. Populate Account Categories ---
      await db.batch((batch) {
        batch.insertAll(db.accountCategories, [
          AccountCategoriesCompanion.insert(id: const Value(1), name: 'Asset'),
          AccountCategoriesCompanion.insert(id: const Value(2), name: 'Liability'),
          AccountCategoriesCompanion.insert(id: const Value(3), name: 'Equity'),
          AccountCategoriesCompanion.insert(id: const Value(4), name: 'Revenue'),
          AccountCategoriesCompanion.insert(id: const Value(5), name: 'Expense'),
          AccountCategoriesCompanion.insert(id: const Value(11), name: 'Current Asset', parent: const Value(1)),
          AccountCategoriesCompanion.insert(id: const Value(12), name: 'Non-current Asset', parent: const Value(1)),
          AccountCategoriesCompanion.insert(id: const Value(21), name: 'Current Liability', parent: const Value(2)),
          AccountCategoriesCompanion.insert(id: const Value(22), name: 'Non-current Liability', parent: const Value(2)),
          AccountCategoriesCompanion.insert(id: const Value(31), name: 'Owner\'s Equity', parent: const Value(3)),
          AccountCategoriesCompanion.insert(id: const Value(41), name: 'Operating Revenue', parent: const Value(4)),
          AccountCategoriesCompanion.insert(id: const Value(51), name: 'Costs of Sale', parent: const Value(5)),
          AccountCategoriesCompanion.insert(id: const Value(52), name: 'Operating Expense', parent: const Value(5)),
          AccountCategoriesCompanion.insert(id: const Value(53), name: 'Other Expense', parent: const Value(5)),
        ]);
      });

      // --- 2. Populate Accounts ---
      await db.batch((batch) {
        batch.insertAll(db.accounts, [
          // ASSETS
          AccountsCompanion.insert(code: 101, name: 'Cash on Hand', description: const Value('Physical cash, coins, and bills kept in the store or office.'), categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 102, name: 'Cash in Bank', description: const Value('Money stored safely in your business bank accounts.'), categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 110, name: 'Accounts Receivable', description: const Value('Money that customers owe you for goods or services they already received.'), categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 120, name: 'Inventory - Raw Materials', description: const Value('Unprocessed materials you bought to create your final products.'), categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 121, name: 'Inventory - Finished Goods', description: const Value('Completed products that are ready to be sold to customers.'), categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 130, name: 'Supplies', description: const Value('Everyday items like pens, paper, and tape used to run the business.'), categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 150, name: 'Equipment', description: const Value('Machines, computers, and tools used long-term for the business.'), categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 160, name: 'Furniture and Fixtures', description: const Value('Desks, chairs, shelves, and display cases used in your store or office.'), categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 170, name: 'Land', description: const Value('Property or lots owned by the business.'), categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 171, name: 'Building', description: const Value('Physical structures, offices, or warehouses owned by the business.'), categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 172, name: 'Vehicle', description: const Value('Cars, trucks, or motorcycles used for business deliveries and operations.'), categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 180, name: 'Accumulated Depreciation', description: const Value('The total value your long-term assets (like equipment) have lost over time.'), categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          
          // LIABILITIES
          AccountsCompanion.insert(code: 201, name: 'Accounts Payable', description: const Value('Money you owe to suppliers or vendors for things you bought on credit.'), categoryId: 21, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 230, name: 'Long-Term Loans', description: const Value('Money borrowed from banks or lenders that takes longer than a year to pay back.'), categoryId: 22, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          
          // CAPITAL
          AccountsCompanion.insert(code: 310, name: 'Retained Earnings', description: const Value('Past profits that you kept in the business instead of taking out.'), categoryId: 31, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 340, name: 'Owner\'s Capital', description: const Value('The personal money or assets you invested into the business.'), categoryId: 31, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 341, name: 'Owner\'s Drawings', description: const Value('Money you withdrew from the business bank account for personal use.'), categoryId: 31, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // INCOME
          AccountsCompanion.insert(code: 401, name: 'Sales Revenue', description: const Value('Income earned directly from selling your products or services.'), categoryId: 41, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 402, name: 'Sales Returns and Allowances', description: const Value('Money refunded to customers for returning items or receiving damaged goods.'), categoryId: 41, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 403, name: 'Sales Discounts', description: const Value('Discounts given to customers, often to encourage them to pay their bills early.'), categoryId: 41, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // COST OF SALES
          AccountsCompanion.insert(code: 501, name: 'Raw Materials Used', description: const Value('The exact cost of the raw materials used up to create the goods you sold.'), categoryId: 51, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 502, name: 'Direct Labor', description: const Value('The wages paid to workers who directly make your products or provide your services.'), categoryId: 51, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 520, name: 'Cost of Goods Sold (COGS)', description: const Value('The total direct cost of producing the items you sold.'), categoryId: 51, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // EXPENSES
          AccountsCompanion.insert(code: 601, name: 'Salaries and Wages Expense', description: const Value('Regular paychecks and wages given to your employees.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 610, name: 'Supplies Expense', description: const Value('The value of everyday office or cleaning supplies that got used up.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 611, name: 'Utilities Expense', description: const Value('Monthly bills for electricity, water, internet, and phone.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 612, name: 'Rent Expense', description: const Value('Money paid to use an office, store, or equipment you do not own.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 613, name: 'Transportation Expense', description: const Value('Costs for gas, fares, or delivery fees for business travel.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 620, name: 'Marketing Expense', description: const Value('Money spent on ads, flyers, and promotions to get more customers.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 625, name: 'Depreciation Expense', description: const Value('The portion of a long-term asset\'s value that was "used up" this year.'), categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 630, name: 'Tax Expense', description: const Value('Business taxes paid to the government.'), categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 635, name: 'Bank Fees', description: const Value('Charges from your bank for maintaining accounts or processing payments.'), categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 640, name: 'Miscellaneous Expense', description: const Value('Small, unexpected business costs that do not fit into other categories.'), categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 645, name: 'Interest Expense', description: const Value('Extra money paid to the bank on top of the original loan amount.'), categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
        ]);
      });

      // --- 3. Default User Detail ---
      await db.into(db.users).insert(
            UsersCompanion.insert(
              username: 'Juan Dela Cruz',
              email: 'juan@example.com',
              businessType: BusinessType.soleProprietorship,
              business: const Value('JDC General Merchandising'),
              businessAddress: const Value('123 Rizal Avenue, Puerto Princesa City, Palawan'),
              contactNumber: const Value('+63 912 345 6789'),
            ),
          );

      // --- 4. DATA SEEDING TOGGLE ---
      // SET THIS TO FALSE IF YOU WANT TO SKIP JOURNAL SEEDING
      const bool seedJournalEntries = false; 

      if (seedJournalEntries) {
        await _seedAllJournalData(db);
      }
    },
    onUpgrade: (Migrator m, int from, int to) async {},
    beforeOpen: (details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// A separate helper to keep the onCreate method clean.
Future<void> _seedAllJournalData(AppDatabase db) async {
  // Fetch accounts for ID lookup
  final allAccounts = await db.select(db.accounts).get();
  final accountIdLookup = {
    for (var account in allAccounts) account.code: account.id,
  };

  final entriesToSeed = [
    // --- JANUARY ---
    {
      'date': DateTime(2026, 1, 1),
      'desc': 'Invest 5,000,000 into the business',
      'lines': [
        {'code': 102, 'dr': 5000000.0, 'cr': 0.0},
        {'code': 340, 'dr': 0.0, 'cr': 5000000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 3),
      'desc': 'Purchased Vehicle for 800,000',
      'lines': [
        {'code': 172, 'dr': 800000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 800000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 3),
      'desc': 'Purchased equipment for 300,000',
      'lines': [
        {'code': 150, 'dr': 300000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 300000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 5),
      'desc': 'Purchase materials worth 200,000',
      'lines': [
        {'code': 120, 'dr': 200000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 200000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 8),
      'desc': 'Withdraw cash worth 60,000',
      'lines': [
        {'code': 101, 'dr': 60000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 60000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 10),
      'desc': 'Process 60,000 worth raw materials into goods',
      'lines': [
        {'code': 121, 'dr': 60000.0, 'cr': 0.0},
        {'code': 120, 'dr': 0.0, 'cr': 60000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 10),
      'desc': 'Labor cost of 15,000 for the processed goods',
      'lines': [
        {'code': 121, 'dr': 15000.0, 'cr': 0.0},
        {'code': 502, 'dr': 0.0, 'cr': 15000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 10),
      'desc': 'Paid labor cost',
      'lines': [
        {'code': 502, 'dr': 15000.0, 'cr': 0.0},
        {'code': 101, 'dr': 0.0, 'cr': 15000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 15),
      'desc': 'Sales revenue from selling goods at 150,000',
      'lines': [
        {'code': 102, 'dr': 150000.0, 'cr': 0.0},
        {'code': 401, 'dr': 0.0, 'cr': 150000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 15),
      'desc': 'Record cost of goods of recent sales at 75,000',
      'lines': [
        {'code': 520, 'dr': 75000.0, 'cr': 0.0},
        {'code': 121, 'dr': 0.0, 'cr': 75000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 25),
      'desc': 'Paid rent',
      'lines': [
        {'code': 612, 'dr': 25000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 25000.0},
      ],
    },
    {
      'date': DateTime(2026, 1, 30),
      'desc': 'Paid staff salaries',
      'lines': [
        {'code': 601, 'dr': 40000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 40000.0},
      ],
    },
    // --- FEBRUARY ---
    {
      'date': DateTime(2026, 2, 5),
      'desc': 'Purchase materials on credit worth 250,000',
      'lines': [
        {'code': 120, 'dr': 250000.0, 'cr': 0.0},
        {'code': 201, 'dr': 0.0, 'cr': 250000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 10),
      'desc': 'Process 120,000 worth raw materials into goods',
      'lines': [
        {'code': 121, 'dr': 120000.0, 'cr': 0.0},
        {'code': 120, 'dr': 0.0, 'cr': 120000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 10),
      'desc': 'Labor cost of 30,000 for the processed goods',
      'lines': [
        {'code': 121, 'dr': 30000.0, 'cr': 0.0},
        {'code': 502, 'dr': 0.0, 'cr': 30000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 10),
      'desc': 'Paid labor cost',
      'lines': [
        {'code': 502, 'dr': 30000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 30000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 15),
      'desc': 'Sales revenue of 300,000--received 100,000 in bank while 197,000 is on credit with discount of 3,000',
      'lines': [
        {'code': 102, 'dr': 100000.0, 'cr': 0.0},
        {'code': 110, 'dr': 197000.0, 'cr': 0.0},
        {'code': 403, 'dr': 3000.0, 'cr': 0.0},
        {'code': 401, 'dr': 0.0, 'cr': 300000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 15),
      'desc': 'Record cost of goods of recent sales at 150,000',
      'lines': [
        {'code': 520, 'dr': 150000.0, 'cr': 0.0},
        {'code': 121, 'dr': 0.0, 'cr': 150000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 20),
      'desc': 'Paid utilities in cash at 8,500',
      'lines': [
        {'code': 611, 'dr': 8500.0, 'cr': 0.0},
        {'code': 101, 'dr': 0.0, 'cr': 8500.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 25),
      'desc': 'Withdrew Cash of 20,000 for labor and supplies',
      'lines': [
        {'code': 101, 'dr': 20000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 20000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 26),
      'desc': 'Withdrew cash for personal use',
      'lines': [
        {'code': 341, 'dr': 10000.0, 'cr': 0.0},
        {'code': 101, 'dr': 0.0, 'cr': 10000.0},
      ],
    },
    {
      'date': DateTime(2026, 2, 28),
      'desc': 'Paid staff salaries',
      'lines': [
        {'code': 601, 'dr': 40000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 40000.0},
      ],
    },
    // --- MARCH ---
    {
      'date': DateTime(2026, 3, 5),
      'desc': 'Process 90,000 worth raw materials into goods',
      'lines': [
        {'code': 121, 'dr': 90000.0, 'cr': 0.0},
        {'code': 120, 'dr': 0.0, 'cr': 90000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 5),
      'desc': 'Labor cost of 25,000 for the processed goods',
      'lines': [
        {'code': 121, 'dr': 25000.0, 'cr': 0.0},
        {'code': 502, 'dr': 0.0, 'cr': 25000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 5),
      'desc': 'Paid labor cost',
      'lines': [
        {'code': 502, 'dr': 25000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 25000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 10),
      'desc': 'Sales revenue of 250,000',
      'lines': [
        {'code': 102, 'dr': 250000.0, 'cr': 0.0},
        {'code': 401, 'dr': 0.0, 'cr': 250000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 10),
      'desc': 'Record cost of goods of recent sales at 115,000',
      'lines': [
        {'code': 520, 'dr': 115000.0, 'cr': 0.0},
        {'code': 121, 'dr': 0.0, 'cr': 115000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 15),
      'desc': 'Settled payable from Feb 5',
      'lines': [
        {'code': 201, 'dr': 150000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 150000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 20),
      'desc': 'Cash expense for transpo',
      'lines': [
        {'code': 613, 'dr': 4000.0, 'cr': 0.0},
        {'code': 101, 'dr': 0.0, 'cr': 4000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 25),
      'desc': 'Deducted 800 fee from bank',
      'lines': [
        {'code': 635, 'dr': 800.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 800.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 28),
      'desc': 'Received cash from the past sales on credit',
      'lines': [
        {'code': 102, 'dr': 197000.0, 'cr': 0.0},
        {'code': 110, 'dr': 0.0, 'cr': 197000.0},
      ],
    },
    {
      'date': DateTime(2026, 3, 30),
      'desc': 'Paid staff salaries',
      'lines': [
        {'code': 601, 'dr': 45000.0, 'cr': 0.0},
        {'code': 102, 'dr': 0.0, 'cr': 45000.0},
      ],
    },
  ];

  for (int i = 0; i < entriesToSeed.length; i++) {
    final entry = entriesToSeed[i];
    final companionLines = (entry['lines'] as List<Map<String, dynamic>>).map((lineData) {
      final dbAccountId = accountIdLookup[lineData['code']];
      return TransactionsCompanion(
        accountId: Value(dbAccountId!),
        debit: Value(lineData['dr'] as double),
        credit: Value(lineData['cr'] as double),
      );
    }).toList();

    await _executeJournalEntry(
      db,
      date: entry['date'] as DateTime,
      description: entry['desc'] as String,
      referenceNo: 'JRN-${(i + 1).toString().padLeft(3, '0')}',
      lines: companionLines,
    );
  }
}

Future<void> _executeJournalEntry(
  AppDatabase db, {
  required DateTime date,
  required String description,
  String? referenceNo,
  required List<TransactionsCompanion> lines,
}) async {
  await db.transaction(() async {
    final journalId = await db.into(db.journals).insert(
          JournalsCompanion.insert(
            date: date,
            description: description,
            referenceNo: Value(referenceNo),
          ),
        );

    for (var line in lines) {
      await db.into(db.transactions).insert(line.copyWith(journalId: Value(journalId)));
    }
  });
}
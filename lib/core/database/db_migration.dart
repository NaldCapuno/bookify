import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/database/tables/user_table.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';

MigrationStrategy buildMigrationStrategy(AppDatabase db) {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();

      // 1. Populate the accountCategories table (Structure only)
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

      // 2. Populate the accounts table (Normal Balance binded here)
      await db.batch((batch) {
        batch.insertAll(db.accounts, [
          // ASSETS
          AccountsCompanion.insert(code: 101, name: 'Cash on Hand', categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 102, name: 'Cash in Bank', categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 110, name: 'Accounts Receivable', categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 120, name: 'Inventory - Raw Materials', categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 121, name: 'Inventory - Finished Goods', categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 130, name: 'Supplies', categoryId: 11, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 150, name: 'Equipment', categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 160, name: 'Furniture and Fixtures', categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 170, name: 'Land', categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 171, name: 'Building', categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 172, name: 'Vehicle', categoryId: 12, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // LIABILITIES
          AccountsCompanion.insert(code: 201, name: 'Accounts Payable', categoryId: 21, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 230, name: 'Long-Term Loans', categoryId: 22, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          
          // CAPITAL
          AccountsCompanion.insert(code: 310, name: 'Retained Earnings', categoryId: 31, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 340, name: 'Owner\'s Capital', categoryId: 31, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 341, name: 'Owner\'s Drawings', categoryId: 31, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // INCOME
          AccountsCompanion.insert(code: 401, name: 'Sales Revenue', categoryId: 41, isLocked: const Value(true), normalBalance: NormalBalance.credit),
          AccountsCompanion.insert(code: 402, name: 'Sales Returns and Allowances', categoryId: 41, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 403, name: 'Sales Discounts', categoryId: 41, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // COST OF SALES
          AccountsCompanion.insert(code: 501, name: 'Raw Materials Used', categoryId: 51, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 502, name: 'Direct Labor', categoryId: 51, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 520, name: 'Cost of Goods Sold (COGS)', categoryId: 51, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          
          // EXPENSES
          AccountsCompanion.insert(code: 601, name: 'Salaries and Wages Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 610, name: 'Supplies Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 611, name: 'Utilities Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 612, name: 'Rent Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 613, name: 'Transportation Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 620, name: 'Marketing Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 630, name: 'Tax Expense', categoryId: 52, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 635, name: 'Bank Fees', categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 640, name: 'Miscellaneous Expense', categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
          AccountsCompanion.insert(code: 645, name: 'Interest Expense', categoryId: 53, isLocked: const Value(true), normalBalance: NormalBalance.debit),
        ]);
      });

      // Default User Detail
      await db
          .into(db.users)
          .insert(
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
          );

      // 3. Fetch all accounts and create a rapid Lookup Map (Code -> Database ID)
      final allAccounts = await db.select(db.accounts).get();
      final accountIdLookup = {
        for (var account in allAccounts) account.code: account.id,
      };

      // 4. The structured list of all 32 migrated journal entries
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

        // Compound Entry Example
        {
          'date': DateTime(2026, 2, 15),
          'desc':
              'Sales revenue of 300,000--received 100,000 in bank while 197,000 is on credit with discount of 3,000',
          'lines': [
            {'code': 102, 'dr': 100000.0, 'cr': 0.0}, // Cash in Bank
            {'code': 110, 'dr': 197000.0, 'cr': 0.0}, // Accounts Receivable
            {'code': 403, 'dr': 3000.0, 'cr': 0.0}, // Sales Discount
            {'code': 401, 'dr': 0.0, 'cr': 300000.0}, // Sales Revenue
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

      // 5. Loop through the list and map them to Drift Database Inserts
      for (int i = 0; i < entriesToSeed.length; i++) {
        final entry = entriesToSeed[i];

        final companionLines = (entry['lines'] as List<Map<String, dynamic>>)
            .map((lineData) {
              final dbAccountId = accountIdLookup[lineData['code']];

              return TransactionsCompanion(
                accountId: Value(dbAccountId!),
                debit: Value(lineData['dr'] as double),
                credit: Value(lineData['cr'] as double),
              );
            })
            .toList();

        // Call the helper function we created earlier
        await _seedInitialJournalEntry(
          db,
          date: entry['date'] as DateTime,
          description: entry['desc'] as String,
          referenceNo: 'JRN-${(i + 1).toString().padLeft(3, '0')}',
          lines: companionLines,
        );
      }
    },
    onUpgrade: (Migrator m, int from, int to) async {},
    beforeOpen: (details) async {
      await db.customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

Future<void> _seedInitialJournalEntry(
  AppDatabase db, {
  required DateTime date,
  required String description,
  String? referenceNo,
  required List<TransactionsCompanion> lines,
}) async {
  // Wrapping this in a transaction ensures that if one part fails,
  // the whole entry is rolled back, preventing corrupted data.
  await db.transaction(() async {
    // 1. Insert the main Journal and get its auto-incremented ID
    final journalId = await db
        .into(db.journals)
        .insert(
          JournalsCompanion.insert(
            date: date,
            description: description,
            referenceNo: Value(referenceNo),
          ),
        );

    // 2. Insert all the transaction lines and bind them to the Journal ID
    for (var line in lines) {
      await db
          .into(db.transactions)
          .insert(line.copyWith(journalId: Value(journalId)));
    }
  });
}

import 'package:bookkeeping/core/database/app_database.dart';
import 'package:drift/drift.dart' as drift;

/// Helper to post pre-defined journal templates for Quick Actions.
///
/// This keeps all the accounting wiring (account codes, Dr/Cr mapping)
/// in one place so individual screens stay focused on UI.
class QuickActionJournalService {
  QuickActionJournalService._();

  static final QuickActionJournalService instance =
      QuickActionJournalService._();

  Future<void> postTemplateEntry({
    required DateTime date,
    required String description,
    String? referenceNo,
    required List<TemplateLine> lines,
  }) async {
    if (lines.isEmpty) return;

    // Resolve account IDs from codes once per code.
    final Map<int, int> codeToId = {};
    for (final line in lines) {
      if (!codeToId.containsKey(line.accountCode)) {
        final accountId =
            await _getAccountIdByCode(line.accountCode);
        codeToId[line.accountCode] = accountId;
      }
    }

    final txLines = lines.map((line) {
      final accountId = codeToId[line.accountCode]!;
      return TransactionsCompanion(
        accountId: drift.Value(accountId),
        debit: drift.Value(line.isDebit ? line.amount : 0),
        credit: drift.Value(line.isDebit ? 0 : line.amount),
      );
    }).toList();

    await appDb.journalEntryDao.insertFullJournalEntry(
      date: date,
      description: description,
      referenceNo: referenceNo,
      lines: txLines,
    );
  }

  Future<int> _getAccountIdByCode(int code) async {
    final query = appDb.select(appDb.accounts)
      ..where((a) => a.code.equals(code));
    final account = await query.getSingle();
    return account.id;
  }
}

/// Lightweight template line: account code from the chart of accounts,
/// a debit/credit flag, and a positive amount.
///
/// The service looks up the concrete `accounts.id` using the code.
class TemplateLine {
  final int accountCode;
  final bool isDebit;
  final double amount;

  const TemplateLine({
    required this.accountCode,
    required this.isDebit,
    required this.amount,
  }) : assert(amount >= 0);
}

// Commonly used account codes (see db_migration.dart seed data).
class QuickActionAccounts {
  static const int cashOnHand = 101;
  static const int cashInBank = 102;
  static const int accountsReceivable = 110;
  static const int inventoryRawMaterials = 120;
  static const int inventoryFinishedGoods = 121;
  static const int supplies = 130;
  static const int equipment = 150;
  static const int furnitureAndFixtures = 160;
  static const int land = 170;
  static const int building = 171;
  static const int vehicle = 172;

  static const int accountsPayable = 201;
  static const int longTermLoans = 230;

  static const int ownersCapital = 340;
  static const int ownersDrawings = 341;

  static const int salesRevenue = 401;
  static const int salesReturnsAndAllowances = 402;
  static const int salesDiscounts = 403;

  static const int costOfGoodsSold = 520;
  static const int rawMaterialsUsed = 501;
  static const int directLabor = 502;

  static const int rentExpense = 612;
  static const int utilitiesExpense = 611;
  static const int transportationExpense = 613;
  static const int suppliesExpense = 610;
  static const int salariesAndWagesExpense = 601;
  static const int salesTaxExpense = 510; // legacy, not used in quick actions
  // NOTE: Expense codes below must stay in sync with db_migration.dart seeds.
  static const int marketingExpense = 620;      // Marketing Expense
  static const int taxExpense = 630;            // Tax Expense
  static const int bankFees = 635;              // Bank Fees
  static const int miscellaneousExpense = 640;  // Miscellaneous Expense
  static const int interestExpense = 645;       // Interest Expense
}


import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';
import 'widgets/ledger_entry_card.dart';

/// Ensures Cash account has mock transactions so the dropdown can be tested. Runs once if Cash has none.
Future<void> _ensureMockDataForCash() async {
  final cashAccount = await (appDb.select(appDb.accounts)
        ..where((t) => t.name.equals('Cash')))
      .getSingleOrNull() ??
      await (appDb.select(appDb.accounts)
            ..where((t) => t.name.equals('Cash on Hand')))
          .getSingleOrNull();
  if (cashAccount == null) return;

  final existing = await (appDb.select(appDb.transactions)
        ..where((t) => t.accountId.equals(cashAccount.id)))
      .get();
  if (existing.isNotEmpty) return;

  final mockData = [
    (DateTime(2026, 2, 1), 'Initial capital investment', 80000.0, 0.0),
    (DateTime(2026, 2, 3), 'Purchase equipment', 0.0, 40000.0),
    (DateTime(2026, 2, 7), 'Sales - cash', 15000.0, 0.0),
  ];
  for (final e in mockData) {
    final journalId = await appDb.into(appDb.journals).insert(
          JournalsCompanion.insert(date: e.$1, description: e.$2),
        );
    await appDb.into(appDb.transactions).insert(
      TransactionsCompanion.insert(
        journalId: journalId,
        accountId: cashAccount.id,
        debit: Value(e.$3),
        credit: Value(e.$4),
      ),
    );
  }
}

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureMockDataForCash());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: StreamBuilder<List<LedgerEntry>>(
        stream: appDb.ledgerDao.watchLedgerEntries(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];
          final Set<int> displayedIds = {};

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSection(
                context,
                entries,
                1,
                'Assets',
                const Color(0xFF10893E),
                displayedIds,
              ),
              _buildSection(
                context,
                entries,
                2,
                'Liabilities',
                const Color(0xFFD31111),
                displayedIds,
              ),
              _buildSection(
                context,
                entries,
                3,
                "Owner's Equity",
                const Color(0xFF1565C0),
                displayedIds,
              ),
              _buildSection(
                context,
                entries,
                4,
                'Revenue',
                const Color(0xFF00897B),
                displayedIds,
              ),
              _buildSection(
                context,
                entries,
                5,
                'Expenses',
                const Color(0xFFE65100),
                displayedIds,
              ),
              _buildMiscSection(context, entries, displayedIds),
            ],
          );
        },
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    List<LedgerEntry> allEntries,
    int rootId,
    String title,
    Color color,
    Set<int> displayedIds,
  ) {
    final sectionItems = allEntries
        .where(
          (e) =>
              (e.category.parent == rootId || e.category.id == rootId) &&
              !displayedIds.contains(e.account.id),
        )
        .toList();

    for (final item in sectionItems) {
      displayedIds.add(item.account.id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(title, sectionItems.length, color),
        if (sectionItems.isEmpty)
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 20),
            child: Text(
              "No accounts in this category",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...sectionItems.map(
            (item) => LedgerEntryCard(
              accountDbId: item.account.id,
              icon: _getIconForAccount(item.account.code),
              code: item.account.code.toString(),
              name: item.account.name,
              transactions: item.transactionCount,
              balance: item.balance.toStringAsFixed(2),
            ),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildMiscSection(
    BuildContext context,
    List<LedgerEntry> allEntries,
    Set<int> displayedIds,
  ) {
    final miscItems = allEntries
        .where((e) => !displayedIds.contains(e.account.id))
        .toList();
    if (miscItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Uncategorized", miscItems.length, Colors.blueGrey),
        ...miscItems.map(
          (item) => LedgerEntryCard(
            accountDbId: item.account.id,
            icon: Icons.help_outline,
            code: item.account.code.toString(),
            name: item.account.name,
            transactions: item.transactionCount,
            balance: item.balance.toStringAsFixed(2),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHeader(String title, int count, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$count accounts',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  IconData _getIconForAccount(int code) {
    if (code < 200) return Icons.account_balance_wallet_outlined;
    if (code < 300) return Icons.credit_card_outlined;
    if (code < 400) return Icons.person_outline;
    return Icons.receipt_long_outlined;
  }
}

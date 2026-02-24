import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';
import 'widgets/ledger_entry_card.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
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

  /// Only include accounts that have at least one transaction or non-zero balance.
  bool _hasActivity(LedgerEntry e) =>
      e.transactionCount > 0 || e.balance != 0.0;

  Widget _buildSection(
    BuildContext context,
    List<LedgerEntry> allEntries,
    int rootId,
    String title,
    Color color,
    Set<int> displayedIds,
  ) {
    final allInCategory = allEntries
        .where(
          (e) =>
              (e.category.parent == rootId || e.category.id == rootId) &&
              !displayedIds.contains(e.account.id),
        )
        .toList();
    final sectionItems =
        allInCategory.where((e) => _hasActivity(e)).toList();

    for (final item in allInCategory) {
      displayedIds.add(item.account.id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(title, allInCategory.length, color),
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
    final allMisc = allEntries
        .where((e) => !displayedIds.contains(e.account.id))
        .toList();
    final miscItems = allMisc.where((e) => _hasActivity(e)).toList();
    if (allMisc.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader("Uncategorized", allMisc.length, Colors.blueGrey),
        if (miscItems.isEmpty)
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

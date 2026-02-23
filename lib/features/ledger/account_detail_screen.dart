import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';

String _formatCurrency(double amount) {
  final formatted = amount.toStringAsFixed(2).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return '₱$formatted';
}

class AccountDetailScreen extends StatelessWidget {
  final LedgerEntry entry;
  final String sectionTitle;
  final int sectionCount;
  final Color headerColor;

  const AccountDetailScreen({
    super.key,
    required this.entry,
    required this.sectionTitle,
    required this.sectionCount,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: Text(entry.account.name),
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildDetailHeader(),
          _buildAccountSummaryCard(),
          Expanded(
            child: StreamBuilder<List<TypedResult>>(
              stream: appDb.ledgerDao.watchTransactionsForAccount(entry.account.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final rows = snapshot.data ?? [];
                if (rows.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rows.length,
                  itemBuilder: (context, index) {
                    final row = rows[index];
                    final journal = row.readTable(appDb.journals);
                    final tx = row.readTable(appDb.transactions);
                    return _buildTransactionCard(journal: journal, tx: tx);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: headerColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sectionTitle,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            entry.account.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${entry.transactionCount} transactions',
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                'Balance: ${_formatCurrency(entry.balance)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSummaryCard() {
    final themeColor = _getThemeColor(entry.account.code.toString());
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIconForAccount(entry.account.code), color: themeColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        entry.account.code.toString(),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.transactionCount} transactions',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.account.name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Balance',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              Text(
                _formatCurrency(entry.balance),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard({required Journal journal, required Transaction tx}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  DateFormat('MMM d, yyyy').format(journal.date),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              journal.description,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAmountBox('Debit', tx.debit, const Color(0xFF10893E)),
                const SizedBox(width: 12),
                _buildAmountBox('Credit', tx.credit, const Color(0xFF1565C0)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountBox(String label, double amount, Color color) {
    final hasAmount = amount > 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasAmount ? color.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasAmount ? color.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: hasAmount ? color : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              hasAmount ? _formatCurrency(amount) : '—',
              style: TextStyle(
                color: hasAmount ? color : Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor(String code) {
    if (code.startsWith('1')) return const Color(0xFF10893E);
    if (code.startsWith('2')) return const Color(0xFFD31111);
    if (code.startsWith('3')) return const Color(0xFF1565C0);
    if (code.startsWith('4')) return const Color(0xFF00897B);
    if (code.startsWith('5')) return const Color(0xFFE65100);
    return Colors.grey;
  }

  IconData _getIconForAccount(int code) {
    if (code < 200) return Icons.account_balance_wallet_outlined;
    if (code < 300) return Icons.credit_card_outlined;
    if (code < 400) return Icons.person_outline;
    return Icons.receipt_long_outlined;
  }
}

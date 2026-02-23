import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';

String _formatCurrency(String value) {
  final amount = double.tryParse(value) ?? 0.0;
  final formatted = amount.toStringAsFixed(2).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return '₱$formatted';
}

class LedgerEntryCard extends StatefulWidget {
  final int accountDbId;
  final IconData icon;
  final String code;
  final String name;
  final int transactions;
  final String balance;

  const LedgerEntryCard({
    super.key,
    required this.accountDbId,
    required this.icon,
    required this.code,
    required this.name,
    required this.transactions,
    required this.balance,
  });

  @override
  State<LedgerEntryCard> createState() => _LedgerEntryCardState();
}

class _LedgerEntryCardState extends State<LedgerEntryCard> {
  bool _isExpanded = false;

  Color _getThemeColor(String code) {
    if (code.startsWith('1')) return const Color(0xFF10893E); // Assets - Green
    if (code.startsWith('2'))
      return const Color(0xFFD31111); // Liabilities - Red
    if (code.startsWith('3')) return const Color(0xFF1565C0); // Equity - Blue
    if (code.startsWith('4')) return const Color(0xFF00897B); // Revenue - Teal
    if (code.startsWith('5'))
      return const Color(0xFFE65100); // Expenses - Orange
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final Color themeColor = _getThemeColor(widget.code);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.icon, color: themeColor, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(child: _buildAccountInfo()),
                  _buildBalanceInfo(),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) _buildExpandedDetails(),
        ],
      ),
    );
  }

  Widget _buildExpandedDetails() {
    return StreamBuilder<List<TypedResult>>(
      stream: appDb.ledgerDao.watchTransactionsForAccount(widget.accountDbId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LinearProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No transactions yet',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          );
        }
        final rows = snapshot.data!;
        return Container(
          width: double.infinity,
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: rows.map((row) {
              final tx = row.readTable(appDb.transactions);
              final journal = row.readTable(appDb.journals);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            journal.description,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            journal.date.toString().split(' ').first,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildTxAmount(tx),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTxAmount(Transaction tx) {
    if (tx.debit > 0) {
      return Text(
        '+₱${tx.debit.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Text(
      '-₱${tx.credit.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Colors.red,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Column(
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
                widget.code,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.transactions} transactions',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          widget.name,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBalanceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Balance',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
        ),
        Text(
          _formatCurrency(widget.balance),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}

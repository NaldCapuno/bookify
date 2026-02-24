import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';

String _formatCurrency(String value) {
  final amount = double.tryParse(value) ?? 0.0;
  final formatted = amount.toStringAsFixed(2).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
  return '₱$formatted';
}

String _formatCurrencyDouble(double amount) {
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

Color _getThemeColor(String code) {
  if (code.startsWith('1')) return const Color(0xFF10893E);
  if (code.startsWith('2')) return const Color(0xFFD31111);
  if (code.startsWith('3')) return const Color(0xFF1565C0);
  if (code.startsWith('4')) return const Color(0xFF00897B);
  if (code.startsWith('5')) return const Color(0xFFE65100);
  return Colors.grey;
}

class _LedgerEntryCardState extends State<LedgerEntryCard> {
  bool _isExpanded = false;

  static const _duration = Duration(milliseconds: 300);
  static const _curve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final themeColor = _getThemeColor(widget.code);
    final hasData = widget.transactions > 0;
    return AnimatedContainer(
      duration: _duration,
      curve: _curve,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: hasData ? () => setState(() => _isExpanded = !_isExpanded) : null,
            borderRadius: BorderRadius.circular(15),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: themeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(widget.icon, color: themeColor, size: 28),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.code,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.transactions} transactions',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        _formatCurrency(widget.balance),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (hasData)
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: _duration,
                          curve: _curve,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.grey.shade400,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (hasData)
            AnimatedSize(
              duration: _duration,
              curve: _curve,
              child: _isExpanded ? _buildExpandedContent() : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    return StreamBuilder<List<TypedResult>>(
      stream: appDb.ledgerDao.watchTransactionsForAccount(widget.accountDbId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: LinearProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
            child: Text(
              'No transactions yet',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          );
        }
        final rows = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: rows.map((row) {
              final tx = row.readTable(appDb.transactions);
              final journal = row.readTable(appDb.journals);
              return _buildTransactionItem(journal: journal, tx: tx);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem({
    required Journal journal,
    required Transaction tx,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 6),
              Text(
                DateFormat('MMM d, yyyy').format(journal.date),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              journal.description,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Row(
            children: [
              _buildAmountBox(
                'Debit',
                tx.debit,
                const Color(0xFFE8F5E9),
                const Color(0xFF10893E),
              ),
              const SizedBox(width: 10),
              _buildAmountBox(
                'Credit',
                tx.credit,
                const Color(0xFFE3F2FD),
                const Color(0xFF1565C0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBox(
    String label,
    double amount,
    Color bgColor,
    Color accentColor,
  ) {
    final hasAmount = amount > 0;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hasAmount ? accentColor.withOpacity(0.15) : bgColor,
          borderRadius: BorderRadius.circular(8),
          border: hasAmount
              ? Border.all(color: accentColor.withOpacity(0.3))
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: hasAmount ? accentColor : Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              hasAmount ? _formatCurrencyDouble(amount) : '—',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: hasAmount ? accentColor : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Assets Section
        _buildCategoryHeader('Assets', '5 accounts', const Color(0xFF10893E)),
        const LedgerEntryCard(
          icon: Icons.account_balance_wallet_outlined,
          code: '1000',
          name: 'Cash',
          transactions: 6,
          balance: '50,000.00',
        ),
        const LedgerEntryCard(
          icon: Icons.group_outlined,
          code: '1100',
          name: 'Accounts Receivable',
          transactions: 2,
          balance: '15,000.00',
        ),
        const LedgerEntryCard(
          icon: Icons.inventory_2_outlined,
          code: '1200',
          name: 'Inventory',
          transactions: 1,
          balance: '25,000.00',
        ),

        const SizedBox(height: 16),

        // Liabilities Section
        _buildCategoryHeader(
          'Liabilities',
          '3 accounts',
          const Color(0xFFD31111),
        ),
        const LedgerEntryCard(
          icon: Icons.credit_card_outlined,
          code: '2000',
          name: 'Accounts Payable',
          transactions: 6,
          balance: '50,000.00',
        ),
      ],
    );
  }

  Widget _buildCategoryHeader(String title, String count, Color color) {
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            count,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class LedgerEntryCard extends StatefulWidget {
  final IconData icon;
  final String code;
  final String name;
  final int transactions;
  final String balance;

  const LedgerEntryCard({
    super.key,
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
    if (code.startsWith('1')) return const Color(0xFF10893E);
    if (code.startsWith('2')) return const Color(0xFFD31111);
    if (code.startsWith('3')) return const Color(0xFF1565C0);
    if (code.startsWith('4')) return const Color(0xFF008080);
    if (code.startsWith('5')) return const Color(0xFFEF6C00);
    if (code.startsWith('6')) return const Color(0xFFEF6C00);
    if (code.startsWith('7')) return const Color(0xFFEF6C00);
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
          // Main Card Header
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

          // Expanded Details Section
          if (_isExpanded) ...[
            const Divider(height: 1),
            Container(
              padding: const EdgeInsets.all(12),
              color: const Color(0xFFF8FAFC),
              child: Column(
                children: [
                  // Mock transaction data based on your images
                  _buildTransactionRow(
                    'Feb 01, 2026',
                    'Initial capital investment',
                    '80,000.00',
                    true,
                  ),
                  _buildTransactionRow(
                    'Feb 03, 2026',
                    'Purchase equipment',
                    '40,000.00',
                    false,
                  ),
                  _buildTransactionRow(
                    'Feb 07, 2026',
                    'Sales - cash',
                    '15,000.00',
                    true,
                  ),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1C1E), // Dark theme color
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTotalColumn('Total Debit', '₱105,000.00'),
                        _buildTotalColumn('Total Credit', '₱51,500.00'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
          '₱${widget.balance}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildTransactionRow(
    String date,
    String title,
    String amount,
    bool isDebit,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: Colors.grey.shade400,
              ),
              const SizedBox(width: 6),
              Text(
                date,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniAmountBox(
                  'Debit',
                  isDebit ? '₱$amount' : '—',
                  isDebit,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMiniAmountBox(
                  'Credit',
                  !isDebit ? '₱$amount' : '—',
                  !isDebit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniAmountBox(String label, String value, bool isActive) {
    final Color bgColor = isActive
        ? (label == 'Debit' ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD))
        : Colors.transparent;
    final Color textColor = isActive
        ? (label == 'Debit' ? const Color(0xFF2E7D32) : const Color(0xFF1565C0))
        : Colors.grey.shade400;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalColumn(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Courier', // Monospaced font often used for totals
          ),
        ),
      ],
    );
  }
}

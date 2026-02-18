import 'package:flutter/material.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildCategoryHeader('Assets', '5 accounts', const Color(0xFF10893E)),
        _buildLedgerCard(
          icon: Icons.account_balance_wallet_outlined,
          code: '1000',
          name: 'Cash',
          transactions: 6,
          balance: '50,000.00',
        ),
        _buildLedgerCard(
          icon: Icons.group_outlined,
          code: '1100',
          name: 'Accounts Receivable',
          transactions: 2,
          balance: '15,000.00',
        ),
        _buildLedgerCard(
          icon: Icons.inventory_2_outlined,
          code: '1200',
          name: 'Inventory',
          transactions: 1,
          balance: '25,000.00',
        ),
        _buildLedgerCard(
          icon: Icons.trending_up_outlined,
          code: '1500',
          name: 'Equipment',
          transactions: 1,
          balance: '40,000.00',
        ),
        _buildLedgerCard(
          icon: Icons.show_chart_outlined,
          code: '1600',
          name: 'Accumulated Depreciation',
          transactions: 1,
          balance: '5,000.00',
        ),

        const SizedBox(height: 16),

        _buildCategoryHeader(
          'Liabilities',
          '3 accounts',
          const Color(0xFFD31111),
        ),
        _buildLedgerCard(
          icon: Icons.credit_card_outlined,
          code: '2000',
          name: 'Accounts Payable',
          transactions: 6,
          balance: '50,000.00',
        ),
        _buildLedgerCard(
          icon: Icons.credit_card_outlined,
          code: '2100',
          name: 'Notes Payable',
          transactions: 2,
          balance: '15,000.00',
        ),
        _buildLedgerCard(
          icon: Icons.credit_card_outlined,
          code: '2200',
          name: 'Wages Payable',
          transactions: 1,
          balance: '25,000.00',
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

  Color _getThemeColor(String code) {
    if (code.startsWith('1')) return const Color(0xFF10893E);
    if (code.startsWith('2')) return const Color(0xFFD31111);
    if (code.startsWith('3')) return const Color(0xFF1565C0);
    if (code.startsWith('4')) return const Color(0xFF008080);
    if (code.startsWith('5')) return const Color(0xFFEF6C00);
    return Colors.grey;
  }

  Widget _buildLedgerCard({
    required IconData icon,
    required String code,
    required String name,
    required int transactions,
    required String balance,
  }) {
    final Color themeColor = _getThemeColor(code);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: themeColor, size: 24),
          ),
          const SizedBox(width: 16),

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
                        code,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$transactions transactions',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C1E),
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
              ),
              Row(
                children: [
                  Text(
                    '₱$balance',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1A1C1E),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

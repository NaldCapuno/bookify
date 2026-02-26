import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';
import '../../core/database/daos/journal_entry_daos.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onFeatureTap;

  DashboardScreen({super.key, required this.onFeatureTap});

  // Currency and Date Formatters
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  // Helper method for strict Accounting Standard formatting (Negative numbers in parentheses)
  String _formatAccounting(double amount) {
    if (amount == 0) return '₱0.00';
    final formatted = _currencyFormat.format(amount.abs());
    return amount < 0 ? '(₱$formatted)' : '₱$formatted';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildTotalCashSection(),
        const SizedBox(height: 24),

        const Text(
          'Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        _buildDynamicAnalyticsSections(),
      ],
    );
  }

  // --- SECTION 1: TOTAL CASH ---
  Widget _buildTotalCashSection() {
    return StreamBuilder<List<LedgerEntry>>(
      stream: appDb.ledgerDao.watchLedgerEntries(),
      builder: (context, snapshot) {
        double totalCash = 0.0;

        if (snapshot.hasData) {
          for (var entry in snapshot.data!) {
            final accName = entry.account.name.toLowerCase();
            if (accName.contains('cash') ||
                accName.contains('hand') ||
                accName.contains('bank')) {
              totalCash += entry.balance;
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Total Cash',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatAccounting(totalCash),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- SECTIONS 2, 3, 4 & 5: DYNAMIC ANALYTICS ---
  Widget _buildDynamicAnalyticsSections() {
    return StreamBuilder<List<JournalSummary>>(
      stream: appDb.journalEntryDao.watchJournalSummaries(),
      builder: (context, snapshot) {
        double inflow = 0.0;
        double outflow = 0.0;
        double income = 0.0;
        double expenses = 0.0;
        List<double> quarterlySales = [0.0, 0.0, 0.0, 0.0];
        List<JournalSummary> recentActivities = [];

        if (snapshot.hasData) {
          final now = DateTime.now();

          for (var summary in snapshot.data!) {
            if (summary.journal.isVoid) continue;

            // Add ALL non-voided journal entries to the recent activity feed
            recentActivities.add(summary);

            double entryCashIn = 0;
            double entryCashOut = 0;
            double entryIncome = 0;
            double entryExpense = 0;

            for (var detail in summary.details) {
              final accName = detail.account.name.toLowerCase();
              final deb = detail.transactionLine.debit;
              final cred = detail.transactionLine.credit;

              if (accName.contains('cash') ||
                  accName.contains('hand') ||
                  accName.contains('bank')) {
                entryCashIn += deb;
                entryCashOut += cred;
              }
              // STRICT MATCH: Only accounts containing "Sales Revenue" count towards Total Sales
              else if (accName.contains('sales revenue')) {
                entryIncome += (cred - deb);
              } else if (accName.contains('expense') ||
                  accName.contains('cost') ||
                  accName.contains('purchases') ||
                  accName.contains('supplies')) {
                entryExpense += (deb - cred);
              }
            }

            inflow += entryCashIn;
            outflow += entryCashOut;
            income += entryIncome;
            expenses += entryExpense;

            // Map Sales Revenue to the Quarterly Chart
            if (summary.journal.date.year == now.year && entryIncome > 0) {
              int q = (summary.journal.date.month - 1) ~/ 3;
              if (q >= 0 && q <= 3) {
                quarterlySales[q] += entryIncome;
              }
            }
          }
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFlowCard(
                    'Cash Inflow',
                    _formatAccounting(inflow),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFlowCard(
                    'Cash Outflow',
                    _formatAccounting(outflow),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildProfitAndLossSection(income, expenses),
            const SizedBox(height: 24),

            _buildTotalSalesChart(quarterlySales),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => onFeatureTap(1),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentActivityList(recentActivities),
          ],
        );
      },
    );
  }

  Widget _buildFlowCard(
    String title,
    String amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitAndLossSection(double income, double expenses) {
    double netProfit = income - expenses;
    int incomeFlex = (income <= 0 && expenses <= 0)
        ? 1
        : (income * 100).toInt();
    int expenseFlex = (income <= 0 && expenses <= 0)
        ? 1
        : (expenses * 100).toInt();
    final NumberFormat compactCurrency = NumberFormat('#,##0', 'en_US');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profit & Loss',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatAccounting(
                netProfit,
              ), // Automatically applies ( ) if negative!
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 40,
              child: Row(
                children: [
                  Expanded(
                    flex: incomeFlex,
                    child: Container(
                      color: const Color(0xFFC7CDFF),
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₱${compactCurrency.format(income)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: expenseFlex,
                    child: Container(
                      color: const Color(0xFFFFD1D1),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₱${compactCurrency.format(expenses)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Income',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Text(
                'Expenses',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSalesChart(List<double> quarterlySales) {
    double maxSales = quarterlySales.reduce((a, b) => a > b ? a : b);
    if (maxSales == 0) maxSales = 1;
    double totalYearSales = quarterlySales.fold(
      0.0,
      (prev, element) => prev + element,
    );

    final now = DateTime.now();
    final yearStr = now.year.toString().substring(2);
    int currentQ = (now.month - 1) ~/ 3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Sales',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatAccounting(totalYearSales),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B4FFF),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildVerticalBar(
                  quarterlySales[0],
                  maxSales,
                  "Q1 '$yearStr",
                  currentQ == 0,
                ),
                _buildVerticalBar(
                  quarterlySales[1],
                  maxSales,
                  "Q2 '$yearStr",
                  currentQ == 1,
                ),
                _buildVerticalBar(
                  quarterlySales[2],
                  maxSales,
                  "Q3 '$yearStr",
                  currentQ == 2,
                ),
                _buildVerticalBar(
                  quarterlySales[3],
                  maxSales,
                  "Q4 '$yearStr",
                  currentQ == 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBar(
    double value,
    double max,
    String label,
    bool isCurrent,
  ) {
    double heightFactor = value / max;
    Color barColor = isCurrent
        ? const Color(0xFF3B4FFF)
        : const Color(0xFFC7CDFF);
    Color textColor = isCurrent
        ? const Color(0xFF3B4FFF)
        : Colors.grey.shade500;

    String formatK(double val) {
      if (val == 0) return '';
      double inK = val / 1000;
      String numStr = inK.toStringAsFixed(1);
      return val < 0 ? '(₱${numStr}k)' : '₱${numStr}k';
    }

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatK(value),
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: (100 * heightFactor).clamp(4.0, 100.0),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // --- NEUTRAL RECENT ACTIVITY LIST ---
  Widget _buildRecentActivityList(List<JournalSummary> recentActivities) {
    if (recentActivities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'No entries found',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    final topActivities = recentActivities.take(3).toList();

    return Column(
      children: topActivities.map((summary) {
        // Calculate the total amount of the journal entry (Sum of Debits)
        double totalAmount = summary.details.fold(
          0.0,
          (sum, item) => sum + item.transactionLine.debit,
        );
        final dateStr = _dateFormat.format(summary.journal.date);

        return _buildActivityItem(
          summary.journal.description,
          dateStr,
          totalAmount,
        );
      }).toList(),
    );
  }

  Widget _buildActivityItem(String description, String date, double amount) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Neutral Icon Styling
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long, // Standard journal/receipt icon
                    color: Colors.grey.shade700,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date, // Only date is shown now
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Neutral text color for the amount
          Text(
            _formatAccounting(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

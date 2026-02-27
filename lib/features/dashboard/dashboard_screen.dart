import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/ledger_dao.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/services/user_service.dart';
import 'package:bookkeeping/core/database/daos/users_dao.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onFeatureTap;

  const DashboardScreen({super.key, required this.onFeatureTap});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Tracks how many sales items to display in the feed
  int _visibleSalesCount = 3;

  // Currency and Date Formatters
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  late final UserService _userService;

  // Helper method for strict Accounting Standard formatting (Negative numbers in parentheses)
  String _formatAccounting(double amount) {
    if (amount == 0) return '₱0.00';
    final formatted = _currencyFormat.format(amount.abs());
    return amount < 0 ? '(₱$formatted)' : '₱$formatted';
  }

  @override
  void initState() {
    super.initState();
    // 2. Initialize it using the global appDb instance
    _userService = UserService(UsersDao(appDb));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildWelcomeBanner(),
        const SizedBox(height: 16),
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
            if (accName.contains('cash on hand')) {
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
                    'Cash on Hand',
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

        // List explicitly for sales entries
        List<JournalSummary> salesActivities = [];

        if (snapshot.hasData) {
          final now = DateTime.now();

          for (var summary in snapshot.data!) {
            if (summary.journal.isVoid) continue;

            double entryCashIn = 0;
            double entryCashOut = 0;
            double entryIncome = 0;
            double entryExpense = 0;
            bool isSale = false;

            for (var detail in summary.details) {
              final accName = detail.account.name.toLowerCase();
              final deb = detail.transactionLine.debit;
              final cred = detail.transactionLine.credit;

              if (accName.contains('cash on hand')) {
                entryCashIn += deb;
                entryCashOut += cred;
              }
              // STRICT MATCH: Only accounts containing "Sales Revenue"
              else if (accName.contains('sales revenue')) {
                entryIncome += (cred - deb);
                isSale = true; // Mark that this journal entry contains a sale
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

            // If it is a sale, add it to our specific sales feed list
            if (isSale && entryIncome > 0) {
              salesActivities.add(summary);
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
                    'Cash In',
                    _formatAccounting(inflow),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFlowCard(
                    'Cash Out',
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

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildRecentSalesList(salesActivities),
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
              _formatAccounting(netProfit),
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
                    child: Container(color: const Color(0xFFC7CDFF)),
                  ),
                  Expanded(
                    flex: expenseFlex,
                    child: Container(color: const Color(0xFFFFD1D1)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Moved the numeric values down here for better readability
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    '₱${compactCurrency.format(income)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Expenses',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                  Text(
                    '₱${compactCurrency.format(expenses)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
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

  // --- STRICTLY SALES ACTIVITY LIST ---
  Widget _buildRecentSalesList(List<JournalSummary> salesActivities) {
    if (salesActivities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'No sales found',
            style: TextStyle(color: Colors.grey[500]),
          ),
        ),
      );
    }

    final visibleActivities = salesActivities.take(_visibleSalesCount).toList();

    return Column(
      children: [
        ...visibleActivities.map((summary) {
          // Extract the exact sales amount from this specific journal entry
          double entrySaleAmount = 0.0;
          for (var detail in summary.details) {
            final accName = detail.account.name.toLowerCase();
            if (accName.contains('sales revenue')) {
              entrySaleAmount +=
                  (detail.transactionLine.credit -
                  detail.transactionLine.debit);
            }
          }

          final dateStr = _dateFormat.format(summary.journal.date);

          return _buildSaleItem(
            summary.journal.description,
            dateStr,
            entrySaleAmount,
          );
        }),

        // Dynamic Load More Button
        if (salesActivities.length > _visibleSalesCount)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextButton(
              onPressed: () {
                setState(() {
                  _visibleSalesCount += 3;
                });
              },
              child: const Text('Load More'),
            ),
          ),
      ],
    );
  }

  Widget _buildSaleItem(String description, String date, double amount) {
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
                // Restored the Green "Add" Icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.green, size: 18),
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
                        date,
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Restored the Green Text
          Text(
            _formatAccounting(amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  // Inside your Dashboard widget
  Widget _buildWelcomeBanner() {
    return StreamBuilder<User?>(
      stream: _userService.watchUserProfile(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // Fallback values while loading or if data is missing
        final String name = user?.username ?? "User";
        final String business = user?.business ?? "Your Business";

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1C1E), // Your signature black/dark grey
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.business_center,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    business,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

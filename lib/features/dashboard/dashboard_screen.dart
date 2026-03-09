import 'package:bookkeeping/features/quick_action/quick_actions_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/ledger_dao.dart';
import 'package:bookkeeping/core/database/daos/journal_entry_daos.dart';
import 'package:bookkeeping/core/services/user_service.dart';
import 'package:bookkeeping/core/database/daos/users_dao.dart';
import 'package:bookkeeping/core/services/walkthrough_service.dart';
import 'package:bookkeeping/core/widgets/app_fab.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onFeatureTap;
  final int selectedIndex;
  final int myIndex;

  const DashboardScreen({
    super.key,
    required this.onFeatureTap,
    required this.selectedIndex,
    required this.myIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey _bannerKey = GlobalKey();
  final GlobalKey _cashCardKey = GlobalKey();
  final GlobalKey _plKey = GlobalKey();
  final GlobalKey _chartKey = GlobalKey();

  int _visibleSalesCount = 3;
  final NumberFormat _currencyFormat = NumberFormat('#,##0.00', 'en_US');
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  late final UserService _userService;

  String _formatAccounting(double amount) {
    if (amount == 0) return '₱0.00';
    final formatted = _currencyFormat.format(amount.abs());
    return amount < 0 ? '(₱$formatted)' : '₱$formatted';
  }

  bool _hasShownTour = false;

  @override
  void initState() {
    super.initState();
    _userService = UserService(UsersDao(appDb));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartWalkthrough();
    });
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.myIndex && !_hasShownTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartWalkthrough();
      });
    }
  }

  void _maybeStartWalkthrough() {
    if (!mounted || _hasShownTour || widget.selectedIndex != widget.myIndex) {
      return;
    }
    _hasShownTour = true;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      WalkthroughService.showDashboardTour(
        context,
        bannerKey: _bannerKey,
        cashCardKey: _cashCardKey,
        profitAndLossKey: _plKey,
        salesChartKey: _chartKey,
      );
    });
  }

  void _goToQuickActions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => const QuickActionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        cacheExtent: 2000,
        children: [
          _buildWelcomeBanner(context, key: _bannerKey),
          const SizedBox(height: 16),
          _buildLiquiditySection(context, key: _cashCardKey),
          const SizedBox(height: 24),
          const Text(
            'Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDynamicAnalyticsSections(),
        ],
      ),
      floatingActionButton: AppFloatingActionButton(
        label: 'Quick Entry',
        icon: Icons.bolt,
        onPressed: () => _goToQuickActions(context),
      ),
    );
  }

  // --- SECTION 1: UPDATED LIQUIDITY (Total -> Breakdown) ---
  Widget _buildLiquiditySection(BuildContext context, {required Key key}) {
    return StreamBuilder<List<LedgerEntry>>(
      stream: appDb.ledgerDao.watchLedgerEntries(),
      builder: (context, snapshot) {
        double cashOnHand = 0.0;
        double cashInBank = 0.0;

        if (snapshot.hasData) {
          for (var entry in snapshot.data!) {
            final accName = entry.account.name.toLowerCase();
            if (accName == 'cash on hand') cashOnHand += entry.balance;
            if (accName == 'cash in bank') cashInBank += entry.balance;
          }
        }

        double totalLiquidity = cashOnHand + cashInBank;

        return Container(
          key: key,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color.fromARGB(255, 44, 161, 51)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Liquidity',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                child: Text(
                  _formatAccounting(totalLiquidity),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(color: Colors.white24, height: 1),
              ),
              _buildSmallLiquidityRow(
                'Cash on Hand',
                cashOnHand,
                Icons.payments,
              ),
              const SizedBox(height: 8),
              _buildSmallLiquidityRow(
                'Cash in Bank',
                cashInBank,
                Icons.account_balance,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallLiquidityRow(String title, double amount, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const Spacer(),
        Text(
          _formatAccounting(amount),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // --- DYNAMIC ANALYTICS (Revenue & Cost Calculation) ---
  Widget _buildDynamicAnalyticsSections() {
    return StreamBuilder<List<JournalSummary>>(
      stream: appDb.journalEntryDao.watchJournalSummaries(),
      builder: (context, snapshot) {
        double netSales = 0.0;
        double totalCosts = 0.0;
        double inflow = 0.0;
        double outflow = 0.0;
        List<double> quarterlySales = [0.0, 0.0, 0.0, 0.0];
        List<JournalSummary> salesActivities = [];

        if (snapshot.hasData) {
          final now = DateTime.now();
          for (var summary in snapshot.data!) {
            if (summary.journal.isVoid) continue;

            double entryNetSale = 0.0;
            bool isSaleEvent = false;

            for (var detail in summary.details) {
              final accName = detail.account.name.toLowerCase();
              final dr = detail.transactionLine.debit;
              final cr = detail.transactionLine.credit;

              // Cash Flow (Liquidity check)
              if (accName.contains('cash on hand') ||
                  accName.contains('cash in bank')) {
                inflow += dr;
                outflow += cr;
              }

              // Revenue logic (Gross - Contra)
              if (accName == 'sales revenue') {
                entryNetSale += (cr - dr);
                isSaleEvent = true;
              } else if (accName == 'sales returns and allowances' ||
                  accName == 'sales discounts') {
                entryNetSale -= (dr - cr);
              }

              // Costs & Operating Expenses
              if (accName == 'raw materials used' ||
                  accName == 'direct labor' ||
                  accName == 'cost of goods sold (cogs)' ||
                  accName.contains('expense') ||
                  accName == 'bank fees') {
                totalCosts += (dr - cr);
              }
            }

            netSales += entryNetSale;
            if (summary.journal.date.year == now.year && entryNetSale > 0) {
              int q = (summary.journal.date.month - 1) ~/ 3;
              if (q >= 0 && q <= 3) quarterlySales[q] += entryNetSale;
            }
            if (isSaleEvent) salesActivities.add(summary);
          }
        }

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildFlowCard(
                    context,
                    'Cash In',
                    _formatAccounting(inflow),
                    Icons.arrow_downward,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFlowCard(
                    context,
                    'Cash Out',
                    _formatAccounting(outflow),
                    Icons.arrow_upward,
                    Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProfitAndLossSection(
              context,
              netSales,
              totalCosts,
              key: _plKey,
            ),
            const SizedBox(height: 24),
            _buildTotalSalesChart(context, quarterlySales, key: _chartKey),
            const SizedBox(height: 24),
            _buildRecentSalesList(context, salesActivities),
          ],
        );
      },
    );
  }

  Widget _buildFlowCard(
    BuildContext context,
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
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          FittedBox(
            child: Text(
              amount,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Restored the Bar Comparison (Net Sales vs Total Costs)
  Widget _buildProfitAndLossSection(
    BuildContext context,
    double income,
    double expenses, {
    required Key key,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double netProfit = income - expenses;

    // Logic for progress bar flex
    int incomeFlex = (income <= 0 && expenses <= 0)
        ? 1
        : (income.abs() * 100).toInt();
    int expenseFlex = (income <= 0 && expenses <= 0)
        ? 1
        : (expenses.abs() * 100).toInt();

    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profit & Loss',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              _formatAccounting(netProfit),
              style: theme.textTheme.headlineMedium!.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // RESTORED: Bar chart visual
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(
                    flex: incomeFlex,
                    child: Container(color: Colors.blue.withOpacity(0.6)),
                  ),
                  Expanded(
                    flex: expenseFlex,
                    child: Container(color: Colors.red.withOpacity(0.4)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _simpleStat('Net Sales', income, Colors.blue),
              _simpleStat('Total Costs', expenses, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _simpleStat(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text(
          _formatAccounting(value),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSalesChart(
    BuildContext context,
    List<double> quarterlySales, {
    required Key key,
  }) {
    double maxSales = quarterlySales.reduce((a, b) => a > b ? a : b);
    if (maxSales == 0) maxSales = 1;

    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Net Sales per Quarter',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(
                4,
                (i) => _buildVerticalBar(
                  context,
                  quarterlySales[i],
                  maxSales,
                  "Q${i + 1}",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalBar(
    BuildContext context,
    double value,
    double max,
    String label,
  ) {
    double factor = value / max;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FittedBox(
            child: Text(
              '₱${(value / 1000).toStringAsFixed(1)}k',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 35,
            height: (100 * factor).clamp(4, 100),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade600],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildRecentSalesList(
    BuildContext context,
    List<JournalSummary> salesActivities,
  ) {
    final visible = salesActivities.reversed.take(_visibleSalesCount).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Sales Activities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (visible.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('No sales yet.')),
          ),
        ...visible.map((s) {
          double saleAmt = 0;
          for (var d in s.details) {
            final name = d.account.name.toLowerCase();
            if (name == 'sales revenue')
              saleAmt += (d.transactionLine.credit - d.transactionLine.debit);
            if (name.contains('discount') || name.contains('return'))
              saleAmt -= (d.transactionLine.debit - d.transactionLine.credit);
          }
          return _buildSaleItem(
            context,
            s.journal.description,
            _dateFormat.format(s.journal.date),
            saleAmt,
          );
        }),
      ],
    );
  }

  Widget _buildSaleItem(
    BuildContext context,
    String desc,
    String date,
    double amt,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.blueAccent,
            radius: 18,
            child: Icon(Icons.receipt_long, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  desc,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            _formatAccounting(amt),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner(BuildContext context, {required Key key}) {
    return StreamBuilder<User?>(
      stream: _userService.watchUserProfile(),
      builder: (context, snapshot) {
        final name = snapshot.data?.username ?? "User";
        final business = snapshot.data?.business ?? "Your Business";
        return Container(
          key: key,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $name 👋',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                business,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

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

  // Helper method for strict Accounting Standard formatting (Negative numbers in parentheses)
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
    // Delay so splash/onboarding transition settles and first target positions correctly
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

  // ... inside your Widget class ...

  void _goToQuickActions(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog:
            true, // This makes it slide up like a sheet, but it's a screen
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
          _buildTotalCashSection(context, key: _cashCardKey),
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
        icon: Icons.bolt, // Lightning bolt signifies "Quick Action"
        onPressed: () => _goToQuickActions(context),
      ),
    );
  }

  // --- SECTION 1: TOTAL CASH ---
  Widget _buildTotalCashSection(BuildContext context, {required Key key}) {
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
          key: key,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF43A047)], // Green shades
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Cash on Hand',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
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
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
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

            _buildProfitAndLossSection(context, income, expenses, key: _plKey),
            const SizedBox(height: 24),

            _buildTotalSalesChart(context, quarterlySales, key: _chartKey),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Sales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.bodySmall!.copyWith(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: theme.textTheme.titleSmall!.copyWith(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitAndLossSection(
    BuildContext context,
    double income,
    double expenses, {
    required Key key,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    double netProfit = income - expenses;
    int incomeFlex = (income <= 0 && expenses <= 0)
        ? 1
        : (income * 100).toInt();
    int expenseFlex = (income <= 0 && expenses <= 0)
        ? 1
        : (expenses * 100).toInt();
    final NumberFormat compactCurrency = NumberFormat('#,##0', 'en_US');

    return Container(
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profit & Loss', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatAccounting(netProfit),
              style: theme.textTheme.headlineMedium!.copyWith(fontSize: 28),
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
                      color: colorScheme.tertiary.withValues(alpha: 0.3),
                    ),
                  ),
                  Expanded(
                    flex: expenseFlex,
                    child: Container(
                      color: colorScheme.error.withValues(alpha: 0.2),
                    ),
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
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '₱${compactCurrency.format(income)}',
                    style: theme.textTheme.bodyMedium!.copyWith(
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
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '₱${compactCurrency.format(expenses)}',
                    style: theme.textTheme.bodyMedium!.copyWith(
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

  Widget _buildTotalSalesChart(
    BuildContext context,
    List<double> quarterlySales, {
    required Key key,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
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
      key: key,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Sales', style: theme.textTheme.titleSmall),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              _formatAccounting(totalYearSales),
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.tertiary,
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
                  context,
                  quarterlySales[0],
                  maxSales,
                  "Q1 '$yearStr",
                  currentQ == 0,
                ),
                _buildVerticalBar(
                  context,
                  quarterlySales[1],
                  maxSales,
                  "Q2 '$yearStr",
                  currentQ == 1,
                ),
                _buildVerticalBar(
                  context,
                  quarterlySales[2],
                  maxSales,
                  "Q3 '$yearStr",
                  currentQ == 2,
                ),
                _buildVerticalBar(
                  context,
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
    BuildContext context,
    double value,
    double max,
    String label,
    bool isCurrent,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    double heightFactor = value / max;
    Color barColor = isCurrent
        ? colorScheme.tertiary
        : colorScheme.tertiary.withValues(alpha: 0.4);
    Color textColor = isCurrent
        ? colorScheme.tertiary
        : colorScheme.onSurfaceVariant;

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
              style: theme.textTheme.bodySmall!.copyWith(
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
            style: theme.textTheme.bodySmall!.copyWith(
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
  Widget _buildRecentSalesList(
    BuildContext context,
    List<JournalSummary> salesActivities,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (salesActivities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Center(
          child: Text(
            'No sales found',
            style: theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
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
            context,
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

  Widget _buildSaleItem(
    BuildContext context,
    String description,
    String date,
    double amount,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withValues(alpha: 0.03),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.add, color: colorScheme.tertiary, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        date,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatAccounting(amount),
            style: theme.textTheme.bodyMedium!.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  // Inside your Dashboard widget
  Widget _buildWelcomeBanner(BuildContext context, {required Key key}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return StreamBuilder<User?>(
      stream: _userService.watchUserProfile(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        // Fallback values while loading or if data is missing
        final String name = user?.username ?? "User";
        final String business = user?.business ?? "Your Business";

        return Container(
          key: key,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome, $name',
                style: theme.textTheme.headlineMedium!.copyWith(
                  color: colorScheme.onPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.business_center,
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    business,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: colorScheme.onPrimary.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
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

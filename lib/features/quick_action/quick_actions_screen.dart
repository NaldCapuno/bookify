import 'package:flutter/material.dart';

// Consolidated Imports
import 'views/sell_products_view.dart';
import 'views/record_purchase_view.dart';
import 'views/inventory_view.dart';
import 'views/banking_view.dart';
import 'views/collect_money_view.dart';
import 'views/invest_to_business_view.dart';
import 'views/disburse_funds_view.dart';
import 'views/pay_your_debt_view.dart';
import 'views/lend_money_view.dart';
import 'views/settle_operations_view.dart';
import 'views/fund_marketing_view.dart';
import 'views/refund_to_customers_view.dart';
import 'views/record_other_expense_view.dart';
import 'views/borrow_money_view.dart';
import 'views/pay_workers_view.dart';
import 'views/consume_supplies_view.dart';

class QuickActionScreen extends StatelessWidget {
  const QuickActionScreen({super.key});

  /// Green theme for Receive Money hero tile only; rest use app_theme.
  static const MaterialColor _receiveTheme = Colors.lightGreen;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenFill = isDark
        ? Colors.lightGreen.shade900.withValues(alpha: 0.35)
        : Colors.lightGreen.shade50;
    final blueFill = isDark
        ? Colors.blue.shade900.withValues(alpha: 0.35)
        : Colors.blue.shade50;
    return Scaffold(
      backgroundColor: scheme.surfaceContainerHighest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: scheme.surfaceContainerHighest,
        leading: IconButton(
          icon: Icon(Icons.close, color: scheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Quick Actions",
          style:
              textTheme.headlineLarge?.copyWith(fontSize: 20) ??
              TextStyle(color: scheme.onSurface, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // 1. HERO TILE: RECEIVE MONEY (green)
          _buildHeroTile(
            context: context,
            title: "Receive Money",
            subtitle: "Record cash or bank payments from customers",
            icon: Icons.payments_outlined,
            themeColor: _receiveTheme,
            onTap: () => _showSubmenu(context, _buildReceiveSubmenu(context)),
          ),
          const SizedBox(height: 12),

          // 2. SOFT WIDE TILE: PURCHASE (theme)
          _buildSoftWideTile(
            context: context,
            title: "Purchase",
            subtitle: "Record buying supplies, equipment, or assets",
            icon: Icons.shopping_bag_outlined,
            onTap: () => _showSubmenu(context, _buildPurchaseSubmenu(context)),
          ),
          const SizedBox(height: 12),

          // 3. BANKING ROW (theme)
          Row(
            children: [
              Expanded(
                child: _buildGridTile(
                  context,
                  "Deposit\nto Bank",
                  Icons.account_balance_outlined,
                  borderColor: Colors.lightGreen.shade700,
                  fillColor: greenFill,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BankingView(type: 'Deposit'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridTile(
                  context,
                  "Withdraw\nFrom Bank",
                  Icons.account_balance_wallet_outlined,
                  borderColor: Colors.lightGreen.shade700,
                  fillColor: greenFill,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const BankingView(type: 'Withdraw'),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 48, thickness: 1),

          // 4. INVENTORY SECTION (theme)
          _buildSectionHeader(context, "INVENTORY & PRODUCTION"),
          Row(
            children: [
              Expanded(
                child: _buildGridTile(
                  context,
                  "Acquire\nRaw Materials",
                  Icons.widgets_outlined,
                  borderColor: Colors.blue.shade700,
                  fillColor: blueFill,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const InventoryView(actionType: 'Acquire'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGridTile(
                  context,
                  "Produce\nFinished Goods",
                  Icons.inventory_2_outlined,
                  borderColor: Colors.blue.shade700,
                  fillColor: blueFill,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const InventoryView(actionType: 'Produce'),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 48, thickness: 1),

          // 5. OTHER ACTIONS SECTION (theme)
          _buildSectionHeader(context, "OTHER ACTIONS"),
          _buildListTile(
            context,
            "Pay your Debt",
            "Pay off an existing loan",
            Icons.credit_score,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayYourDebtView()),
            ),
          ),
          _buildListTile(
            context,
            "Disburse Funds",
            "Owner withdrawal or fund distribution",
            Icons.account_balance_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DisburseFundsView()),
            ),
          ),
          _buildListTile(
            context,
            "Lend Money",
            "Provide a loan or advance",
            Icons.handshake_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LendMoneyView()),
            ),
          ),
          _buildListTile(
            context,
            "Settle Operations",
            "Pay rent, salaries, utilities",
            Icons.storefront,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettleOperationsView()),
            ),
          ),
          _buildListTile(
            context,
            "Pay Employees",
            "Pay production labor (direct labor)",
            Icons.engineering_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayWorkersView()),
            ),
          ),
          _buildListTile(
            context,
            "Consume Supplies",
            "Record supplies used in operations",
            Icons.inventory_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsumeSuppliesView()),
            ),
          ),
          _buildListTile(
            context,
            "Fund Marketing",
            "Pay for ads and promotions",
            Icons.campaign_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FundMarketingView()),
            ),
          ),
          _buildListTile(
            context,
            "Refund to Customers",
            "Return money for goods",
            Icons.assignment_return_outlined,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RefundToCustomersView()),
            ),
          ),

          // MOVED TO LAST
          _buildListTile(
            context,
            "Record Other Expense",
            "Bank fees or misc costs",
            Icons.more_horiz,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecordOtherExpenseView()),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- NAVIGATION HELPERS ---

  void _showSubmenu(BuildContext context, Widget content) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: content,
      ),
    );
  }

  // --- SUBMENU WIDGETS ---

  Widget _buildReceiveSubmenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetHeader(context, "Receive Money"),
        _buildListTile(
          context,
          "Collect Money",
          "Payment for receivables",
          Icons.request_quote_outlined,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CollectMoneyView()),
            );
          },
        ),
        _buildListTile(
          context,
          "Invest to Business",
          "Owner's capital injection",
          Icons.savings_outlined,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvestToBusinessView()),
            );
          },
        ),
        _buildListTile(
          context,
          "Borrow Money",
          "Borrow from lender or supplier",
          Icons.credit_score_outlined,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BorrowMoneyView()),
            );
          },
        ),
        _buildListTile(
          context,
          "Sell Products",
          "Direct cash or credit sale",
          Icons.point_of_sale_outlined,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SellProductsView()),
            );
          },
        ),
      ],
    );
  }

  static const Map<String, IconData> _purchaseCategoryIcons = {
    'Supplies': Icons.inventory_2_outlined,
    'Equipment': Icons.precision_manufacturing_outlined,
    'Furniture': Icons.chair_outlined,
    'Land': Icons.landscape_outlined,
    'Building': Icons.apartment_outlined,
    'Vehicle': Icons.directions_car_outlined,
  };

  Widget _buildPurchaseSubmenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetHeader(context, "Purchase Asset"),
        ...[
          'Supplies',
          'Equipment',
          'Furniture',
          'Land',
          'Building',
          'Vehicle',
        ].map(
          (cat) => _buildListTile(
            context,
            cat,
            "Record purchase of $cat",
            _purchaseCategoryIcons[cat] ?? Icons.add_business_outlined,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RecordPurchaseView(initialCategory: cat),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- REUSABLE UI COMPONENTS (Standardized) ---

  Widget _sheetHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style:
            textTheme.titleMedium?.copyWith(
              color: scheme.onSurface,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ) ??
            TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
      ),
    );
  }

  Widget _buildHeroTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? themeColor.shade900 : themeColor.shade800;
    final textColor = Colors.white;
    final subtitleColor = Colors.white.withValues(alpha: 0.85);
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(color: subtitleColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: textColor, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoftWideTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final greenFill = isDark
        ? Colors.lightGreen.shade900.withValues(alpha: 0.35)
        : Colors.lightGreen.shade50;
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: greenFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.lightGreen.shade700, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(icon, color: scheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style:
                            textTheme.titleMedium?.copyWith(fontSize: 15) ??
                            TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: scheme.onSurface,
                            ),
                      ),
                      Text(
                        subtitle,
                        style:
                            textTheme.bodySmall?.copyWith(fontSize: 12) ??
                            TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: scheme.onSurfaceVariant,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile(
    BuildContext context,
    String t,
    IconData i, {
    required Color borderColor,
    required Color fillColor,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(i, color: scheme.primary),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: scheme.onSurfaceVariant,
                      size: 12,
                    ),
                  ],
                ),
                Text(
                  t,
                  style:
                      textTheme.titleSmall?.copyWith(height: 1.1) ??
                      TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        height: 1.1,
                        color: scheme.onSurface,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    String t,
    String s,
    IconData i, {
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: scheme.surfaceContainerHighest,
        child: Icon(i, color: scheme.primary, size: 20),
      ),
      title: Text(
        t,
        style:
            textTheme.titleMedium?.copyWith(fontSize: 15) ??
            TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: scheme.onSurface,
            ),
      ),
      subtitle: Text(
        s,
        style:
            textTheme.bodySmall?.copyWith(fontSize: 12) ??
            TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: scheme.outlineVariant,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: scheme.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

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
import 'views/remit_taxes_view.dart';
import 'views/refund_to_customers_view.dart';
import 'views/record_other_expense_view.dart';
import 'views/borrow_money_view.dart';
import 'views/pay_workers_view.dart';
import 'views/consume_supplies_view.dart';

class QuickActionScreen extends StatelessWidget {
  const QuickActionScreen({super.key});

  final MaterialColor receiveTheme = Colors.lightGreen;
  final MaterialColor outflowTheme = Colors.lightGreen;
  final MaterialColor inventoryTheme = Colors.blue;
  final MaterialColor otherTheme = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Quick Actions",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          // 1. HERO TILE: RECEIVE MONEY
          _buildHeroTile(
            title: "Receive Money",
            subtitle: "Record cash or bank payments from customers",
            icon: Icons.payments_outlined,
            themeColor: receiveTheme,
            onTap: () => _showSubmenu(context, _buildReceiveSubmenu(context)),
          ),
          const SizedBox(height: 12),

          // 2. SOFT WIDE TILE: PURCHASE
          _buildSoftWideTile(
            title: "Purchase",
            subtitle: "Record buying supplies, equipment, or assets",
            icon: Icons.shopping_bag_outlined,
            themeColor: outflowTheme,
            onTap: () => _showSubmenu(context, _buildPurchaseSubmenu(context)),
          ),
          const SizedBox(height: 12),

          // 3. BANKING ROW
          Row(
            children: [
              Expanded(
                child: _buildGridTile(
                  "Deposit\nto Bank",
                  Icons.account_balance_outlined,
                  outflowTheme,
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
                  "Withdraw\nFrom Bank",
                  Icons.account_balance_wallet_outlined,
                  outflowTheme,
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

          // 4. INVENTORY SECTION
          _buildSectionHeader("INVENTORY & PRODUCTION", inventoryTheme),
          Row(
            children: [
              Expanded(
                child: _buildGridTile(
                  "Acquire\nMaterials",
                  Icons.widgets_outlined,
                  inventoryTheme,
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
                  "Produce\nGoods",
                  Icons.inventory_2_outlined,
                  inventoryTheme,
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

          // 5. OTHER ACTIONS SECTION
          _buildSectionHeader("OTHER ACTIONS", Colors.black54),
          _buildListTile(
            "Pay your Debt",
            "Pay off an existing loan",
            Icons.credit_score,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayYourDebtView()),
            ),
          ),
          _buildListTile(
            "Disburse Funds",
            "Owner withdrawal or fund distribution",
            Icons.account_balance_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DisburseFundsView()),
            ),
          ),
          _buildListTile(
            "Lend Money",
            "Provide a loan or advance",
            Icons.handshake_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LendMoneyView()),
            ),
          ),
          _buildListTile(
            "Settle Operations",
            "Pay rent, salaries, utilities",
            Icons.storefront,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettleOperationsView()),
            ),
          ),
          _buildListTile(
            "Pay Employees",
            "Pay production labor (direct labor)",
            Icons.engineering_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PayWorkersView()),
            ),
          ),
          _buildListTile(
            "Consume Supplies",
            "Record supplies used in operations",
            Icons.inventory_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ConsumeSuppliesView()),
            ),
          ),
          _buildListTile(
            "Fund Marketing",
            "Pay for ads and promotions",
            Icons.campaign_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FundMarketingView()),
            ),
          ),
          _buildListTile(
            "Remit Taxes",
            "Pay government tax dues",
            Icons.receipt_long_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RemitTaxesView()),
            ),
          ),
          _buildListTile(
            "Refund to Customers",
            "Return money for goods",
            Icons.assignment_return_outlined,
            otherTheme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RefundToCustomersView()),
            ),
          ),

          // MOVED TO LAST
          _buildListTile(
            "Record Other Expense",
            "Bank fees or misc costs",
            Icons.more_horiz,
            otherTheme,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
        _sheetHeader("Receive Money", receiveTheme),
        _buildListTile(
          "Collect Money",
          "Payment for receivables",
          Icons.request_quote_outlined,
          receiveTheme,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CollectMoneyView()),
            );
          },
        ),
        _buildListTile(
          "Invest to Business",
          "Owner's capital injection",
          Icons.savings_outlined,
          receiveTheme,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InvestToBusinessView()),
            );
          },
        ),
        _buildListTile(
          "Borrow Money",
          "Borrow from lender or supplier",
          Icons.credit_score_outlined,
          receiveTheme,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BorrowMoneyView()),
            );
          },
        ),
        _buildListTile(
          "Sell Products",
          "Direct cash or credit sale",
          Icons.point_of_sale_outlined,
          receiveTheme,
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

  Widget _buildPurchaseSubmenu(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetHeader("Purchase Asset", outflowTheme),
        ...[
          'Supplies',
          'Equipment',
          'Furniture',
          'Land',
          'Building',
          'Vehicle',
        ].map(
          (cat) => _buildListTile(
            cat,
            "Record purchase of $cat",
            Icons.add_business_outlined,
            outflowTheme,
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

  Widget _sheetHeader(String title, MaterialColor color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: color.shade900,
        ),
      ),
    );
  }

  Widget _buildHeroTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: themeColor.shade800,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoftWideTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: themeColor.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.shade200),
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
                Icon(icon, color: themeColor.shade700),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: themeColor.shade700,
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
                  color: themeColor.shade300,
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
    String t,
    IconData i,
    MaterialColor c, {
    VoidCallback? onTap,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: c.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.shade200),
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
                    Icon(i, color: c.shade700),
                    Icon(Icons.arrow_forward_ios, color: c.shade300, size: 12),
                  ],
                ),
                Text(
                  t,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    height: 1.1,
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
    String t,
    String s,
    IconData i,
    MaterialColor c, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: c.shade50,
        child: Icon(i, color: c.shade700, size: 20),
      ),
      title: Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: Text(s, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.black12,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

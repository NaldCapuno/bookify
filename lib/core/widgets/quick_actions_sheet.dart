import 'package:flutter/material.dart';

class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Section Themes separated perfectly
    final MaterialColor receiveTheme = Colors.lightGreen; // Money In
    final MaterialColor outflowTheme = Colors.lightGreen; // Purchase & Banking
    final MaterialColor inventoryTheme = Colors.blue; // Inventory
    final MaterialColor otherTheme = Colors.teal; // Standard list items
    final Color labelTheme = Colors.black; // Standard list items

    return Container(
      padding: EdgeInsets.only(
        top: 32,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- DRAG HANDLE & HEADER ---
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 24),

            // ==========================================
            // TOP ACTIONS
            // ==========================================

            // 8x2 Hero: Receive Money (Distinct Green Theme)
            _buildHeroTile(
              context,
              title: "Receive Money",
              subtitle: "Record cash or bank payments from customers",
              icon: Icons.payments_outlined,
              themeColor: receiveTheme,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),

            // 8x2 Soft Wide Tile: Purchase (Matches the Bank tiles perfectly)
            _buildSoftWideTile(
              context,
              title: "Purchase",
              subtitle: "Record buying supplies, equipment, or assets",
              icon: Icons.shopping_bag_outlined,
              themeColor: outflowTheme,
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),

            // 4x2 Row: Bank Actions (Matches Purchase)
            Row(
              children: [
                Expanded(
                  child: _buildGridTile(
                    context,
                    title: "Deposit\nto Bank",
                    icon: Icons.account_balance_outlined,
                    themeColor: outflowTheme,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridTile(
                    context,
                    title: "Withdraw\nFrom Bank",
                    icon: Icons.account_balance_wallet_outlined,
                    themeColor: outflowTheme,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(height: 1),
            ),

            // ==========================================
            // SECTION 2: INVENTORY (Indigo Theme)
            // ==========================================
            _buildSectionHeader("INVENTORY & PRODUCTION", inventoryTheme),

            // 4x2 Row
            Row(
              children: [
                Expanded(
                  child: _buildGridTile(
                    context,
                    title: "Acquire\nRaw Material",
                    icon: Icons.widgets_outlined,
                    themeColor: inventoryTheme,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGridTile(
                    context,
                    title: "Produce\nFinished Goods",
                    icon: Icons.inventory_2_outlined,
                    themeColor: inventoryTheme,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0),
              child: Divider(height: 1),
            ),

            // ==========================================
            // SECTION 3: OTHER ACTIONS (Grey Theme)
            // ==========================================
            _buildSectionHeader("OTHER ACTIONS", labelTheme),

            _buildListTile(
              context,
              title: "Pay your Debt",
              subtitle: "Pay off an existing loan or liability",
              icon: Icons.credit_score,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildListTile(
              context,
              title: "Lend Money",
              subtitle: "Provide a loan or advance to someone",
              icon: Icons.handshake_outlined,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildListTile(
              context,
              title: "Settle Operations",
              subtitle: "Pay rent, salaries, utilities, etc.",
              icon: Icons.storefront,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildListTile(
              context,
              title: "Fund Marketing",
              subtitle: "Pay for ads and promotions",
              icon: Icons.campaign_outlined,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildListTile(
              context,
              title: "Remit Taxes",
              subtitle: "Pay government tax dues",
              icon: Icons.receipt_long_outlined,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildListTile(
              context,
              title: "Record Other Expense",
              subtitle: "Bank fees or miscellaneous costs",
              icon: Icons.more_horiz,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),
            _buildListTile(
              context,
              title: "Refund to Customers",
              subtitle: "Return money for returned goods",
              icon: Icons.assignment_return_outlined,
              themeColor: otherTheme,
              onTap: () => Navigator.pop(context),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  Widget _buildSectionHeader(String title, Color themeColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: themeColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // THE HERO TILE (8x2 Concept) - Deep Shade for Receive Money
  Widget _buildHeroTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEW: THE SOFT WIDE TILE (8x2 Concept) - Matches Bank Tiles for Purchase
  Widget _buildSoftWideTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeColor.shade50, // Matches GridTile exactly
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                Icon(icon, color: themeColor.shade700, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor.shade900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: themeColor.shade700,
                        ),
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

  // THE GRID TILES (4x2 Concept) - Soft Shade
  Widget _buildGridTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: themeColor.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(icon, color: themeColor.shade700, size: 30),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: themeColor.shade300,
                      size: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: themeColor.shade900,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // THE LIST TILES (8x1 Concept) - Clean & Uniform
  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required MaterialColor themeColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: themeColor.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: themeColor.shade700, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';
import '../../core/widgets/feature_card.dart'; // Import the reusable widget
import 'category_detail_screen.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  static int _countForCategory(List<LedgerEntry> entries, int categoryId) {
    return entries
        .where(
          (e) => e.category.parent == categoryId || e.category.id == categoryId,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<List<LedgerEntry>>(
          stream: appDb.ledgerDao.watchLedgerEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                  strokeWidth: 2,
                ),
              );
            }

            final entries = snapshot.data ?? [];

            // Define your categories metadata
            final categories = [
              {
                'id': 1,
                'name': 'Assets',
                'icon': Icons.account_balance_outlined,
              },
              {
                'id': 2,
                'name': 'Liabilities',
                'icon': Icons.credit_card_outlined,
              },
              {
                'id': 3,
                'name': "Owner's Equity",
                'icon': Icons.pie_chart_outline,
              },
              {'id': 4, 'name': 'Revenue', 'icon': Icons.trending_up_outlined},
              {
                'id': 5,
                'name': 'Expenses',
                'icon': Icons.trending_down_outlined,
              },
            ];

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final id = cat['id'] as int;
                final title = cat['name'] as String;
                final count = _countForCategory(entries, id);

                // Using the reusable FeatureCard instead of a local method
                return FeatureCard(
                  title: title,
                  subtitle: '$count ${count == 1 ? 'account' : 'accounts'}',
                  icon: cat['icon'] as IconData,
                  isFullWidth: true, // This ensures the list-style layout
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryDetailScreen(
                          categoryId: id,
                          categoryName: title,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

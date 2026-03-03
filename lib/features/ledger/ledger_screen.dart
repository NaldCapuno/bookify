import 'package:flutter/material.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/ledger_dao.dart';
import 'package:bookkeeping/core/widgets/feature_card.dart';
import 'package:bookkeeping/core/services/walkthrough_service.dart';
import 'category_detail_screen.dart';

class LedgerScreen extends StatefulWidget {
  final int selectedIndex;
  final int myIndex;

  const LedgerScreen({
    super.key,
    required this.selectedIndex,
    required this.myIndex,
  });

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  final GlobalKey _assetsKey = GlobalKey();
  final GlobalKey _liabilitiesKey = GlobalKey();
  final GlobalKey _equityKey = GlobalKey();
  final GlobalKey _revenueKey = GlobalKey();
  final GlobalKey _expensesKey = GlobalKey();
  bool _hasShownTour = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartLedgerTour();
    });
  }

  @override
  void didUpdateWidget(covariant LedgerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.myIndex && !_hasShownTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartLedgerTour();
      });
    }
  }

  void _maybeStartLedgerTour() {
    if (!mounted || _hasShownTour || widget.selectedIndex != widget.myIndex) {
      return;
    }
    _hasShownTour = true;
    WalkthroughService.showLedgerTour(
      context,
      assetsKey: _assetsKey,
      liabilitiesKey: _liabilitiesKey,
      equityKey: _equityKey,
      revenueKey: _revenueKey,
      expensesKey: _expensesKey,
    );
  }

  Key? _keyForIndex(int index) {
    switch (index) {
      case 0:
        return _assetsKey;
      case 1:
        return _liabilitiesKey;
      case 2:
        return _equityKey;
      case 3:
        return _revenueKey;
      case 4:
        return _expensesKey;
      default:
        return null;
    }
  }

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
      body: SafeArea(
        child: StreamBuilder<List<LedgerEntry>>(
          stream: appDb.ledgerDao.watchLedgerEntries(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  strokeWidth: 2,
                ),
              );
            }

            final entries = snapshot.data ?? [];

            // Schedule tour after list is built (key must be attached)
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _maybeStartLedgerTour();
            });

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
                  key: _keyForIndex(index),
                  title: title,
                  subtitle: '$count ${count == 1 ? 'account' : 'accounts'}',
                  icon: cat['icon'] as IconData,
                  isFullWidth: true,
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

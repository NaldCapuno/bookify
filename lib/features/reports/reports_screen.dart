import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/feature_card.dart';
import 'package:bookkeeping/core/services/walkthrough_service.dart';

class ReportsScreen extends StatefulWidget {
  final Function(int) onFeatureTap;
  final int selectedIndex;
  final int myIndex;

  const ReportsScreen({
    super.key,
    required this.onFeatureTap,
    required this.selectedIndex,
    required this.myIndex,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final GlobalKey _incomeStatementKey = GlobalKey();
  final GlobalKey _balanceSheetKey = GlobalKey();
  final GlobalKey _cashFlowKey = GlobalKey();
  bool _hasShownTour = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartReportsTour();
    });
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.myIndex && !_hasShownTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartReportsTour();
      });
    }
  }

  void _maybeStartReportsTour() {
    if (!mounted || _hasShownTour || widget.selectedIndex != widget.myIndex) {
      return;
    }
    _hasShownTour = true;
    WalkthroughService.showReportsTour(
      context,
      incomeStatementKey: _incomeStatementKey,
      balanceSheetKey: _balanceSheetKey,
      cashFlowKey: _cashFlowKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FeatureCard(
          key: _incomeStatementKey,
          title: 'Income Statement',
          subtitle: 'Revenue, expenses, and net profit',
          icon: Icons.auto_graph_outlined,
          onTap: () => Navigator.pushNamed(context, '/income-statement'),
        ),
        FeatureCard(
          key: _balanceSheetKey,
          title: 'Balance Sheet',
          subtitle: 'Assets & liabilities snapshot',
          icon: Icons.account_balance_outlined,
          onTap: () => Navigator.pushNamed(context, '/balance-sheet'),
        ),
        FeatureCard(
          key: _cashFlowKey,
          title: 'Cash Flow',
          subtitle: 'Cash inflows and outflows',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => Navigator.pushNamed(context, '/cash-flow'),
        ),
      ],
    );
  }
}

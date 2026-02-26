import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart'; // Import your new widget

class ReportsScreen extends StatelessWidget {
  final Function(int) onFeatureTap;

  const ReportsScreen({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        FeatureCard(
          title: 'Income Statement',
          subtitle: 'Revenue, expenses, and net profit',
          icon: Icons.auto_graph_outlined,
          onTap: () => Navigator.pushNamed(context, '/income-statement'),
        ),
        FeatureCard(
          title: 'Balance Sheet',
          subtitle: 'Assets & liabilities snapshot',
          icon: Icons.account_balance_outlined,
          onTap: () => Navigator.pushNamed(context, '/balance-sheet'),
        ),
        FeatureCard(
          title: 'Cash Flow',
          subtitle: 'Cash inflows and outflows',
          icon: Icons.account_balance_wallet_outlined,
          onTap: () => Navigator.pushNamed(context, '/cash-flow'),
        ),
      ],
    );
  }
}

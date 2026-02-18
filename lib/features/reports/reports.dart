import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Removed Scaffold (MainNavigation handles this)
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        // 2. Changed 'iconColor' to 'color'
        FeatureCard(
          title: 'Income Statement',
          subtitle: 'Profit & loss report',
          icon: Icons.trending_up,
          color: Colors.green, // Fixed here
        ),
        SizedBox(height: 12), // Added spacing for better looks
        FeatureCard(
          title: 'Balance Sheet',
          subtitle: 'Assets & liabilities',
          icon: Icons.balance_outlined,
          color: Colors.orangeAccent, // Fixed here
        ),
        SizedBox(height: 12),
        FeatureCard(
          title: 'Cash Flow',
          subtitle: 'Cash movement analysis',
          icon: Icons.attach_money_outlined,
          color: Colors.teal, // Fixed here
        ),
      ],
    );
  }
}

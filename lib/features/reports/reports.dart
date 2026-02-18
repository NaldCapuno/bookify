import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          FeatureCard(
            title: 'Income Statement',
            subtitle: 'Profit & loss report',
            icon: Icons.trending_up,
            iconColor: Colors.green,
          ),
          FeatureCard(
            title: 'Balance Sheet',
            subtitle: 'Assets & liabilities',
            icon: Icons.balance_outlined,
            iconColor: Colors.orangeAccent,
          ),
          FeatureCard(
            title: 'Cash Flow',
            subtitle: 'Cash movement analysis',
            icon: Icons.attach_money_outlined,
            iconColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}

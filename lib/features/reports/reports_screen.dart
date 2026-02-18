import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart';

class ReportsScreen extends StatelessWidget {
  final Function(int) onFeatureTap;

  const ReportsScreen({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FeatureCard(
          title: 'Income Statement',
          subtitle: 'Profit & loss report',
          icon: Icons.trending_up,
          color: Colors.green,
          onTap: () => onFeatureTap(5),
        ),

        const SizedBox(height: 12),
        FeatureCard(
          title: 'Balance Sheet',
          subtitle: 'Assets & liabilities',
          icon: Icons.balance_outlined,
          color: Colors.orangeAccent,
          onTap: () => onFeatureTap(6),
        ),

        const SizedBox(height: 12),
        FeatureCard(
          title: 'Cash Flow',
          subtitle: 'Cash movement analysis',
          icon: Icons.attach_money_outlined,
          color: Colors.teal,
          onTap: () => onFeatureTap(7),
        ),
      ],
    );
  }
}

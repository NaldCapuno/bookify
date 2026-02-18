import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),
          _buildWelcomeBanner(),
          const SizedBox(height: 24),
          const FeatureCard(
            title: 'Journal',
            subtitle: 'Record daily transactions',
            icon: Icons.menu_book_outlined,
            iconColor: Colors.blue,
          ),
          const FeatureCard(
            title: 'Ledger',
            subtitle: 'View account summaries',
            icon: Icons.description_outlined,
            iconColor: Colors.purple,
          ),
          const FeatureCard(
            title: 'Income Statement',
            subtitle: 'Profit & loss report',
            icon: Icons.trending_up,
            iconColor: Colors.green,
          ),
          const FeatureCard(
            title: 'Balance Sheet',
            subtitle: 'Assets & liabilities',
            icon: Icons.balance_outlined,
            iconColor: Colors.orangeAccent,
          ),
          const FeatureCard(
            title: 'Cash Flow',
            subtitle: 'Cash movement analysis',
            icon: Icons.attach_money_outlined,
            iconColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF232D3F),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              'KL',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back, Kenrick!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.business_center_outlined,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'No business set',
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

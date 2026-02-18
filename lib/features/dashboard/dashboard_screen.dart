import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onFeatureTap;

  const DashboardScreen({super.key, required this.onFeatureTap});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildWelcomeBanner(),

        const SizedBox(height: 24),
        FeatureCard(
          title: 'Journal',
          subtitle: 'Record daily transactions',
          icon: Icons.menu_book_outlined,
          color: Colors.blue,
          onTap: () => onFeatureTap(1),
        ),

        const SizedBox(height: 12),
        FeatureCard(
          title: 'Ledger',
          subtitle: 'View account summaries',
          icon: Icons.description_outlined,
          color: Colors.purple,
          onTap: () => onFeatureTap(2),
        ),

        const SizedBox(height: 12),
        FeatureCard(
          title: 'Reports',
          subtitle: 'Analyze your finances',
          icon: Icons.analytics_outlined,
          color: Colors.green,
          onTap: () => onFeatureTap(3),
        ),
      ],
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

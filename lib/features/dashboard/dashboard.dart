import 'package:flutter/material.dart';
import '../../core/widgets/feature_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Corrected ListView structure
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _buildWelcomeBanner(),

        const SizedBox(height: 24),

        // --- Journal ---
        const FeatureCard(
          title: 'Journal',
          subtitle: 'Record daily transactions',
          icon: Icons.menu_book_outlined,
          color: Colors
              .blue, // Changed from iconColor to color to match FeatureCard widget
          // Add onTap if needed: onTap: () => Navigator.pushNamed(context, '/journal'),
        ),

        const SizedBox(height: 12), // Add spacing between cards
        // --- Ledger ---
        const FeatureCard(
          title: 'Ledger',
          subtitle: 'View account summaries',
          icon: Icons.description_outlined,
          color: Colors.purple,
        ),

        const SizedBox(height: 12),

        // --- Income Statement ---
        const FeatureCard(
          title: 'Income Statement',
          subtitle: 'Profit & loss report',
          icon: Icons.trending_up,
          color: Colors.green,
        ),

        const SizedBox(height: 12),

        // --- Balance Sheet ---
        const FeatureCard(
          title: 'Balance Sheet',
          subtitle: 'Assets & liabilities',
          icon: Icons.balance_outlined,
          color: Colors.orangeAccent,
        ),

        const SizedBox(height: 12),

        // --- Cash Flow ---
        const FeatureCard(
          title: 'Cash Flow',
          subtitle: 'Cash movement analysis',
          icon: Icons.attach_money_outlined,
          color: Colors.teal,
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

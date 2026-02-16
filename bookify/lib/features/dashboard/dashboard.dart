import 'package:flutter/material.dart';

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final String path;
  final List<Color> gradient;

  FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.path,
    required this.gradient,
  });
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock user data (Replace with your Auth Provider logic)
    final String userName = "John Doe";
    final String initials = "JD";

    final List<FeatureItem> features = [
      FeatureItem(
        icon: Icons.book_outlined,
        title: 'Journal',
        description: 'Record daily transactions',
        path: '/journal',
        gradient: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)], // blue-50 to blue-100
      ),
      FeatureItem(
        icon: Icons.description_outlined,
        title: 'Ledger',
        description: 'View account summaries',
        path: '/ledger',
        gradient: [
          Color(0xFFFAF5FF),
          Color(0xFFF3E8FF),
        ], // purple-50 to purple-100
      ),
      FeatureItem(
        icon: Icons.trending_up,
        title: 'Income Statement',
        description: 'Profit & loss report',
        path: '/income-statement',
        gradient: [
          Color(0xFFF0FDF4),
          Color(0xFFDCFCE7),
        ], // green-50 to green-100
      ),
      FeatureItem(
        icon: Icons.balance,
        title: 'Balance Sheet',
        description: 'Assets & liabilities',
        path: '/balance-sheet',
        gradient: [
          Color(0xFFFFF7ED),
          Color(0xFFFFEDD5),
        ], // orange-50 to orange-100
      ),
      FeatureItem(
        icon: Icons.attach_money,
        title: 'Cash Flow',
        description: 'Cash movement analysis',
        path: '/cash-flow',
        gradient: [Color(0xFFF0FDFA), Color(0xFFCCFBF1)], // teal-50 to teal-100
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Dashboard', style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- Welcome Section ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF111827),
                    Color(0xFF374151),
                  ], // gray-900 to gray-700
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back, ${userName.split(' ')[0]}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(
                              Icons.business_center_outlined,
                              color: Colors.grey,
                              size: 16,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'No business set',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // --- Feature Grid ---
            GridView.builder(
              shrinkWrap:
                  true, // Important for use inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 160, // Height of the cards
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                final item = features[index];
                return FeatureCard(item: item);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final FeatureItem item;

  const FeatureCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, item.path),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: item.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: Colors.blueGrey[800]),
            ),
            const Spacer(),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.description,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

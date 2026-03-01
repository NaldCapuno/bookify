import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<OnboardingData> _pages(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      OnboardingData(
        title: "Welcome to TsekBooks",
        desc: "An easy-to-use bookkeeping app designed for your business needs.",
        image: 'assets/images/logo.png',
        color: colorScheme.primary,
      ),
      OnboardingData(
        title: "Track Your Finances",
        desc:
            "Monitor your Assets, Liabilities, and Equity with real-time reports.",
        icon: Icons.bar_chart_outlined,
        color: colorScheme.tertiary,
      ),
      OnboardingData(
        title: "Secure & Offline",
        desc:
            "Your data stays on your device. Private, secure, and always accessible.",
        icon: Icons.security_outlined,
        color: colorScheme.primary,
      ),
    ];
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Top Skip Button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _completeOnboarding,
                child: Text(
                  "SKIP",
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Middle Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _pages(context).length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages(context)[index]);
                },
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Builder(
                builder: (ctx) {
                  final pages = _pages(ctx);
                  return Column(
                    children: [
                      // Page Indicators (Dots)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          pages.length,
                          (index) => _buildDot(ctx, index),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Next / Get Started Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage == pages.length - 1) {
                              _completeOnboarding();
                            } else {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentPage == pages.length - 1
                                ? "GET STARTED"
                                : "NEXT",
                            style: theme.textTheme.labelLarge!.copyWith(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Show Image if imagePath is provided
          if (data.image != null) ...[
            Image.asset(
              data.image!,
              height: 200, // Adjust size as needed for your logo
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
          ]
          // 2. Otherwise show Icon if available
          else if (data.icon != null) ...[
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: data.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(data.icon, size: 100, color: data.color),
            ),
            const SizedBox(height: 40),
          ],

          Text(
            data.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 16),
          Text(
            data.desc,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(BuildContext context, int index) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? colorScheme.primary
            : colorScheme.outline.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String desc;
  final IconData? icon;
  final String? image;
  final Color color;

  OnboardingData({
    required this.title,
    required this.desc,
    this.icon,
    this.image,
    required this.color,
  });
}

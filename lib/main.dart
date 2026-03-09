import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookkeeping/core/services/theme_service.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/features/splash_screen/splash_screen.dart';
import 'package:bookkeeping/main_navigation.dart';
import 'package:bookkeeping/features/profile/profile_screen.dart';
import 'package:bookkeeping/features/settings/settings_screen.dart';
import 'package:bookkeeping/features/incomestatement/incomestatement_screen.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet_screen.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_screen.dart';
import 'package:bookkeeping/features/onboarding/onboarding_screen.dart';
import 'package:bookkeeping/features/userguide/user_guide_screen.dart';
import 'package:bookkeeping/features/userguide/about_us_screen.dart';
import 'package:bookkeeping/core/widgets/unfocus_on_tap_outside.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;
  await ThemeService.instance.init();

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;

  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode,
          builder: (context, child) =>
              UnfocusOnTapOutside(child: child ?? const SizedBox.shrink()),
          initialRoute: onboardingComplete ? '/' : '/onboarding',
          routes: {
            '/onboarding': (context) => const OnboardingScreen(),
            '/': (context) => const SplashScreen(),
            '/home': (context) => const MainNavigation(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/income-statement': (context) => const IncomeStatementScreen(),
            '/balance-sheet': (context) => const BalanceSheetScreen(),
            '/cash-flow': (context) => const CashFlowStatementScreen(),
            '/user-guide': (context) => const UserGuideScreen(),
            '/about-us': (context) => const AboutUsScreen(),
          },
        );
      },
    );
  }
}

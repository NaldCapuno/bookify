import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bookkeeping/features/splash_screen/splash_screen.dart';
import 'package:bookkeeping/main_navigation.dart';
import 'package:bookkeeping/features/profile/profile_screen.dart';
import 'package:bookkeeping/features/settings/settings_screen.dart';
import 'package:bookkeeping/features/incomestatement/incomestatement_screen.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet_screen.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_screen.dart';
import 'package:bookkeeping/features/onboarding/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  runApp(MyApp(onboardingComplete: onboardingComplete));
}

class MyApp extends StatelessWidget {
  final bool onboardingComplete;

  // 4. Update constructor to receive the flag
  const MyApp({super.key, required this.onboardingComplete});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F4F7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF2F4F7),
          elevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF1A1C1E),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Color(0xFF1A1C1E)),
        ),
      ),
      // 5. If onboarding is complete, start with Splash, otherwise go to Onboarding
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
      },
    );
  }
}


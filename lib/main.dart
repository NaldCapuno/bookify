import 'package:flutter/material.dart';
// import 'package:bookkeeping/features/splash_screen/splash_screen.dart';
import 'package:bookkeeping/main_navigation.dart';
import 'package:bookkeeping/features/profile/profile_screen.dart';
import 'package:bookkeeping/features/settings/settings_screen.dart';
import 'package:bookkeeping/features/incomestatement/incomestatement_screen.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet_screen.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      initialRoute: '/',
      routes: {
        // '/splash': (context) => const SplashScreen(),
        '/': (context) => const MainNavigation(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/income-statement': (context) => const IncomeStatementScreen(),
        '/balance-sheet': (context) => const BalanceSheetScreen(),
        '/cash-flow': (context) => const CashFlowScreen(),
      },
    );
  }
}

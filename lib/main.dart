import 'package:bookkeeping/main_navigation.dart';
import 'package:bookkeeping/features/login/login.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/features/journal/journal.dart';
import 'package:bookkeeping/features/ledger/ledger.dart';
import 'package:bookkeeping/features/reports/reports.dart';
import 'package:bookkeeping/features/profile/profile.dart';
import 'package:bookkeeping/features/settings/settings.dart';
import 'package:bookkeeping/features/signup/signup_screen.dart';

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
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/signin': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigation(),
        '/journal': (context) => const JournalScreen(),
        '/ledger': (context) => const LedgerScreen(),
        '/reports': (context) => const ReportsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}

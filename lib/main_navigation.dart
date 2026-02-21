import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:bookkeeping/core/widgets/navbar.dart';
import 'package:bookkeeping/features/dashboard/dashboard_screen.dart';
import 'package:bookkeeping/features/journal/journal_screen.dart';
import 'package:bookkeeping/features/ledger/ledger_screen.dart';
import 'package:bookkeeping/features/reports/reports_screen.dart';
import 'package:bookkeeping/features/accounts/accounts_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    'Dashboard',
    'Journal',
    'Ledger',
    'Reports',
    'Accounts',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _titles[_selectedIndex],
        onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardScreen(onFeatureTap: _onItemTapped),
          const JournalScreen(),
          const LedgerScreen(),
          ReportsScreen(onFeatureTap: _onItemTapped),
          const AccountsScreen(),
        ],
      ),

      bottomNavigationBar: CustomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

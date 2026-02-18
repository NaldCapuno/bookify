import 'package:flutter/material.dart';
import 'package:bookkeeping/features/dashboard/dashboard_screen.dart';
import 'package:bookkeeping/features/journal/journal_screen.dart';
import 'package:bookkeeping/features/ledger/ledger_screen.dart';
import 'package:bookkeeping/features/reports/reports_screen.dart';
import 'package:bookkeeping/features/profile/profile_screen.dart';
import 'package:bookkeeping/features/settings/settings_screen.dart';
import 'package:bookkeeping/features/incomestatement/incomestatement_screen.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet_screen.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_screen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSettingsTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onSettingsTap,
    this.showBackButton = false,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 1,

      automaticallyImplyLeading: false,

      leading: showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBackTap)
          : null,

      actions: [
        if (!showBackButton)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsTap,
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isSettingsOpen = false;

  final List<String> _titles = [
    'Dashboard',
    'Journal',
    'Ledger',
    'Reports',
    'Profile',
    'Income Statement',
    'Balance Sheet',
    'Cash Flow',
  ];

  List<Widget> get _screens => [
    DashboardScreen(onFeatureTap: _onItemTapped),
    const JournalScreen(),
    const LedgerScreen(),
    ReportsScreen(onFeatureTap: _onItemTapped),
    const ProfileScreen(),
    const IncomeStatementScreen(),
    const BalanceSheetScreen(),
    const CashFlowScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _isSettingsOpen = false;
      _selectedIndex = index;
    });
  }

  void _openSettings() {
    setState(() {
      _isSettingsOpen = true;
    });
  }

  void _closeSettings() {
    setState(() {
      _isSettingsOpen = false;
    });
  }

  bool get _isSubReport => _selectedIndex >= 5;

  @override
  Widget build(BuildContext context) {
    bool canPopInternally = _isSettingsOpen || _isSubReport;

    return PopScope(
      canPop: !canPopInternally,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_isSettingsOpen) {
          _closeSettings();
        } else if (_isSubReport) {
          _onItemTapped(3);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _isSettingsOpen ? "Settings" : _titles[_selectedIndex],
          onSettingsTap: _openSettings,
          showBackButton: _isSettingsOpen || _isSubReport,
          onBackTap: () {
            if (_isSettingsOpen) {
              _closeSettings();
            } else if (_isSubReport) {
              _onItemTapped(3);
            }
          },
        ),

        body: _isSettingsOpen
            ? const SettingsScreen()
            : IndexedStack(index: _selectedIndex, children: _screens),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex > 4 ? 3 : _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF2F4F7),
          selectedItemColor: _isSettingsOpen
              ? Colors.grey
              : const Color(0xFF1A1C1E),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Journal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.description_outlined),
              activeIcon: Icon(Icons.description),
              label: 'Ledger',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Reports',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

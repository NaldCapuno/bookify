import 'package:flutter/material.dart';

// 1. Import your Custom AppBar
import '/core/widgets/appbar.dart';

// 2. Import your Screens
import '/features/dashboard/dashboard.dart';
import '/features/journal/journal.dart';
import '/features/ledger/ledger.dart';
import '/features/reports/reports.dart';
import '/features/profile/profile.dart';
import '/features/settings/settings.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _isSettingsOpen = false;

  // List of titles corresponding to each tab index
  final List<String> _titles = [
    'Dashboard', // Index 0
    'Journal', // Index 1
    'Ledger', // Index 2
    'Reports', // Index 3
    'Profile', // Index 4
  ];

  // List of Screens corresponding to each tab index
  final List<Widget> _screens = [
    const DashboardScreen(),
    const JournalScreen(),
    const LedgerScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _isSettingsOpen = false; // Close settings if we tap a bottom tab
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ---------------------------------------------------------
      // 1. HERE IS YOUR APP BAR
      // It updates dynamically based on the selected tab or settings state
      // ---------------------------------------------------------
      appBar: CustomAppBar(
        title: _isSettingsOpen ? "Settings" : _titles[_selectedIndex],
        onSettingsTap: _openSettings,
        showBackButton: _isSettingsOpen,
        onBackTap: _closeSettings,
      ),

      // ---------------------------------------------------------
      // 2. HERE IS THE BODY (THE CONTENT)
      // If settings is open, show settings. Otherwise, show the active tab.
      // ---------------------------------------------------------
      body: _isSettingsOpen
          ? const SettingsScreen()
          : IndexedStack(index: _selectedIndex, children: _screens),

      // ---------------------------------------------------------
      // 3. HERE IS YOUR BOTTOM NAVIGATION
      // ---------------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed, // Needed for 4+ items
        backgroundColor: const Color(0xFFF2F4F7), // Match your theme
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
    );
  }
}

import 'package:flutter/material.dart';
import '/features/dashboard/dashboard.dart';
import '/features/journal/journal.dart';
import '/features/ledger/ledger.dart';
import '/features/reports/reports.dart';
import '/features/profile/profile.dart';
import '/features/settings/settings.dart';

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

      leading: IconButton(
        icon: Icon(showBackButton ? Icons.arrow_back : Icons.menu),
        onPressed: showBackButton ? onBackTap : () {},
      ),

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
  ];

  final List<Widget> _screens = [
    const DashboardScreen(),
    const JournalScreen(),
    const LedgerScreen(),
    const ReportsScreen(),
    const ProfileScreen(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isSettingsOpen ? "Settings" : _titles[_selectedIndex],
        onSettingsTap: _openSettings,
        showBackButton: _isSettingsOpen,
        onBackTap: _closeSettings,
      ),

      body: _isSettingsOpen
          ? const SettingsScreen()
          : IndexedStack(index: _selectedIndex, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
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
    );
  }
}

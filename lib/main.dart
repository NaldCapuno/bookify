import 'package:flutter/material.dart';
import 'features/dashboard/dashboard.dart';
import 'features/journal/journal.dart';
import 'features/ledger/ledger.dart';
import 'features/reports/reports.dart';
import 'features/profile/profile.dart';
import 'features/settings/settings.dart';

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
      home: const MainNavigation(),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSettingsTap;
  final bool showBackButton;
  final VoidCallback onBackTap;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onSettingsTap,
    this.showBackButton = false,
    required this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: IconButton(
        icon: Icon(showBackButton ? Icons.arrow_back : Icons.menu),
        onPressed: showBackButton ? onBackTap : () {},
      ),
      actionsPadding: const EdgeInsets.only(right: 12),
      actions: [
        if (!showBackButton)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: onSettingsTap,
          ),
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

  final PageController _pageController = PageController();

  final List<String> _titles = [
    'Dashboard',
    'Journal',
    'Ledger',
    'Reports',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _isSettingsOpen = false;
      _selectedIndex = index;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(index);
      }
    });
  }

  void _openSettings() {
    setState(() {
      _isSettingsOpen = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isSettingsOpen ? "Settings" : _titles[_selectedIndex],
        onSettingsTap: _openSettings,
        showBackButton: _isSettingsOpen,
        onBackTap: () {
          setState(() {
            _isSettingsOpen = false;
          });
        },
      ),
      body: _isSettingsOpen
          ? const SettingsScreen()
          : PageView(
              key: ValueKey(_selectedIndex),
              controller: PageController(initialPage: _selectedIndex),
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              children: [
                const DashboardScreen(),
                const JournalScreen(),
                const LedgerScreen(),
                const ReportsScreen(),
                const ProfileScreen(),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _isSettingsOpen
            ? Colors.grey
            : const Color(0xFF232D3F),
        unselectedItemColor: Colors.grey,
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:bookkeeping/core/widgets/navbar.dart';
import 'package:bookkeeping/features/dashboard/dashboard_screen.dart';
import 'package:bookkeeping/features/journal/journal_screen.dart';
import 'package:bookkeeping/features/ledger/ledger_screen.dart';
import 'package:bookkeeping/features/reports/reports_screen.dart';
import 'package:bookkeeping/features/accounts/accounts_screen.dart';

import 'package:bookkeeping/features/profile/user_service.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/users_dao.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late final UserService _userService;
  String _userInitials = '';

  final List<String> _titles = [
    'Dashboard',
    'Journal',
    'Ledger',
    'Reports',
    'Accounts',
  ];

  @override
  void initState() {
    super.initState();
    _userService = UserService(UsersDao(appDb));
    _loadUserInitials();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserInitials() async {
    final user = await _userService.getUserProfile();
    if (user != null && mounted) {
      setState(() {
        _userInitials = _getInitials(user.username);
      });
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '';
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length >= 2) {
      return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
    } else if (nameParts.isNotEmpty && nameParts.first.isNotEmpty) {
      return nameParts.first[0].toUpperCase();
    }
    return '';
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _navigateToProfile() async {
    await Navigator.pushNamed(context, '/profile');
    _loadUserInitials();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _selectedIndex = 0;
        });
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _titles[_selectedIndex],
          userInitials: _userInitials,
          onProfileTap: _navigateToProfile,
          onSettingsTap: () => Navigator.pushNamed(context, '/settings'),
          onUserGuideTap: () => Navigator.pushNamed(context, '/user-guide'),
          onAboutUsTap: () => Navigator.pushNamed(context, '/about-us'),
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
      ),
    );
  }
}
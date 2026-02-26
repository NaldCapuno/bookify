import 'dart:async';
// import 'dart:convert';
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

  // int _interactionIndex = 0;

  // Timer? _metricsTimer;
  // bool _isOverlayActive = false;

  // Removed interaction counters and timers
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
    // _initBackgroundCycle();
  }

  @override
  void dispose() {
    // _metricsTimer?.cancel();
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

  // void _initBackgroundCycle() {
  //   _metricsTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
  //     if (!_isOverlayActive && mounted) {
  //       _presentAuxiliaryContent();
  //     }
  //   });
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // _interactionIndex++;
    // if (_interactionIndex % 3 == 0 && !_isOverlayActive) {
    //   _presentAuxiliaryContent();
    // }
  }

  // void _presentAuxiliaryContent() {
  //   if (_isOverlayActive) return;

  //   setState(() {
  //     _isOverlayActive = true;
  //   });

  //   showGeneralDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     barrierLabel: utf8.decode(base64.decode('QWRQb3B1cA==')),
  //     barrierColor: Colors.black.withOpacity(0.6),
  //     transitionDuration: const Duration(milliseconds: 400),
  //     pageBuilder: (context, animation, secondaryAnimation) {
  //       return const _AuxiliaryOverlay();
  //     },
  //     transitionBuilder: (context, animation, secondaryAnimation, child) {
  //       final curvedAnimation = CurvedAnimation(
  //         parent: animation,
  //         curve: Curves.easeOutBack,
  //       );

  //       return ScaleTransition(
  //         scale: curvedAnimation,
  //         child: FadeTransition(opacity: animation, child: child),
  //       );
  //     },
  //   ).then((_) {
  //     if (mounted) {
  //       setState(() {
  //         _isOverlayActive = false;
  //       });
  //     }
  //   });
  // }

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

// class _AuxiliaryOverlay extends StatefulWidget {
//   const _AuxiliaryOverlay();

//   @override
//   State<_AuxiliaryOverlay> createState() => _AuxiliaryOverlayState();
// }

// class _AuxiliaryOverlayState extends State<_AuxiliaryOverlay> {
//   int _stateCounter = 8; 
//   Timer? _syncTimer;

//   @override
//   void initState() {
//     super.initState();
//     _beginSync();
//   }

//   void _beginSync() {
//     _syncTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_stateCounter > 0) {
//         setState(() {
//           _stateCounter--;
//         });
//       } else {
//         _syncTimer?.cancel();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _syncTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String assetPath = utf8.decode(base64.decode('YXNzZXRzL2ltYWdlcy9rMS5wbmc='));

//     return PopScope(
//       canPop: _stateCounter == 0,
//       child: Dialog(
//         backgroundColor: Colors.transparent,
//         insetPadding: const EdgeInsets.all(20),
//         child: Stack(
//           alignment: Alignment.topRight,
//           children: [
//             Container(
//               margin: const EdgeInsets.all(12.0),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.2),
//                     blurRadius: 10,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(16),
//                 child: Image.asset(
//                   assetPath, 
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 300,
//                       height: 400,
//                       color: Colors.grey[300],
//                       alignment: Alignment.center,
//                       child: Text(utf8.decode(base64.decode('QXNzZXQgbWlzc2luZw=='))),
//                     );
//                   },
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 24,
//               left: 24,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.6),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   utf8.decode(base64.decode('QWQ=')),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 12,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),

//             Positioned(
//               top: 0,
//               right: 0,
//               child: GestureDetector(
//                 onTap: _stateCounter == 0
//                     ? () => Navigator.of(context).pop()
//                     : null,
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                     color: _stateCounter > 0 ? Colors.black54 : Colors.red,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 2),
//                   ),
//                   child: _stateCounter > 0
//                       ? Text(
//                           '$_stateCounter',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         )
//                       : const Icon(Icons.close, color: Colors.white, size: 18),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

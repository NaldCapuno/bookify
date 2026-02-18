import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onSettingsTap;
  final bool showBackButton;
  final VoidCallback? onBackTap; // Made nullable for safety

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
      centerTitle: true,
      backgroundColor: const Color(0xFFF5EFE6), // Your theme background color
      elevation: 0,

      // LOGIC: Only show back button if requested. Otherwise show nothing (or a Logo).
      leading: showBackButton
          ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: onBackTap)
          : Container(
              padding: const EdgeInsets.all(12),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.indigo,
              ), // Placeholder Logo
            ),

      actions: [
        // Only show Settings button if we are NOT in the settings screen
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

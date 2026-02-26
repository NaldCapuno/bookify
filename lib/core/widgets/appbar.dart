import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap; // Added this
  final VoidCallback? onUserGuideTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final String userInitials; // Added this

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSettingsTap,
    this.onProfileTap,
    this.onUserGuideTap,
    this.showBackButton = false,
    this.onBackTap,
    this.userInitials = '', // Default to empty
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      elevation: 1,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBackTap ?? () => Navigator.pop(context),
            )
          : null,
      actions: [
        if (!showBackButton)
          PopupMenuButton<int>(
            offset: const Offset(0, 50),
            icon: CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF232D3F),
              child: Text(
                userInitials.isNotEmpty ? userInitials : '?', // Made dynamic
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onSelected: (value) {
              if (value == 0) {
                // Use callback if provided, else fallback to direct navigation
                if (onProfileTap != null) {
                  onProfileTap!();
                } else {
                  Navigator.pushNamed(context, '/profile');
                }
              } else if (value == 1) {
                if (onSettingsTap != null) {
                  onSettingsTap!();
                } else {
                  Navigator.pushNamed(context, '/settings');
                }
              } else if (value == 2) {
                if (onUserGuideTap != null) {
                  onUserGuideTap!();
                } else {
                  Navigator.pushNamed(context, '/user-guide');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Row(
                  children: [
                    Icon(Icons.account_circle, color: Colors.black54, size: 20),
                    SizedBox(width: 10),
                    Text("Profile"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.black54, size: 20),
                    SizedBox(width: 10),
                    Text("Settings"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.black54, size: 20),
                    SizedBox(width: 10),
                    Text("User Guide"),
                  ],
                ),
              ),
            ],
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
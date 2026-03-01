import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onSettingsTap;
  final VoidCallback? onProfileTap; // Added this
  final VoidCallback? onUserGuideTap;
  final VoidCallback? onAboutUsTap;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final String userInitials; // Added this

  const CustomAppBar({
    super.key,
    required this.title,
    this.onSettingsTap,
    this.onProfileTap,
    this.onUserGuideTap,
    this.onAboutUsTap,
    this.showBackButton = false,
    this.onBackTap,
    this.userInitials = '', // Default to empty
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return AppBar(
      title: Text(title, style: theme.textTheme.headlineLarge!.copyWith(fontWeight: FontWeight.bold)),
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
              backgroundColor: colorScheme.secondary,
              child: Text(
                userInitials.isNotEmpty ? userInitials : '?',
                style: TextStyle(
                  color: colorScheme.onSecondary,
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
              } else if (value == 3) {
                if (onAboutUsTap != null) {
                  onAboutUsTap!();
                } else {
                  Navigator.pushNamed(context, '/about-us');
                }
              }
            },
            itemBuilder: (context) {
              final iconColor = theme.colorScheme.onSurface.withOpacity(0.6);
              return [
                PopupMenuItem(
                  value: 0,
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      const Text("Profile"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      const Text("Settings"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(Icons.help_outline, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      const Text("User Guide"),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: iconColor, size: 20),
                      const SizedBox(width: 10),
                      const Text("About Us"),
                    ],
                  ),
                ),
              ];
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
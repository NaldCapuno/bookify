import 'package:flutter/material.dart';

class AppFloatingActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const AppFloatingActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 2,
      // Using a heroTag is important if you use this on multiple
      // screens to avoid transition errors
      heroTag: label,
      icon: Icon(icon),
      label: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge!.copyWith(letterSpacing: 0.5),
      ),
    );
  }
}

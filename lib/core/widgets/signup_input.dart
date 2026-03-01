import 'package:flutter/material.dart';

class SignupInput extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;

  const SignupInput({
    super.key, 
    required this.label, 
    required this.hint, 
    required this.icon, 
    required this.controller,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            hintText: hint,
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 15),
            filled: true,
            fillColor: colorScheme.surfaceContainerHighest,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colorScheme.primary, width: 1),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
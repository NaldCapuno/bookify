import 'package:flutter/material.dart';

class AppToast {
  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    IconData? icon,
  }) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    scaffoldMessenger.removeCurrentSnackBar();

    final backgroundColor = isError ? colorScheme.error : colorScheme.inverseSurface;
    final foregroundColor = isError ? colorScheme.onError : colorScheme.onInverseSurface;

    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ??
                  (isError ? Icons.error_outline : Icons.check_circle_outline),
              color: foregroundColor,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.horizontal,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.025,
          left: 24,
          right: 24,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

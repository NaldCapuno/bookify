import 'package:flutter/material.dart';

class EmptyReportPlaceholder extends StatelessWidget {
  final String message;
  const EmptyReportPlaceholder({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            color: scheme.onSurfaceVariant,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ) ??
              TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class LedgerEntryCard extends StatelessWidget {
  final int accountDbId;
  final IconData icon;
  final String code;
  final String name;
  final int transactions;
  final String balance;
  final VoidCallback onTap;

  const LedgerEntryCard({
    super.key,
    required this.accountDbId,
    required this.icon,
    required this.code,
    required this.name,
    required this.transactions,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Text(
              code,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              '₱$balance',
              style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:bookkeeping/core/constants/app_insets.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:bookkeeping/core/widgets/app_confirmation_sheet.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AccountDetailsSheet extends StatelessWidget {
  final Account account;
  final NormalBalance normalBalance;

  const AccountDetailsSheet({
    super.key,
    required this.account,
    required this.normalBalance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Using the extension helper
    final warningColor = context.warning;

    final bool isDebit = normalBalance == NormalBalance.debit;
    final String balanceTag = isDebit ? 'DR' : 'CR';

    // Use warningColor instead of hardcoded Colors.orange
    final Color tagColor = isDebit ? colorScheme.tertiary : warningColor;
    final bool isArchived = account.isArchived;

    return SafeArea(
      top: false,
      child: Stack(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(
            AppInsets.formHorizontal,
            AppInsets.formTop,
            AppInsets.formHorizontal,
            AppInsets.formBottom,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Row(
                children: [
                  // DR / CR Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isArchived
                          ? colorScheme.surfaceContainerHighest
                          : tagColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isArchived
                            ? colorScheme.outlineVariant
                            : tagColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      balanceTag,
                      style: theme.textTheme.labelMedium!.copyWith(
                        color: isArchived
                            ? colorScheme.onSurfaceVariant
                            : tagColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      account.name,
                      style: theme.textTheme.headlineMedium!.copyWith(
                        color: isArchived
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (account.isLocked)
                    Icon(
                      Icons.lock_outline,
                      color: colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Account Code: ${account.code}',
                style: TextStyle(
                  color: isArchived
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurfaceVariant,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),

              _buildDetailRow(
                context,
                Icons.description_outlined,
                'Description',
                account.description ?? 'No description provided.',
                isArchived,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: colorScheme.outlineVariant),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: account.isLocked
                        ? ElevatedButton.icon(
                            onPressed: () =>
                                _handleArchiveToggle(context, warningColor),
                            icon: Icon(
                              isArchived
                                  ? Icons.unarchive_outlined
                                  : Icons.archive_outlined,
                              size: 18,
                              color: colorScheme.onPrimary,
                            ),
                            label: Text(
                              isArchived ? 'Unarchive' : 'Archive',
                              style: TextStyle(color: colorScheme.onPrimary),
                            ),
                            style: ElevatedButton.styleFrom(
                              // Uses Tertiary for Unarchive, Warning for Archive
                              backgroundColor: isArchived
                                  ? colorScheme.tertiary
                                  : warningColor,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => _handleDelete(context),
                            icon: Icon(
                              Icons.delete_forever_outlined,
                              size: 18,
                              color: colorScheme.onError,
                            ),
                            label: Text(
                              'Delete',
                              style: TextStyle(color: colorScheme.onError),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // --- THE ARCHIVE STAMP ---
        if (isArchived)
          Positioned(
            right: 40,
            top: 60,
            child: IgnorePointer(
              child: Transform.rotate(
                angle: -0.15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      // Using theme-aware warning color here
                      color: warningColor.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ARCHIVED',
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: warningColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool isArchived,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall!.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: isArchived
                ? colorScheme.onSurfaceVariant
                : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Future<void> _handleArchiveToggle(
    BuildContext context,
    Color warningColor,
  ) async {
    final newStatus = !account.isArchived;

    // Optional: show a confirmation sheet first if you want to be extra safe
    await appDb.accountsDao.archiveAccount(account.id, newStatus);

    if (context.mounted) {
      Navigator.pop(context);
      AppToast.show(
        context,
        message: newStatus
            ? 'Account archived successfully!'
            : 'Account unarchived successfully!',
      );
    }
  }

  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => AppConfirmationSheet(
        title: 'Delete Account?',
        message:
            'This will permanently remove ${account.name}. This action cannot be undone.',
        confirmLabel: 'Delete',
        confirmColor: Theme.of(context).colorScheme.error,
        icon: Icons.delete_forever_outlined,
      ),
    );

    if (confirmed == true) {
      try {
        await appDb.accountsDao.deleteAccount(account.id);
        if (context.mounted) {
          Navigator.pop(context);
          AppToast.show(context, message: 'Account deleted successfully!');
        }
      } catch (e) {
        if (context.mounted) {
          AppToast.show(
            context,
            message: 'Cannot delete: Account is in use.',
            isError: true,
          );
        }
      }
    }
  }
}

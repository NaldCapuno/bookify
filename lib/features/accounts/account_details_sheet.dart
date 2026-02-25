import 'package:flutter/material.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';

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
    final bool isDebit = normalBalance == NormalBalance.debit;
    final String balanceTag = isDebit ? 'DR' : 'CR';
    final Color tagColor = isDebit
        ? Colors.blue.shade700
        : Colors.orange.shade700;
    final bool isArchived = account.isArchived;

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    color: Colors.grey[300],
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
                          ? Colors.grey.shade100
                          : tagColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isArchived
                            ? Colors.grey.shade300
                            : tagColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      balanceTag,
                      style: TextStyle(
                        color: isArchived ? Colors.grey : tagColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      account.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isArchived ? Colors.grey : Colors.black,
                      ),
                    ),
                  ),
                  if (account.isLocked)
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.grey,
                      size: 20,
                    ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Account Code: ${account.code}',
                style: TextStyle(
                  color: isArchived ? Colors.grey.shade400 : Colors.blueGrey,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 32),

              _buildDetailRow(
                Icons.description_outlined,
                'Description',
                account.description ?? 'No description provided.',
                isArchived,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Close'),
                ),
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
                      color: Colors.orange.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'ARCHIVED',
                    style: TextStyle(
                      color: Colors.orange.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    bool isArchived,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isArchived ? Colors.grey.shade300 : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isArchived ? Colors.grey.shade300 : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            color: isArchived ? Colors.grey.shade400 : Colors.black87,
          ),
        ),
      ],
    );
  }
}

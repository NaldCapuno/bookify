import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/accounts_dao.dart';
import 'package:bookkeeping/core/widgets/app_fab.dart';
import 'package:bookkeeping/core/widgets/app_confirmation_sheet.dart';
import 'package:bookkeeping/features/accounts/account_details_sheet.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/widgets/appt_toast.dart';
import 'add_account_form.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: AppFloatingActionButton(
        label: 'Add Account',
        onPressed: () => _showAddAccountDialog(context),
      ),
      body: StreamBuilder<List<AccountRow>>(
        stream: appDb.accountsDao.watchAccountsGrouped(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('No accounts found.'));
          }

          // Grouping logic
          final Map<String, List<AccountRow>> groupedData = {};
          for (var row in data) {
            groupedData.putIfAbsent(row.category.name, () => []).add(row);
          }

          final categoryNames = groupedData.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: categoryNames.length,
            itemBuilder: (context, index) {
              final categoryName = categoryNames[index];
              final rows = groupedData[categoryName]!;

              return StickyHeader(
                header: _buildStickyHeader(categoryName),
                content: Column(
                  children: rows
                      .map((row) => _buildAccountTile(row, context))
                      .toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildStickyHeader(String title) {
    return Container(
      height: 45.0,
      width: double.infinity,
      color: const Color(0xFFF2F4F7),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.blueGrey[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountTile(AccountRow row, BuildContext context) {
    final account = row.account;
    final bool isArchived = account.isArchived;
    final bool isLocked = account.isLocked;

    // Logic for DR/CR Tag
    final bool isDebit = row.category.normalBalance == NormalBalance.debit;
    final String balanceTag = isDebit ? 'DR' : 'CR';
    final Color tagColor = isDebit
        ? Colors.blue.shade700
        : Colors.orange.shade700;

    return Stack(
      children: [
        Dismissible(
          key: ValueKey('account_${account.id}'),
          direction: isArchived
              ? DismissDirection.none
              : DismissDirection.endToStart,

          background: Container(
            color: isLocked ? Colors.orange.shade50 : Colors.red.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLocked
                      ? Icons.archive_outlined
                      : Icons.delete_forever_outlined,
                  color: isLocked
                      ? Colors.orange.shade400
                      : Colors.red.shade400,
                  size: 28,
                ),
                Text(
                  isLocked ? 'ARCHIVE' : 'DELETE',
                  style: TextStyle(
                    color: isLocked ? Colors.orange : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          confirmDismiss: (direction) async {
            if (isLocked) {
              await _showArchiveConfirmation(context, account);
            } else {
              await _showDeleteConfirmation(context, account);
            }
            return false;
          },

          child: Container(
            color: isArchived ? const Color(0xFFF8FAFC) : Colors.white,
            child: Column(
              children: [
                ListTile(
                  onTap: () => _showAccountDetails(context, row),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: Text(
                    account.code.toString(),
                    style: TextStyle(
                      color: isArchived ? Colors.grey : Colors.blueGrey,
                      fontFamily: 'monospace',
                    ),
                  ),
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: isArchived
                              ? Colors.grey.shade200
                              : tagColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isArchived
                                ? Colors.grey.shade300
                                : tagColor.withOpacity(0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          balanceTag,
                          style: TextStyle(
                            color: isArchived ? Colors.grey : tagColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          account.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isArchived ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: isArchived
                      ? null
                      : (isLocked
                            ? const Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: Colors.grey,
                              )
                            : const Icon(Icons.chevron_right, size: 20)),
                ),
                const Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFFF2F4F7),
                ),
              ],
            ),
          ),
        ),
        if (isArchived) _buildArchiveStamp(),
      ],
    );
  }

  Widget _buildArchiveStamp() {
    return Positioned(
      right: 50,
      top: 20,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.withOpacity(0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ARCHIVED',
              style: TextStyle(
                color: Colors.orange.withOpacity(0.4),
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showArchiveConfirmation(
    BuildContext context,
    Account account,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AppConfirmationSheet(
        title: 'Archive ${account.name}?',
        message:
            'Archived accounts won\'t appear in your active list but will remain in historical reports.',
        confirmLabel: 'Archive',
        confirmColor: Colors.orange.shade700,
        icon: Icons.archive_outlined,
      ),
    );

    if (result == true) {
      await appDb.accountsDao.archiveAccount(account.id, true);
      AppToast.show(context, message: 'Account archived successfully!');
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Account account,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AppConfirmationSheet(
        title: 'Delete ${account.name}?',
        message:
            'This will permanently remove the account. This cannot be undone.',
        confirmLabel: 'Delete',
        confirmColor: Colors.red.shade700,
        icon: Icons.delete_forever_outlined,
      ),
    );

    if (result == true) {
      await appDb.accountsDao.deleteAccount(account.id);
      AppToast.show(context, message: 'Account deleted successfully!');
    }
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAccountForm(),
    );
  }

  void _showAccountDetails(BuildContext context, AccountRow row) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AccountDetailsSheet(
        account: row.account,
        normalBalance: row.category.normalBalance,
      ),
    );
  }
}

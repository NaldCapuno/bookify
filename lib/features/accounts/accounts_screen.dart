import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/accounts_dao.dart';
import 'package:bookkeeping/core/widgets/app_fab.dart';
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
          if (data.isEmpty)
            return const Center(child: Text('No accounts found.'));

          final Map<String, List<AccountRow>> groupedData = {};
          for (var row in data) {
            groupedData.putIfAbsent(row.category.name, () => []).add(row);
          }

          final categoryNames = groupedData.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 80,
            ), // Extra padding so FAB doesn't cover last item
            itemCount: categoryNames.length,
            itemBuilder: (context, index) {
              final categoryName = categoryNames[index];
              final accounts = groupedData[categoryName]!;

              return StickyHeader(
                header: _buildStickyHeader(categoryName),
                content: Column(
                  children: accounts
                      .map((item) => _buildAccountTile(item.account, context))
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

  Widget _buildAccountTile(Account account, BuildContext context) {
    final bool isArchived =
        account.isArchived; // Assumes you added this to your DB

    return Stack(
      children: [
        Dismissible(
          key: ValueKey('account_${account.id}'),
          // Only allow swiping if it's NOT locked and NOT already archived
          direction: (account.isLocked || isArchived)
              ? DismissDirection.none
              : DismissDirection.endToStart,
          background: Container(
            color: Colors.orange.shade50,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.archive_outlined,
                  color: Colors.orange.shade400,
                  size: 28,
                ),
                const Text(
                  'ARCHIVE',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            bool shouldArchive = await _showArchiveConfirmation(
              context,
              account,
            );
            return false; // Always return false so the card snaps back
          },
          child: Container(
            // Fade the background if archived
            color: isArchived ? const Color(0xFFF8FAFC) : Colors.white,
            child: Column(
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  leading: Text(
                    account.code.toString(),
                    style: TextStyle(
                      color: isArchived ? Colors.grey : Colors.blueGrey,
                      fontFamily: 'monospace',
                      decoration: isArchived
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  title: Text(
                    account.name,
                    style: TextStyle(
                      color: isArchived ? Colors.grey : Colors.black,
                      decoration: isArchived
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: isArchived
                      ? null
                      : (account.isLocked
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
        // The Stamp
        if (isArchived) _buildArchiveStamp(),
      ],
    );
  }

  Widget _buildArchiveStamp() {
    return Positioned(
      right: 50,
      top: 15,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.4),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ARCHIVED',
              style: TextStyle(
                color: Colors.orange.withValues(alpha: 0.4),
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

  Future<bool> _showArchiveConfirmation(
    BuildContext context,
    Account account,
  ) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.archive_outlined,
                color: Colors.orange,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                'Archive ${account.name}?',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Archived accounts won\'t appear in your active list but will remain in historical reports.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                      ),
                      child: const Text(
                        'Archive',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (result == true) {
      await appDb.accountsDao.archiveAccount(account.id, true);
      return true;
    }
    return false;
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAccountForm(),
    );
  }
}

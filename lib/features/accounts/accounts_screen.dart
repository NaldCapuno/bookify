import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/accounts_dao.dart';
import 'add_account_form.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddAccountDialog(context);
        },
        backgroundColor: const Color(0xFF1A1C1E),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Account'),
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
                      .map((item) => _buildAccountTile(item.account))
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

  Widget _buildAccountTile(Account account) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 4,
            ),
            leading: Text(
              account.code.toString(),
              style: const TextStyle(
                color: Colors.blueGrey,
                fontFamily: 'monospace',
              ),
            ),
            title: Text(account.name),
            trailing: account.isLocked
                ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey)
                : const Icon(Icons.chevron_right, size: 20),
          ),
          const Divider(
            height: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFF2F4F7),
          ),
        ],
      ),
    );
  }

  void _showAddAccountDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Required to allow the form to move freely
      backgroundColor: Colors.transparent, // Required to see the "snap" clearly
      elevation: 0,
      builder: (context) => const AddAccountForm(),
    );
  }
}

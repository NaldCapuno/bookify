import 'package:flutter/material.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/database/daos/accounts_dao.dart';
import 'package:bookkeeping/core/widgets/app_fab.dart';
import 'package:bookkeeping/core/widgets/app_confirmation_sheet.dart';
import 'package:bookkeeping/features/accounts/account_details_sheet.dart';
import 'package:bookkeeping/core/database/tables/account_categories_table.dart';
import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/core/services/walkthrough_service.dart';
import 'add_account_form.dart';
import 'package:bookkeeping/features/accounts/account_search_header.dart';

class AccountsScreen extends StatefulWidget {
  final int selectedIndex;
  final int myIndex;

  const AccountsScreen({
    super.key,
    required this.selectedIndex,
    required this.myIndex,
  });

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  BalanceFilter _currentFilter = BalanceFilter.all;

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _listKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();
  bool _hasShownTour = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeStartAccountsTour();
    });
  }

  @override
  void didUpdateWidget(covariant AccountsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex == widget.myIndex && !_hasShownTour) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _maybeStartAccountsTour();
      });
    }
  }

  void _maybeStartAccountsTour() {
    if (!mounted || _hasShownTour || widget.selectedIndex != widget.myIndex) {
      return;
    }
    _hasShownTour = true;
    WalkthroughService.showAccountsTour(
      context,
      searchKey: _searchKey,
      listKey: _listKey,
      fabKey: _fabKey,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _hideKeyboard() {
    _searchFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Ensure the background color doesn't blend with the search bar
      backgroundColor: const Color(0xFFF8FAFC),
      floatingActionButton: AppFloatingActionButton(
        key: _fabKey,
        label: 'Add Account',
        onPressed: () => _showAddAccountDialog(context),
      ),
      body: SafeArea(
        // We use a Column to stack the search bar on top of the list
        child: Column(
          children: [
            // --- SEARCH BAR SECTION ---
            // Added a Container wrapper to ensure visibility and spacing
            Container(
              key: _searchKey,
              color: Colors.white,
              child: AccountSearchHeader(
                controller: _searchController,
                focusNode: _searchFocusNode,
                selectedFilter: _currentFilter,
                onFilterChanged: (filter) =>
                    setState(() => _currentFilter = filter),
                searchQuery: _searchQuery,
                onChanged: (value) => setState(() => _searchQuery = value),
                onClear: () {
                  _hideKeyboard();
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
            ),

            // --- LIST SECTION ---
            Expanded(
              child: StreamBuilder<List<AccountRow>>(
                stream: appDb.accountsDao.watchAccountsGrouped(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    );
                  }

                  final data = snapshot.data ?? [];

                  // Schedule tour after content is built (key must be attached)
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _maybeStartAccountsTour();
                  });

                  // Logic: If query matches Category, Name, or Code
                  final filteredData = data.where((row) {
                    final query = _searchQuery.toLowerCase();

                    // Existing Search Logic
                    final matchesSearch =
                        row.account.name.toLowerCase().contains(query) ||
                        row.account.code.toString().contains(query) ||
                        row.category.name.toLowerCase().contains(query);

                    // New Filter Logic
                    final isDebit =
                        row.category.normalBalance == NormalBalance.debit;
                    bool matchesFilter = true;
                    if (_currentFilter == BalanceFilter.dr)
                      matchesFilter = isDebit;
                    if (_currentFilter == BalanceFilter.cr)
                      matchesFilter = !isDebit;

                    return matchesSearch && matchesFilter;
                  }).toList();

                  if (filteredData.isEmpty) {
                    return Center(
                      child: Text(
                        key: _listKey,
                        _searchQuery.isEmpty
                            ? 'No accounts found.'
                            : 'No results for "$_searchQuery"',
                      ),
                    );
                  }

                  // Grouping logic remains the same
                  final Map<String, List<AccountRow>> groupedData = {};
                  for (var row in filteredData) {
                    groupedData
                        .putIfAbsent(row.category.name, () => [])
                        .add(row);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: groupedData.length,
                    itemBuilder: (context, index) {
                      final categoryName = groupedData.keys.elementAt(index);
                      final rows = groupedData[categoryName]!;

                      return StickyHeader(
                        header: _buildStickyHeader(
                          categoryName,
                          key: index == 0 ? _listKey : null,
                        ),
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
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStickyHeader(String title, {Key? key}) {
    return Container(
      key: key,
      height: 40.0,
      width: double.infinity,
      color: const Color(0xFFF2F4F7),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.blueGrey[800],
          fontWeight: FontWeight.bold,
          fontSize: 10,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildAccountTile(AccountRow row, BuildContext context) {
    final account = row.account;
    final bool isArchived = account.isArchived;
    final bool isLocked = account.isLocked;

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
                  size: 24,
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
                    vertical: 0,
                  ),
                  leading: Text(
                    account.code.toString(),
                    style: TextStyle(
                      color: isArchived ? Colors.grey : Colors.blueGrey,
                      fontFamily: 'monospace',
                      fontSize: 13,
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
                            color: isArchived ? Colors.grey : Colors.black87,
                            fontSize: 15,
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
                                size: 14,
                                color: Colors.grey,
                              )
                            : const Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Colors.grey,
                              )),
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
      top: 15,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -0.15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                fontSize: 10,
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
            'Archived accounts won\'t appear in active lists but remain in historical reports.',
        confirmLabel: 'Archive',
        confirmColor: Colors.orange.shade700,
        icon: Icons.archive_outlined,
      ),
    );
    if (result == true) {
      await appDb.accountsDao.archiveAccount(account.id, true);
      if (mounted) {
        AppToast.show(context, message: 'Account archived successfully!');
      }
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
      if (mounted) {
        AppToast.show(context, message: 'Account deleted successfully!');
      }
    }
  }

  void _showAddAccountDialog(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddAccountForm(),
    );
  }

  void _showAccountDetails(BuildContext context, AccountRow row) {
    FocusScope.of(context).unfocus();
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

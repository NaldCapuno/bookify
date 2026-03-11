import 'package:bookkeeping/core/database/tables/accounts_table.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';

class CategoryDetailScreen extends StatelessWidget {
  final int categoryId;
  final String categoryName;

  static final NumberFormat _amountFormat = NumberFormat('#,##0.00');

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(title: categoryName, showBackButton: true),
      body: SafeArea(
        top: false,
        child: StreamBuilder<List<LedgerEntry>>(
        stream: appDb.ledgerDao.watchLedgerEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allEntries = snapshot.data ?? [];

          // Filter logic: Include accounts where the category is the selected one
          // OR where the category's parent is the selected one (e.g. "Asset" selected, show "Current Asset" accounts)
          final entries = allEntries.where((e) {
            final isSameCategory = e.category.id == categoryId;
            final isParentCategory = e.category.parent == categoryId;
            return (isSameCategory || isParentCategory) &&
                e.transactionCount > 0;
          }).toList();

          if (entries.isEmpty) {
            return _buildEmptyState(theme, colorScheme);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) =>
                _buildAccountTable(context, entries[index]),
          );
        },
        ),
      ),
    );
  }

  Widget _buildAccountTable(BuildContext context, LedgerEntry entry) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MM/dd/yy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Account Header
            Text(
              '${entry.account.code} - ${entry.account.name}',
              style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),

            // Table Header
            _buildTableHeader(theme),
            Divider(color: colorScheme.outline, thickness: 1),

            // Transactions List
            StreamBuilder<List<TypedResult>>(
              stream: appDb.ledgerDao.watchTransactionsForAccount(
                entry.account.id,
              ),
              builder: (context, txSnapshot) {
                if (!txSnapshot.hasData) return const LinearProgressIndicator();

                final rows = txSnapshot.data ?? [];
                double totalDebit = 0;
                double totalCredit = 0;

                return Column(
                  children: [
                    ...rows.map((row) {
                      final journal = row.readTable(appDb.journals);
                      final tx = row.readTable(appDb.transactions);
                      totalDebit += tx.debit;
                      totalCredit += tx.credit;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                dateFormat.format(journal.date),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                journal.description,
                                style: const TextStyle(fontSize: 12),
                                maxLines: 2,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildAmountCell(
                                context,
                                tx.debit > 0
                                    ? _amountFormat.format(tx.debit)
                                    : '—',
                                hasAmount: tx.debit > 0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildAmountCell(
                                context,
                                tx.credit > 0
                                    ? _amountFormat.format(tx.credit)
                                    : '—',
                                hasAmount: tx.credit > 0,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    Divider(color: colorScheme.outline, height: 24),

                    // Balance Row
                    Row(
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text(
                            'BALANCE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(flex: 2, child: SizedBox()),
                        Expanded(
                          flex: 2,
                          child: _buildAmountCell(
                            context,
                            // FIX: Now using account.normalBalance instead of category.normalBalance
                            _amountFormat.format(
                              _calculateBalance(
                                entry.account.normalBalance,
                                totalDebit,
                                totalCredit,
                              ),
                            ),
                            hasAmount: true,
                            bold: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Methods ---

  static double _calculateBalance(
    NormalBalance normalBalance,
    double debit,
    double credit,
  ) {
    return (normalBalance == NormalBalance.debit)
        ? (debit - credit)
        : (credit - debit);
  }

  Widget _buildTableHeader(ThemeData theme) {
    const style = TextStyle(fontWeight: FontWeight.bold, fontSize: 11);
    return const Row(
      children: [
        Expanded(flex: 1, child: Text('DATE', style: style)),
        Expanded(flex: 2, child: Text('DESCRIPTION', style: style)),
        Expanded(
          flex: 1,
          child: Text('DEBIT', textAlign: TextAlign.right, style: style),
        ),
        Expanded(
          flex: 1,
          child: Text('CREDIT', textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Text(
        'No transactions found for this category.',
        style: theme.textTheme.bodyMedium!.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  static Widget _buildAmountCell(
    BuildContext context,
    String value, {
    required bool hasAmount,
    bool bold = false,
  }) {
    return Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          textAlign: hasAmount ? TextAlign.right : TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: hasAmount ? null : Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}

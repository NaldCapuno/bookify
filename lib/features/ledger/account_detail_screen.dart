import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';

class AccountDetailScreen extends StatelessWidget {
  final LedgerEntry entry;

  const AccountDetailScreen({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${entry.account.code} - ${entry.account.name}',
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: StreamBuilder<List<TypedResult>>(
        stream: appDb.ledgerDao.watchTransactionsForAccount(entry.account.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          final rows = snapshot.data ?? [];
          if (rows.isEmpty) {
            return Center(
              child: Text(
                'No transactions yet',
                style: theme.textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          // Map rows to simple view model and compute totals.
          final txItems = <_TxRow>[];
          double totalDebit = 0;
          double totalCredit = 0;

          for (final row in rows) {
            final journal = row.readTable(appDb.journals);
            final tx = row.readTable(appDb.transactions);
            txItems.add(
              _TxRow(
                date: journal.date,
                debit: tx.debit,
                credit: tx.credit,
              ),
            );
            totalDebit += tx.debit;
            totalCredit += tx.credit;
          }

          final dateFormatter = DateFormat('yyyy-MM-dd');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'DATE',
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'DEBIT',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'CREDIT',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: colorScheme.outline, thickness: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: txItems.length,
                    itemBuilder: (context, index) {
                      final item = txItems[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                dateFormatter.format(item.date),
                                style: theme.textTheme.bodyMedium!.copyWith(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.debit > 0
                                    ? item.debit.toStringAsFixed(2)
                                    : '—',
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodyMedium!.copyWith(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                item.credit > 0
                                    ? item.credit.toStringAsFixed(2)
                                    : '—',
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodyMedium!.copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Divider(color: colorScheme.outline, thickness: 2),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'TOTAL',
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        totalDebit.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        totalCredit.toStringAsFixed(2),
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TxRow {
  final DateTime date;
  final double debit;
  final double credit;

  _TxRow({
    required this.date,
    required this.debit,
    required this.credit,
  });
}

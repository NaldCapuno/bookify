import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';
import '../../core/database/tables/account_categories_table.dart';

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: categoryName, showBackButton: true),
      body: StreamBuilder<List<LedgerEntry>>(
        stream: appDb.ledgerDao.watchLedgerEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final allEntries = snapshot.data ?? [];
          final entries = allEntries
              .where(
                (e) =>
                    e.category.parent == categoryId ||
                    e.category.id == categoryId,
              )
              .where((e) => e.transactionCount > 0)
              .toList();

          if (entries.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No accounts with transactions in this category',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _buildAccountTable(entries[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildAccountTable(LedgerEntry entry) {
    final dateFormat = DateFormat('MM/dd/yy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black12, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${entry.account.code} - ${entry.account.name}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'DATE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'DESCRIPTION',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'DEBIT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'CREDIT',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black, thickness: 1),
            StreamBuilder<List<TypedResult>>(
              stream: appDb.ledgerDao.watchTransactionsForAccount(entry.account.id),
              builder: (context, txSnapshot) {
                if (txSnapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                final rows = txSnapshot.data ?? [];
                double totalDebit = 0;
                double totalCredit = 0;

                for (final row in rows) {
                  final tx = row.readTable(appDb.transactions);
                  totalDebit += tx.debit;
                  totalCredit += tx.credit;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...rows.map((row) {
                      final journal = row.readTable(appDb.journals);
                      final tx = row.readTable(appDb.transactions);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                dateFormat.format(journal.date),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                journal.description,
                                style: const TextStyle(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildAmountCell(
                                tx.debit > 0
                                    ? _amountFormat.format(tx.debit)
                                    : '—',
                                hasAmount: tx.debit > 0,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: _buildAmountCell(
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
                    const Divider(color: Colors.black26, height: 24),
                    // TOTAL row commented out for now; only BALANCE is shown.
                    // Row(
                    //   children: [
                    //     const Expanded(
                    //       flex: 1,
                    //       child: Text(
                    //         'TOTAL',
                    //         style: TextStyle(
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12,
                    //         ),
                    //       ),
                    //     ),
                    //     const Expanded(flex: 2, child: SizedBox()),
                    //     Expanded(
                    //       flex: 1,
                    //       child: _buildAmountCell(
                    //         _amountFormat.format(totalDebit),
                    //         hasAmount: true,
                    //         fontSize: 12,
                    //         bold: true,
                    //       ),
                    //     ),
                    //     Expanded(
                    //       flex: 1,
                    //       child: _buildAmountCell(
                    //         _amountFormat.format(totalCredit),
                    //         hasAmount: true,
                    //         fontSize: 12,
                    //         bold: true,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    const SizedBox(height: 8),
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
                            _amountFormat.format(
                              _balanceForAccount(
                                entry.category.normalBalance,
                                totalDebit,
                                totalCredit,
                              ),
                            ),
                            hasAmount: true,
                            fontSize: 12,
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

  /// Balance per account using category normal balance (same logic as LedgerDao).
  static double _balanceForAccount(
    NormalBalance normalBalance,
    double totalDebit,
    double totalCredit,
  ) {
    if (normalBalance == NormalBalance.debit) {
      return totalDebit - totalCredit;
    }
    return totalCredit - totalDebit;
  }

  /// Renders debit/credit cell: "—" centered, numbers right-aligned and scale down if too long.
  static Widget _buildAmountCell(
    String value, {
    required bool hasAmount,
    double fontSize = 13,
    bool bold = false,
  }) {
    final text = Text(
      value,
      textAlign: hasAmount ? TextAlign.right : TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
    if (hasAmount) {
      return Align(
        alignment: Alignment.centerRight,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerRight,
          child: text,
        ),
      );
    }
    return text;
  }
}

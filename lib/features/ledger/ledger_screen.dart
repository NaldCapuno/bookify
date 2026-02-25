import 'package:flutter/material.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/ledger_dao.dart';
import 'category_detail_screen.dart';

class LedgerScreen extends StatelessWidget {
  const LedgerScreen({super.key});

  static int _countForCategory(List<LedgerEntry> entries, int categoryId) {
    return entries
        .where(
          (e) =>
              e.category.parent == categoryId || e.category.id == categoryId,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: StreamBuilder<List<LedgerEntry>>(
          stream: appDb.ledgerDao.watchLedgerEntries(),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? [];
            final counts = [
              _countForCategory(entries, 1),
              _countForCategory(entries, 2),
              _countForCategory(entries, 3),
              _countForCategory(entries, 4),
              _countForCategory(entries, 5),
            ];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.black),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildCategoryTile(context, 1, 'Assets', counts[0]),
                _buildCategoryTile(context, 2, 'Liabilities', counts[1]),
                _buildCategoryTile(
                  context,
                  3,
                  "Owner's Equity",
                  counts[2],
                ),
                _buildCategoryTile(context, 4, 'Revenue', counts[3]),
                _buildCategoryTile(context, 5, 'Expenses', counts[4]),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    int id,
    String title,
    int accountCount,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDetailScreen(
              categoryId: id,
              categoryName: title,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$accountCount',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

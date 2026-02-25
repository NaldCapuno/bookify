import 'package:flutter/material.dart';

class LedgerEntryCard extends StatelessWidget {
  final int accountDbId;
  final IconData icon;
  final String code;
  final String name;
  final int transactions;
  final String balance;
  final VoidCallback onTap;

  const LedgerEntryCard({
    super.key,
    required this.accountDbId,
    required this.icon,
    required this.code,
    required this.name,
    required this.transactions,
    required this.balance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Text(
              code,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            Text(
              '₱$balance',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

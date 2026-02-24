import 'package:flutter/material.dart';

enum AccountCategory { assets, liabilities, equity, revenue, expenses }

class LedgerAccount {
  final String code;
  final String name;
  final double balance;
  final int transactions;
  final IconData icon;
  final AccountCategory category;

  LedgerAccount({
    required this.code,
    required this.name,
    required this.balance,
    required this.transactions,
    required this.icon,
    required this.category,
  });
}

import 'package:bookkeeping/core/widgets/empty_placeholder.dart';
import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementCard extends StatelessWidget {
  final IncomeStatement data;

  const IncomeStatementCard({super.key, required this.data});

  String _formatAccounting(double amount, {bool showSymbol = false}) {
    if (amount == 0 && !showSymbol) return '-';
    final formatter = NumberFormat('#,##0', 'en_US');
    String formatted = formatter.format(amount.abs());
    if (showSymbol) formatted = '₱  $formatted';
    if (amount < 0) return '($formatted)';
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    // GUARD CLAUSE: Check if any revenue or expense activity exists
    final bool hasData = data.totalRevenue != 0 || data.totalExpenses != 0;

    if (!hasData) {
      return const EmptyReportPlaceholder(message: "No transaction recorded.");
    }

    final allExpenses = [
      ...data.costOfSales,
      ...data.operatingExpenses,
      ...data.otherExpenses,
      ...data.taxExpenses,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Revenues",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...data.revenues.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: _formatAccounting(item.amount),
            ),
          ),
        ),
        FinancialLineItem(
          label: "Total Revenues:",
          amount: _formatAccounting(data.totalRevenue, showSymbol: true),
          isTotal: true,
        ),
        const SizedBox(height: 24),
        const Text(
          "Expenses",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        ...allExpenses.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: _formatAccounting(item.amount),
            ),
          ),
        ),
        FinancialLineItem(
          label: "Total Expenses:",
          amount: _formatAccounting(data.totalExpenses),
          isTotal: true,
        ),
        const SizedBox(height: 16),
        FinancialLineItem(
          label: data.netIncomeLabel,
          amount: _formatAccounting(data.netIncome, showSymbol: true),
          isGrandTotal: true,
        ),
      ],
    );
  }
}

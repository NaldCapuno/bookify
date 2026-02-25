import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementCard extends StatelessWidget {
  final IncomeStatement data;

  const IncomeStatementCard({super.key, required this.data});

  // Formatting helper matching the exact style of your other reports
  String _formatAccounting(double amount, {bool showSymbol = false}) {
    if (amount == 0 && !showSymbol) return '-';
    final formatter = NumberFormat('#,##0', 'en_US');
    String formatted = formatter.format(amount.abs());

    if (showSymbol) {
      formatted = '₱  $formatted';
    }

    if (amount < 0) {
      return '($formatted)';
    }
    return formatted;
  }

  @override
  Widget build(BuildContext context) {
    // Flatten all expenses to mimic the single-step layout
    final allExpenses = [
      ...data.costOfSales,
      ...data.operatingExpenses,
      ...data.otherExpenses,
      ...data.taxExpenses,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==============================
        // REVENUES SECTION
        // ==============================
        const Text(
          "Revenues",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        ...data.revenues.map((item) {
          return Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: _formatAccounting(
                item.amount,
              ), // Passed directly to the main right column
            ),
          );
        }).toList(),

        // Total Revenues
        FinancialLineItem(
          label: "Total Revenues:",
          amount: _formatAccounting(data.totalRevenue, showSymbol: true),
          isTotal: true,
        ),

        const SizedBox(height: 24),

        // ==============================
        // EXPENSES SECTION
        // ==============================
        const Text(
          "Expenses",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        ...allExpenses.map((item) {
          return Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: _formatAccounting(
                item.amount,
              ), // Passed directly to the main right column
            ),
          );
        }).toList(),

        // Total Expenses
        FinancialLineItem(
          label: "Total Expenses:",
          amount: _formatAccounting(data.totalExpenses),
          isTotal: true, // Automatically draws the line above it!
        ),

        const SizedBox(height: 16),

        // ==============================
        // NET INCOME
        // ==============================
        FinancialLineItem(
          label: data.netIncomeLabel,
          amount: _formatAccounting(data.netIncome, showSymbol: true),
          isGrandTotal:
              true, // Automatically handles the bold text and double underlines!
        ),
      ],
    );
  }
}

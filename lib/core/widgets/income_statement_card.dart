import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementCard extends StatelessWidget {
  final IncomeStatement data;

  const IncomeStatementCard({super.key, required this.data});

  // Formatting helper matching the image
  String _formatAccounting(double amount, {bool showSymbol = false}) {
    final formatter = NumberFormat('#,##0', 'en_US');
    String formatted = formatter.format(amount.abs());

    // Add parentheses for negative numbers first
    if (amount < 0) {
      formatted = '($formatted)';
    }

    // Add symbol outside the parentheses
    if (showSymbol) {
      formatted = '₱  $formatted';
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

        ...data.revenues.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          bool isFirst = idx == 0;
          bool isLast = idx == data.revenues.length - 1;

          return Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: "", // Leave outer column blank
              innerAmount: _formatAccounting(item.amount, showSymbol: isFirst),
              isLastInGroup: isLast,
            ),
          );
        }).toList(), // <-- FIX: Added .toList() here to prevent Iterable errors
        // Total Revenues
        FinancialLineItem(
          label: "Total Revenues:",
          amount: _formatAccounting(data.totalRevenue, showSymbol: true),
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

        ...allExpenses.asMap().entries.map((entry) {
          int idx = entry.key;
          var item = entry.value;
          bool isLast = idx == allExpenses.length - 1;

          return Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: "", // Leave outer column blank
              innerAmount: _formatAccounting(item.amount),
              isLastInGroup: isLast,
            ),
          );
        }).toList(), // <-- FIX: Added .toList() here to prevent Iterable errors
        // Total Expenses
        FinancialLineItem(
          label: "Total Expenses:",
          amount: _formatAccounting(data.totalExpenses),
          isLastInGroup: true, // Puts a line under the total expense
        ),

        const SizedBox(height: 16),

        // ==============================
        // NET INCOME
        // ==============================
        FinancialLineItem(
          label: data
              .netIncomeLabel, // Restored dynamic NET INCOME / NET LOSS label
          amount: _formatAccounting(data.netIncome, showSymbol: true),
          isGrandTotal: true,
          hasDoubleUnderline: true,
        ),
      ],
    );
  }
}

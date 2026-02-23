import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/core/widgets/reports_color.dart';
import 'package:bookkeeping/core/widgets/reports_section_header.dart';
import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementCard extends StatelessWidget {
  final IncomeStatement data;
  const IncomeStatementCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // REVENUE SECTION
          const SectionHeader(title: "REVENUE"),
          const SizedBox(height: 12),
          ...data.revenues.map(
            (item) => FinancialLineItem(
              label: item.name,
              amount: currencyFormat.format(item.amount),
            ),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE0E0E0)),
          FinancialLineItem(
            label: "Total Revenue",
            amount: currencyFormat.format(data.totalRevenue),
            isTotal: true,
          ),

          const SizedBox(height: 30),
          const SectionHeader(title: "EXPENSES"),
          const SizedBox(height: 12),
          _buildExpenseGroup("Cost of Sales", data.costOfSales, currencyFormat),
          _buildExpenseGroup(
            "Operating Expenses",
            data.operatingExpenses,
            currencyFormat,
          ),
          _buildExpenseGroup(
            "Other Expenses",
            data.otherExpenses,
            currencyFormat,
          ),
          _buildExpenseGroup("Tax Expenses", data.taxExpenses, currencyFormat),

          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE0E0E0)),
          FinancialLineItem(
            label: "Total Expenses",
            amount: currencyFormat.format(data.totalExpenses),
            isTotal: true,
          ),

          const SizedBox(height: 20),
          const Divider(color: Color(0xFF001F3F), thickness: 1.2),
          const SizedBox(height: 20),
          FinancialLineItem(
            label: data.netIncomeLabel,
            amount: currencyFormat.format(data.netIncome),
            isGrandTotal: true,
          ),
        ],
      ),
    );
  }

  // Helper method to keep the UI code DRY and clean
  Widget _buildExpenseGroup(
    String title,
    List<FinancialItem> items,
    NumberFormat formatter,
  ) {
    if (items.isEmpty)
      return const SizedBox.shrink(); // Don't show the group if it's empty

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
              ), // Indent sub-items slightly
              child: FinancialLineItem(
                label: item.name,
                amount: formatter.format(item.amount),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

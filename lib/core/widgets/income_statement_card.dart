import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementCard extends StatelessWidget {
  final IncomeStatement data;

  const IncomeStatementCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==============================
        // INCOME SECTION
        // ==============================
        const Text(
          "INCOME",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Category: Sales Revenue
        _buildCategoryHeader("Sales Revenue"),
        ...data.revenues.map(
          (item) =>
              _buildIndentedAccount(item.name, currency.format(item.amount)),
        ),

        const SizedBox(height: 20),

        // ==============================
        // EXPENSES SECTION
        // ==============================
        const Text(
          "EXPENSES",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),

        // Category: Cost of Sales (500s)
        if (data.costOfSales.isNotEmpty) ...[
          _buildCategoryHeader("Cost of Sales"),
          ...data.costOfSales.map(
            (item) =>
                _buildIndentedAccount(item.name, currency.format(item.amount)),
          ),
          const SizedBox(height: 12),
        ],

        // Category: Operating Expense (600s)
        if (data.operatingExpenses.isNotEmpty) ...[
          _buildCategoryHeader("Operating Expense"),
          ...data.operatingExpenses.map(
            (item) =>
                _buildIndentedAccount(item.name, currency.format(item.amount)),
          ),
          const SizedBox(height: 12),
        ],

        // Category: Other Expenses (700s)
        if (data.otherExpenses.isNotEmpty) ...[
          _buildCategoryHeader("Other Expense"),
          ...data.otherExpenses.map(
            (item) =>
                _buildIndentedAccount(item.name, currency.format(item.amount)),
          ),
          const SizedBox(height: 12),
        ],

        const Divider(thickness: 1.5, height: 32),

        // ==============================
        // SUMMARY BLOCKS (The "Excel" Logic)
        // ==============================

        // Block 1: Gross Profit Calculation
        FinancialLineItem(
          label: "Total Revenue",
          amount: currency.format(data.totalRevenue),
          isTotal: true,
        ),
        FinancialLineItem(
          label: "Less Cost of Sales",
          amount: currency.format(data.totalCostOfSales),
        ),
        FinancialLineItem(
          label: "Gross Profit",
          amount: currency.format(data.grossProfit),
          isGrandTotal: true,
        ),

        const SizedBox(height: 32),

        // Block 2: Net Income Calculation
        FinancialLineItem(
          label: "Total Revenue",
          amount: currency.format(data.totalRevenue),
        ),
        FinancialLineItem(
          label: "Less Total Expenses",
          amount: currency.format(data.totalExpenses),
        ),

        const Divider(thickness: 2, color: Colors.black, height: 24),

        FinancialLineItem(
          label: data.netIncomeLabel,
          amount: currency.format(data.netIncome),
          isGrandTotal: true,
        ),
      ],
    );
  }

  // category headers (Sales Revenue, Cost of Sales, etc.)
  Widget _buildCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0, bottom: 2.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    );
  }

  // indented account rows (The individual accounts under categories)
  Widget _buildIndentedAccount(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, top: 2, bottom: 2),
      child: FinancialLineItem(
        label: name,
        amount: amount,
        // Using standard size to contrast with bold headers
      ),
    );
  }
}

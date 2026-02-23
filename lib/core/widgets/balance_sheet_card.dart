import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSheetCard extends StatelessWidget {
  final BalanceSheet data;
  const BalanceSheetCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: '₱');

    return LayoutBuilder(
      builder: (context, constraints) {
        // If width is less than 600px, we use Portrait (Vertical) mode
        bool isPortrait = constraints.maxWidth < 600;

        if (isPortrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAssetsColumn(currency),
              const SizedBox(height: 40),
              const Divider(thickness: 2),
              const SizedBox(height: 20),
              _buildLiabilitiesEquityColumn(currency),
            ],
          );
        } else {
          // Landscape/Tablet Mode (Side-by-Side)
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildAssetsColumn(currency)),
              const SizedBox(width: 32),
              Expanded(child: _buildLiabilitiesEquityColumn(currency)),
            ],
          );
        }
      },
    );
  }

  Widget _buildAssetsColumn(NumberFormat currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "ASSETS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildSection("Current Assets", data.currentAssets, currency),
        FinancialLineItem(
          label: "Total Current Assets",
          amount: currency.format(data.totalCurrentAssets),
          isTotal: true,
        ),
        const SizedBox(height: 16),
        _buildSection("Non-Current Assets", data.nonCurrentAssets, currency),
        FinancialLineItem(
          label: "Total Non-Current Assets",
          amount: currency.format(data.totalNonCurrentAssets),
          isTotal: true,
        ),
        const SizedBox(height: 20),
        FinancialLineItem(
          label: "TOTAL ASSETS",
          amount: currency.format(data.totalAssets),
          isGrandTotal: true,
        ),
      ],
    );
  }

  Widget _buildLiabilitiesEquityColumn(NumberFormat currency) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "LIABILITIES & OWNER'S EQUITY",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        const Text(
          "Liabilities",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        _buildSection("Current Liabilities", data.currentLiabilities, currency),
        FinancialLineItem(
          label: "Total Current Liabilities",
          amount: currency.format(data.totalCurrentLiabilities),
          isTotal: true,
        ),
        const SizedBox(height: 16),
        _buildSection(
          "Non-Current Liabilities",
          data.nonCurrentLiabilities,
          currency,
        ),
        FinancialLineItem(
          label: "Total Non-Current Liabilities",
          amount: currency.format(data.totalNonCurrentLiabilities),
          isTotal: true,
        ),
        FinancialLineItem(
          label: "Total Liabilities",
          amount: currency.format(data.totalLiabilities),
          isTotal: true,
        ),
        const SizedBox(height: 24),
        const Text(
          "Owner's Equity",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        ...data.equityItems.map(
          (e) => _buildIndentedRow(e.name, currency.format(e.amount)),
        ),
        _buildIndentedRow("Net Income", currency.format(data.netIncome)),
        FinancialLineItem(
          label: "Total Owner's Equity",
          amount: currency.format(data.totalOwnerEquity),
          isTotal: true,
        ),
        const SizedBox(height: 20),
        FinancialLineItem(
          label: "TOTAL LIABILITIES & EQUITY",
          amount: currency.format(data.totalLiabilitiesAndEquity),
          isGrandTotal: true,
        ),
      ],
    );
  }

  Widget _buildSection(
    String title,
    List<dynamic> items,
    NumberFormat currency,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (items.isEmpty)
          _buildIndentedRow("No items", "₱0.00")
        else
          ...items.map(
            (i) => _buildIndentedRow(i.name, currency.format(i.amount)),
          ),
      ],
    );
  }

  Widget _buildIndentedRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 4),
      child: FinancialLineItem(label: label, amount: amount),
    );
  }
}

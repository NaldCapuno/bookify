import 'package:bookkeeping/core/widgets/empty_placeholder.dart';
import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSheetCard extends StatelessWidget {
  final BalanceSheet data;
  const BalanceSheetCard({super.key, required this.data});

  String _formatAccounting(double amount) {
    final formatter = NumberFormat('#,##0', 'en_US');
    if (amount < 0) {
      return "(${formatter.format(amount.abs())})";
    }
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Check if the entire report is empty
    final bool hasAnyData =
        data.totalAssets != 0 || data.totalLiabilitiesAndEquity != 0;

    if (!hasAnyData) {
      return const EmptyReportPlaceholder(message: "No transaction recorded.");
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isPortrait = constraints.maxWidth < 600;

        if (isPortrait) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAssetsColumn(),
              const SizedBox(height: 40),
              _buildLiabilitiesEquityColumn(),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildAssetsColumn()),
              const SizedBox(width: 32),
              Expanded(child: _buildLiabilitiesEquityColumn()),
            ],
          );
        }
      },
    );
  }

  Widget _buildAssetsColumn() {
    if (data.totalAssets == 0) {
      return const EmptyReportPlaceholder(
        message: "No asset transactions recorded.",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Assets",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        _buildSection("Current Assets", data.currentAssets),
        if (data.currentAssets.isNotEmpty)
          FinancialLineItem(
            label: "Total Current Assets",
            amount: _formatAccounting(data.totalCurrentAssets),
            isTotal: true,
          ),
        if (data.nonCurrentAssets.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSection("Long-term Assets", data.nonCurrentAssets),
          FinancialLineItem(
            label: "Total Long-term Assets",
            amount: _formatAccounting(data.totalNonCurrentAssets),
            isTotal: true,
          ),
        ],
        const SizedBox(height: 20),
        FinancialLineItem(
          label: "Total Assets:",
          amount: _formatAccounting(data.totalAssets),
          isTotal: true,
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildLiabilitiesEquityColumn() {
    if (data.totalLiabilitiesAndEquity == 0) {
      return const EmptyReportPlaceholder(
        message: "No liability or equity entries found.",
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          "Liabilities",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        if (data.currentLiabilities.isNotEmpty) ...[
          _buildSection("Current Liabilities", data.currentLiabilities),
          FinancialLineItem(
            label: "Total Current Liabilities",
            amount: _formatAccounting(data.totalCurrentLiabilities),
            isTotal: true,
          ),
        ],
        if (data.nonCurrentLiabilities.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSection("Long-term Liabilities", data.nonCurrentLiabilities),
          FinancialLineItem(
            label: "Total Long-term Liabilities",
            amount: _formatAccounting(data.totalNonCurrentLiabilities),
            isTotal: true,
          ),
        ],
        if (data.totalLiabilities > 0)
          FinancialLineItem(
            label: "Total Liabilities",
            amount: _formatAccounting(data.totalLiabilities),
            isTotal: true,
            isBold: true,
          ),
        const SizedBox(height: 24),
        if (data.totalOwnerEquity != 0 || data.netIncome != 0) ...[
          const Text(
            "Owner's Equity",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          const Text("Owner's Equity", style: TextStyle(fontSize: 14)),
          ...data.equityItems.map((item) {
            return Padding(
              padding: const EdgeInsets.only(left: 24.0),
              child: FinancialLineItem(
                label: item.name,
                amount: _formatAccounting(item.amount),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: "Retained Earnings (Net Income)",
              amount: _formatAccounting(data.netIncome),
            ),
          ),
          FinancialLineItem(
            label: "Total Owner's Equity",
            amount: _formatAccounting(data.totalOwnerEquity),
            isTotal: true,
          ),
        ],
        const SizedBox(height: 20),
        FinancialLineItem(
          label: "Total Liabilities and Owner's Equity",
          amount: _formatAccounting(data.totalLiabilitiesAndEquity),
          isGrandTotal: true,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<dynamic> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14)),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: FinancialLineItem(
              label: item.name,
              amount: _formatAccounting(item.amount),
            ),
          );
        }),
      ],
    );
  }
}

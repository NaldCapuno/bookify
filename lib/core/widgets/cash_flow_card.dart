import 'package:bookkeeping/core/widgets/financial_line_item.dart';
import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_statement.dart';
import 'package:bookkeeping/core/widgets/empty_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashFlowStatementCard extends StatelessWidget {
  final CashFlowStatement data;

  const CashFlowStatementCard({super.key, required this.data});

  String _formatAccounting(double amount, {bool showSymbol = false}) {
    if (amount == 0 && !showSymbol) return '-';
    final formatter = NumberFormat('#,##0', 'en_US');
    String formatted = formatter.format(amount.abs());
    if (showSymbol) formatted = '₱  $formatted';
    if (amount < 0) return '($formatted)';
    return formatted;
  }

  String _flowLabel(String category, double amount) {
    if (amount >= 0) return "NET CASH PROVIDED BY $category";
    return "NET CASH USED IN $category";
  }

  // --- NEW: Smart Label Generator ---
  String _formatActivityLabel(String accountName, double amount, String type) {
    // 1. Investing Activities (Buying/Selling Assets)
    if (type == 'investing') {
      if (amount < 0) {
        return "Purchase of $accountName"; // Money out = Purchase
      } else {
        return "Proceeds from sale of $accountName"; // Money in = Sale
      }
    }

    // 2. Financing Activities (Loans/Equity)
    if (type == 'financing') {
      // Handle special Equity cases explicitly for clearer reading
      if (accountName.toLowerCase().contains('drawing')) {
        return "Owner's drawings";
      }

      if (amount > 0) {
        return "Proceeds from $accountName"; // Money in = Borrowing/Capital
      } else {
        return "Payments on $accountName"; // Money out = Repayment
      }
    }

    return accountName; // Fallback
  }

  @override
  Widget build(BuildContext context) {
    // GUARD CLAUSE
    final bool hasActivity =
        data.netIncome != 0 ||
        data.operatingAssetChanges.isNotEmpty ||
        data.operatingLiabilityChanges.isNotEmpty ||
        data.investingActivities.isNotEmpty ||
        data.financingLiabilities.isNotEmpty ||
        data.financingEquity.isNotEmpty;

    if (!hasActivity) {
      return const EmptyReportPlaceholder(message: "No transaction recorded.");
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==========================================
        // 1. OPERATING ACTIVITIES
        // ==========================================
        const Text(
          "CASH FLOWS FROM OPERATING ACTIVITIES",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        FinancialLineItem(
          label: "Net income",
          amount: _formatAccounting(data.netIncome, showSymbol: true),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 4.0),
          child: Text(
            "Adjustments to reconcile net income to\nnet cash provided by operating activities:",
            style: TextStyle(fontSize: 12),
          ),
        ),
        if (data.depreciationExpense > 0)
          _buildIndentedAccount(
            label: "Depreciation on fixed assets",
            amount: _formatAccounting(data.depreciationExpense),
            indent: 32.0,
          ),

        // Operating Assets
        if (data.operatingAssetChanges.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
            child: Text(
              "(Increase) decrease in current assets:",
              style: TextStyle(fontSize: 12),
            ),
          ),
          ..._buildItemRows(
            data.operatingAssetChanges,
            indent: 32.0,
            isLastSection: data.operatingLiabilityChanges.isEmpty,
          ),
        ],

        // Operating Liabilities
        if (data.operatingLiabilityChanges.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.only(left: 16.0, top: 4.0, bottom: 4.0),
            child: Text(
              "Increase (decrease) in current liabilities:",
              style: TextStyle(fontSize: 12),
            ),
          ),
          ..._buildItemRows(
            data.operatingLiabilityChanges,
            indent: 32.0,
            isLastSection: true,
          ),
        ],

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FinancialLineItem(
            label: _flowLabel(
              "OPERATING ACTIVITIES",
              data.netCashFromOperating,
            ),
            amount: _formatAccounting(data.netCashFromOperating),
            isBold: true,
          ),
        ),

        const SizedBox(height: 24),

        // ==========================================
        // 2. INVESTING ACTIVITIES (Updated Labels)
        // ==========================================
        const Text(
          "CASH FLOWS FROM INVESTING ACTIVITIES",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        ...data.investingActivities.map((item) {
          // Apply custom label logic here
          final label = _formatActivityLabel(
            item.name,
            item.amount,
            'investing',
          );
          return _buildIndentedAccount(
            label: label,
            amount: _formatAccounting(item.amount),
            indent: 16.0,
          );
        }),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FinancialLineItem(
            label: _flowLabel(
              "INVESTING ACTIVITIES",
              data.netCashFromInvesting,
            ),
            amount: _formatAccounting(data.netCashFromInvesting),
            isBold: true,
          ),
        ),

        const SizedBox(height: 24),

        // ==========================================
        // 3. FINANCING ACTIVITIES (Updated Labels)
        // ==========================================
        const Text(
          "CASH FLOWS FROM FINANCING ACTIVITIES",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),

        // Financing Liabilities
        ...data.financingLiabilities.map((item) {
          final label = _formatActivityLabel(
            item.name,
            item.amount,
            'financing',
          );
          return _buildIndentedAccount(
            label: label,
            amount: _formatAccounting(item.amount),
            indent: 16.0,
          );
        }),

        // Financing Equity
        ...data.financingEquity.map((item) {
          final label = _formatActivityLabel(
            item.name,
            item.amount,
            'financing',
          );
          return _buildIndentedAccount(
            label: label,
            amount: _formatAccounting(item.amount),
            indent: 16.0,
          );
        }),

        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: FinancialLineItem(
            label: _flowLabel(
              "FINANCING ACTIVITIES",
              data.netCashFromFinancing,
            ),
            amount: _formatAccounting(data.netCashFromFinancing),
            isBold: true,
            isLastInGroup: true,
          ),
        ),

        const SizedBox(height: 12),

        // ==========================================
        // SUMMARY
        // ==========================================
        Padding(
          padding: const EdgeInsets.only(left: 32.0),
          child: FinancialLineItem(
            label: "NET INCREASE (DECREASE) IN CASH",
            amount: _formatAccounting(data.netIncreaseInCash),
            isBold: true,
          ),
        ),

        const SizedBox(height: 12),

        FinancialLineItem(
          label: "BEGINNING CASH BALANCE",
          amount: _formatAccounting(data.beginningCashBalance),
          isLastInGroup: true,
        ),

        FinancialLineItem(
          label: "ENDING CASH BALANCE",
          amount: _formatAccounting(data.endingCashBalance, showSymbol: true),
          isBold: true,
          hasDoubleUnderline: true,
        ),
      ],
    );
  }

  // --- HELPERS ---

  List<Widget> _buildItemRows(
    List<FinancialItem> items, {
    required double indent,
    bool isLastSection = false,
  }) {
    if (items.isEmpty) return [];
    return items.asMap().entries.map((entry) {
      int idx = entry.key;
      var item = entry.value;
      bool isLast = isLastSection && (idx == items.length - 1);
      return _buildIndentedAccount(
        label: item.name,
        amount: _formatAccounting(item.amount),
        indent: indent,
        isLastInGroup: isLast,
      );
    }).toList();
  }

  Widget _buildIndentedAccount({
    required String label,
    required String amount,
    required double indent,
    bool isLastInGroup = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(left: indent),
      child: FinancialLineItem(
        label: label,
        amount: amount,
        isLastInGroup: isLastInGroup,
      ),
    );
  }
}

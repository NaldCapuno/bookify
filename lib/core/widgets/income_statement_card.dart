import 'package:bookkeeping/core/widgets/empty_placeholder.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementCard extends StatelessWidget {
  final IncomeStatement data;

  const IncomeStatementCard({super.key, required this.data});

  // Aggregates lists of items into a single total amount
  double _sumList(List items) {
    return items.fold(0.0, (sum, item) => sum + (item.amount as double));
  }

  @override
  Widget build(BuildContext context) {
    final bool hasData = data.totalRevenue != 0 || data.totalExpenses != 0;

    if (!hasData) {
      return const EmptyReportPlaceholder(message: "No transaction recorded.");
    }

    // Calculate strict accounting categories based on your data models
    final double totalRevenue = _sumList(data.revenues);
    final double costOfSales = _sumList(data.costOfSales);
    final double grossIncome = totalRevenue - costOfSales;

    // Combine operating and other expenses as per the image layout
    final double operatingExpenses =
        _sumList(data.operatingExpenses) + _sumList(data.otherExpenses);
    final double netIncomeLoss = grossIncome - operatingExpenses;

    final double taxProvision = _sumList(data.taxExpenses);
    final double netIncomeAfterTax = netIncomeLoss - taxProvision;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FormalReportRow(
          label: "REVENUE",
          amount: totalRevenue,
          isBold: true,
          showCurrencySymbol: true,
        ),
        const SizedBox(height: 12),
        _FormalReportRow(
          label: "LESS: COST OF SALES",
          amount: costOfSales,
          isUnderlined: true,
        ),
        const SizedBox(height: 12),
        _FormalReportRow(
          label: "GROSS INCOME",
          amount: grossIncome,
          showCurrencySymbol: true,
          isBold: true,
        ),
        const SizedBox(height: 12),
        _FormalReportRow(
          label: "LESS: OPERATING EXPENSES",
          amount: operatingExpenses,
          isUnderlined: true,
        ),
        const SizedBox(height: 12),
        _FormalReportRow(
          label: "NET INCOME/(LOSS)",
          amount: netIncomeLoss,
          showCurrencySymbol: true,
          isBold: true,
          isUnderlined: true,
        ),
        const SizedBox(height: 12),
        _FormalReportRow(
          label: "LESS: PROVISION FOR INCOME TAX",
          amount: taxProvision,
          isUnderlined: true,
        ),
        const SizedBox(height: 12),
        _FormalReportRow(
          label: "NET INCOME AFTER INCOME TAX",
          amount: netIncomeAfterTax,
          showCurrencySymbol: true,
          isBold: true,
          isDoubleUnderlined: true,
        ),
      ],
    );
  }
}

/// A custom widget to perfectly mimic the aligned accounting rows in the document.
class _FormalReportRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool showCurrencySymbol;
  final bool isUnderlined;
  final bool isDoubleUnderlined;
  final bool isBold;

  const _FormalReportRow({
    required this.label,
    required this.amount,
    this.showCurrencySymbol = false,
    this.isUnderlined = false,
    this.isDoubleUnderlined = false,
    this.isBold = false,
  });

  String _formatAccounting(double val) {
    if (val == 0) return '-';
    final formatter = NumberFormat('#,##0.00', 'en_US');
    String formatted = formatter.format(val.abs());
    return val < 0 ? '($formatted)' : formatted;
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      fontSize: 13,
      color: Colors.black87,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 1. The Label (Left aligned)
        Expanded(child: Text(label, style: textStyle)),

        // 2. The Currency Symbol 'P' (Fixed width, right aligned relative to itself)
        SizedBox(
          width: 30,
          child: Text(
            showCurrencySymbol ? 'P' : '',
            style: textStyle,
            textAlign: TextAlign.right,
          ),
        ),

        // 3. The Amount & Underlines (Fixed width, right aligned)
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatAccounting(amount),
                style: textStyle,
                textAlign: TextAlign.right,
              ),
              if (isUnderlined || isDoubleUnderlined) ...[
                const SizedBox(height: 2),
                Container(height: 1, color: Colors.black87),
              ],
              if (isDoubleUnderlined) ...[
                const SizedBox(height: 2),
                Container(height: 1, color: Colors.black87),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

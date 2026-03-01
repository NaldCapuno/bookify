import 'package:bookkeeping/features/cashflow/cash_flow_statement.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/utils/pdf_export_service.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';

class ReportControlBar extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final dynamic currentData;
  final DateTime? startDate;
  final DateTime? endDate;

  const ReportControlBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.currentData,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: [
        Text(
          "Period:",
          style: TextStyle(color: appColors.secondaryText.withValues(alpha: 0.8)),
        ),
        const SizedBox(width: 8),

        // --- DROPDOWN SECTION ---
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: appColors.backgroundGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: appColors.dividerColor),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReportPeriod>(
                isExpanded: true,
                value: selectedPeriod,
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  size: 20,
                  color: appColors.secondaryText,
                ),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: appColors.primaryText,
                  fontSize: 14,
                ),
                onChanged: (ReportPeriod? newValue) {
                  if (newValue != null) {
                    onPeriodChanged(newValue);
                  }
                },
                items: ReportPeriod.values.map<DropdownMenuItem<ReportPeriod>>((
                  ReportPeriod period,
                ) {
                  return DropdownMenuItem<ReportPeriod>(
                    value: period,
                    child: Text(period.label, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // --- REVERTED DOWNLOAD BUTTON DESIGN ---
        OutlinedButton.icon(
          onPressed: () {
            if (currentData is CashFlowStatement) {
              PdfExportService.exportCashFlowStatement(currentData!);
            }
            if (currentData != null) {
              if (currentData is IncomeStatement) {
                PdfExportService.exportIncomeStatement(currentData!);
              } else if (currentData is BalanceSheet) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cash Flow PDF Export coming soon!"),
                  ),
                );
                PdfExportService.exportBalanceSheet(
                  currentData!,
                  startDate ?? DateTime.now(),
                  endDate ?? DateTime.now(),
                );
              } else if (currentData is BalanceSheet) {
                // Pass the dates to the export service
                PdfExportService.exportBalanceSheet(
                  currentData!,
                  startDate ?? DateTime.now(),
                  endDate ?? DateTime.now(),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No data available to download yet."),
                ),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: appColors.primaryText,
            side: BorderSide(color: appColors.dividerColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text("Download"),
        ),
      ],
    );
  }
}

import 'package:bookkeeping/core/widgets/app_toast.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_statement.dart';
import 'package:flutter/material.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/utils/pdf_export_service.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/core/database/app_database.dart'; // Added for User model

class ReportControlBar extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final dynamic currentData;
  final DateTime? startDate;
  final DateTime? endDate;

  // Add business owner to pass to PDF export
  final User? businessOwner;

  const ReportControlBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.currentData,
    this.startDate,
    this.endDate,
    this.businessOwner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Row(
      children: [
        Text(
          "Period:",
          style: theme.textTheme.bodyMedium!.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 8),

        // --- DROPDOWN SECTION ---
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.05),
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
                  color: colorScheme.onSurfaceVariant,
                ),
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
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
            if (currentData == null) {
              AppToast.show(
                context,
                message: "No data available to download yet.",
              );
              return;
            }

            // Prepare header details
            final ownerName = businessOwner?.username ?? '';
            final address = businessOwner?.businessAddress ?? '';
            final isYearly = selectedPeriod == ReportPeriod.yearly;

            if (currentData is IncomeStatement) {
              PdfExportService.exportIncomeStatement(
                currentData!,
                ownerName: ownerName,
                address: address,
                isYearly: isYearly,
              );
            } else if (currentData is BalanceSheet) {
              PdfExportService.exportBalanceSheet(
                currentData!,
                startDate ?? DateTime.now(),
                endDate ?? DateTime.now(),
                ownerName: ownerName,
                address: address,
              );
            } else if (currentData is CashFlowStatement) {
              PdfExportService.exportCashFlowStatement(
                currentData!,
                ownerName: ownerName,
                address: address,
              );
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: colorScheme.outlineVariant),
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

import 'package:flutter/material.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/utils/pdf_export_service.dart';
import 'package:bookkeeping/core/widgets/reports_color.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart'; // Add this import

class ReportControlBar extends StatelessWidget {
  final ReportPeriod selectedPeriod;
  final ValueChanged<ReportPeriod> onPeriodChanged;
  final dynamic currentData; // Changed from IncomeStatement? to dynamic

  const ReportControlBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    this.currentData,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Period:",
          style: TextStyle(color: AppColors.secondaryText.withOpacity(0.8)),
        ),
        const SizedBox(width: 8),

        // --- DROPDOWN SECTION ---
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.dividerColor),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<ReportPeriod>(
                isExpanded: true,
                value: selectedPeriod,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.secondaryText),
                style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryText, fontSize: 14),
                onChanged: (ReportPeriod? newValue) {
                  if (newValue != null) onPeriodChanged(newValue);
                },
                items: ReportPeriod.values.map<DropdownMenuItem<ReportPeriod>>((ReportPeriod period) {
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

        // --- DOWNLOAD BUTTON SECTION ---
        OutlinedButton.icon(
          onPressed: () {
            if (currentData != null) {
              // Route to the correct PDF logic based on data type
              if (currentData is IncomeStatement) {
                PdfExportService.exportIncomeStatement(currentData);
              } else if (currentData is BalanceSheet) {
                PdfExportService.exportBalanceSheet(currentData);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("No data available to download yet.")),
              );
            }
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primaryText,
            side: const BorderSide(color: AppColors.dividerColor),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text("Download"),
        ),
      ],
    );
  }
}
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FinancialLineItem extends StatelessWidget {
  final String label;
  final String amount;
  final String? innerAmount;

  final bool isTotal;
  final bool isGrandTotal;
  final bool isLastInGroup;
  final bool hasDoubleUnderline;
  final bool hasInnerBottomBorder;
  final bool isBold; // FIX: Brought this explicit control back!

  const FinancialLineItem({
    super.key,
    required this.label,
    required this.amount,
    this.innerAmount,
    this.isTotal = false,
    this.isGrandTotal = false,
    this.isLastInGroup = false,
    this.hasDoubleUnderline = false,
    this.hasInnerBottomBorder = false,
    this.isBold = false, // Defaults to false
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    // FIX: Removed the buggy '.contains("NET")' logic.
    // Now it only bolds if it is a Grand Total, or if you explicitly pass isBold: true
    bool weightIsBold = isGrandTotal || isBold;
    FontWeight fontWeight = weightIsBold ? FontWeight.bold : FontWeight.normal;
    double fontSize = 13;
    Color textColor = appColors.primaryText;

    bool drawDoubleLine = hasDoubleUnderline || isGrandTotal;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // LABEL
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // --- INNER COLUMN ---
          if (innerAmount != null)
            Container(
              width: 80,
              decoration: BoxDecoration(
                border: Border(
                  bottom: (hasInnerBottomBorder || isLastInGroup)
                      ? BorderSide(color: textColor, width: 1.0)
                      : BorderSide.none,
                ),
              ),
              padding: const EdgeInsets.only(bottom: 2.0, top: 2.0),
              child: Text(
                innerAmount!,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.right,
              ),
            ),

          if (innerAmount != null) const SizedBox(width: 8),

          // --- OUTER COLUMN ---
          Container(
            width: 90,
            decoration: BoxDecoration(
              border: Border(
                top: (isTotal || isGrandTotal)
                    ? BorderSide(color: textColor, width: 1.0)
                    : BorderSide.none,
                bottom: (isLastInGroup && innerAmount == null) || drawDoubleLine
                    ? BorderSide(color: textColor, width: 1.0)
                    : BorderSide.none,
              ),
            ),
            padding: EdgeInsets.only(
              bottom: drawDoubleLine ? 2.0 : 0.0,
              top: 2.0,
            ),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: drawDoubleLine
                      ? BorderSide(color: textColor, width: 1.0)
                      : BorderSide.none,
                ),
              ),
              child: Text(
                amount,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

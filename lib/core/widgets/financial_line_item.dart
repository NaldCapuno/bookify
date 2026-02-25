import 'package:bookkeeping/core/widgets/reports_color.dart';
import 'package:flutter/material.dart';

class FinancialLineItem extends StatelessWidget {
  final String label;
  final String amount;
  final String?
  innerAmount; // For showing the amount in parentheses if negative
  final bool hasDoubleUnderline; // To trigger the double underline style
  final bool isTotal;
  final bool isGrandTotal;
  final bool isLastInGroup; // Added to trigger the accounting subtotal line

  const FinancialLineItem({
    super.key,
    required this.label,
    required this.amount,
    this.innerAmount, // Must be present
    this.hasDoubleUnderline = false, // Must be present
    this.isTotal = false,
    this.isGrandTotal = false,
    this.isLastInGroup = false,
  });

  @override
  Widget build(BuildContext context) {
    FontWeight fontWeight = FontWeight.normal;
    double fontSize = 14;
    Color textColor = AppColors.primaryText;

    if (isGrandTotal) {
      fontWeight = FontWeight.bold;
      fontSize = 15;
    } else if (isTotal) {
      fontWeight = FontWeight.normal;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          // Wrap the amount in a Container to apply the specific accounting borders
          Container(
            decoration: BoxDecoration(
              border: Border(
                // Single line below the last item in a sub-category
                bottom: isLastInGroup
                    ? BorderSide(color: textColor, width: 1.0)
                    : BorderSide.none,
                // Single line above the grand total
                top: isGrandTotal
                    ? BorderSide(color: textColor, width: 1.0)
                    : BorderSide.none,
              ),
            ),
            padding: const EdgeInsets.only(bottom: 2.0, top: 2.0),
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
        ],
      ),
    );
  }
}

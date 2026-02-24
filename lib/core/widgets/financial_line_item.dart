import 'package:bookkeeping/core/widgets/reports_color.dart';
import 'package:flutter/material.dart';

class FinancialLineItem extends StatelessWidget {
  final String label;
  final String amount;
  final bool isTotal;
  final bool isGrandTotal;

  const FinancialLineItem({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isGrandTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    FontWeight fontWeight = FontWeight.normal;
    double fontSize = 15;
    Color textColor = AppColors.primaryText;

    if (isGrandTotal) {
      fontWeight = FontWeight.w900;
      fontSize = 18;
      textColor = AppColors.accentBlue;
    } else if (isTotal) {
      fontWeight = FontWeight.w700;
      fontSize = 16;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align to top if label wraps
        children: [
          // 1. Wrap label in Expanded so it doesn't push the amount off-screen
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                right: 12.0,
              ), // Gap between text and numbers
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: fontWeight,
                  color: textColor,
                ),
                // 2. Add overflow handling for very long account names
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // 3. Amount stays fixed-width
          Text(
            amount,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:bookkeeping/core/widgets/reports_color.dart';

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
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: fontWeight,
              color: textColor,
            ),
          ),
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

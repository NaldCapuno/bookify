import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class WalkthroughService {
  static void showDashboardTour(
    BuildContext context, {
    required GlobalKey bannerKey,
    required GlobalKey cashCardKey,
    required GlobalKey profitAndLossKey,
    required GlobalKey salesChartKey,
  }) {
    List<TargetFocus> targets = [
      _createTarget(
        "Banner",
        bannerKey,
        "Welcome to TsekBooks!",
        "This is your business identity. You can customize your business name and type in the Profile settings.",
        cashCardKey,
      ),
      _createTarget(
        "CashCard",
        cashCardKey,
        "Cash on Hand",
        "This card tracks your total liquidity. It automatically sums up all accounts labeled 'Cash on Hand'.",
        profitAndLossKey,
      ),
      _createTarget(
        "PLCard",
        profitAndLossKey,
        "Net Profit Tracker",
        "See your real-time performance. It compares your Sales Revenue against your Expenses.",
        salesChartKey,
      ),
      _createTarget(
        "SalesChart",
        salesChartKey,
        "Sales Trends",
        "This chart visualizes your sales growth across the four quarters of the year.",
        null,
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF1A1C1E),
      opacityShadow: 0.9,
      textSkip: "SKIP",
      paddingFocus: 10,
    ).show(context: context);
  }

  static TargetFocus _createTarget(
    String id,
    GlobalKey currentKey,
    String title,
    String text,
    GlobalKey? nextKey,
  ) {
    return TargetFocus(
      identify: id,
      keyTarget: currentKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: ContentAlign.bottom,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    controller.next();

                    if (nextKey != null && nextKey.currentContext != null) {
                      Scrollable.ensureVisible(
                        nextKey.currentContext!,
                        duration: const Duration(milliseconds: 500),
                        alignment: 0.5,
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Text(
                    nextKey != null ? "Next" : "Finish",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

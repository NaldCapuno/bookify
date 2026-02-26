import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class WalkthroughService {
  static void showDashboardTour(BuildContext context, {
    required GlobalKey dashboardKey,
    required GlobalKey fabKey,
    required GlobalKey reportsKey,
  }) {
    final targets = [
      // Step 1: Highlight the Dashboard Stats
      TargetFocus(
        identify: "dashboard_target",
        keyTarget: dashboardKey,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) => _buildInstruction(
              title: "Business Overview",
              desc: "Monitor your Assets, Liabilities, and Equity at a glance here.",
            ),
          ),
        ],
      ),
      // Step 2: Highlight the FAB (Add Transaction)
      TargetFocus(
        identify: "fab_target",
        keyTarget: fabKey,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) => _buildInstruction(
              title: "Record Transactions",
              desc: "Tap here to record sales or expenses into your Journal.",
            ),
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFF1A1C1E),
      opacityShadow: 0.8,
      paddingFocus: 10,
      onClickTarget: (target) => print("Click on target"),
    ).show(context: context);
  }

  static Widget _buildInstruction({required String title, required String desc}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Text(desc, style: const TextStyle(color: Colors.white, fontSize: 16)),
      ],
    );
  }
}
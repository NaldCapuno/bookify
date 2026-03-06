import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class WalkthroughService {
  static const String _prefPrefix = 'walkthrough_complete_';
  static const Color _walkthroughShadow = Colors.black;
  static const Color _walkthroughOnShadow = Colors.white;
  static const Color _walkthroughButtonBg = Colors.white;
  static const Color _walkthroughButtonFg = Colors.black87;

  /// Uncomment the calls below to enable: walkthroughs won't show again after Finish or Skip
  // ignore: unused_element
  static Future<bool> _hasCompletedWalkthrough(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefPrefix$tourId') ?? false;
  }

  // ignore: unused_element
  static Future<void> _markWalkthroughComplete(String tourId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefPrefix$tourId', true);
  }

  // DASHBOARD TOUR
  static Future<void> showDashboardTour(
    BuildContext context, {
    required GlobalKey bannerKey,
    required GlobalKey cashCardKey,
    required GlobalKey profitAndLossKey,
    required GlobalKey salesChartKey,
  }) async {
    if (await _hasCompletedWalkthrough('dashboard')) return; // COMMENTED OUT
    List<TargetFocus> targets = [
      _createTarget(
        "Banner",
        bannerKey,
        "Welcome to TsekBooks!",
        "This is your business identity. You can customize your business name and type in the Profile settings.",
      ),
      _createTarget(
        "CashCard",
        cashCardKey,
        "Cash on Hand",
        "This card tracks your total liquidity. It automatically sums up all accounts labeled 'Cash on Hand'.",
      ),
      _createTarget(
        "PLCard",
        profitAndLossKey,
        "Net Profit Tracker",
        "See your real-time performance. It compares your Sales Revenue against your Expenses.",
      ),
      _createTarget(
        "SalesChart",
        salesChartKey,
        "Sales Trends",
        "This chart visualizes your sales growth across the four quarters of the year.",
        isLastStep: true,
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: _walkthroughShadow,
      opacityShadow: 0.9,
      textSkip: "SKIP",
      paddingFocus: 10,
      beforeFocus: (target) => _scrollToTarget(target),
      onFinish: () {
        _markWalkthroughComplete('dashboard'); // COMMENTED OUT
      },
      onSkip: () {
        _markWalkthroughComplete('dashboard'); // COMMENTED OUT
        return true;
      },
    ).show(context: context);
  }

  // JOURNAL TOUR
  static Future<void> showJournalTour(
    BuildContext context, {
    required GlobalKey filterKey,
    required GlobalKey emptyKey,
    required GlobalKey fabKey,
  }) async {
    if (await _hasCompletedWalkthrough('journal')) return; // COMMENTED OUT
    List<TargetFocus> targets = [
      _createTarget(
        "JournalFilter",
        filterKey,
        "Quick Filters",
        "Organize your transactions by week, month, or quarter to keep your TsekBooks organized.",
      ),
      _createTarget(
        "EmptyJournal",
        emptyKey,
        "Your Financial History",
        "This is where your business story lives. Once you add transactions, they will appear here as professional journal entries.",
        contentAlign: ContentAlign.top,
      ),
      _createTarget(
        "AddJournal",
        fabKey,
        "Record Your First Entry",
        "Tap here to add a sale or expense. TsekBooks will handle the double-entry accounting for you automatically!",
        contentAlign: ContentAlign.top,
        isLastStep: true,
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: _walkthroughShadow,
      opacityShadow: 0.9,
      textSkip: "SKIP",
      beforeFocus: (target) => _scrollToTarget(target),
      onFinish: () {
        _markWalkthroughComplete('journal'); // COMMENTED OUT
      },
      onSkip: () {
        _markWalkthroughComplete('journal'); // COMMENTED OUT
        return true;
      },
    ).show(context: context);
  }

  static Future<void> showLedgerTour(
    BuildContext context, {
    required GlobalKey assetsKey,
    required GlobalKey liabilitiesKey,
    required GlobalKey equityKey,
    required GlobalKey revenueKey,
    required GlobalKey expensesKey,
  }) async {
    if (await _hasCompletedWalkthrough('ledger')) return; // COMMENTED OUT
    List<TargetFocus> targets = [
      _createTarget(
        "Assets",
        assetsKey,
        "Assets",
        "What your business owns—cash, inventory, equipment, and receivables. These are the resources that generate value.",
      ),
      _createTarget(
        "Liabilities",
        liabilitiesKey,
        "Liabilities",
        "What your business owes—loans, payables, and other debts. Tracking these keeps your obligations clear.",
      ),
      _createTarget(
        "OwnerEquity",
        equityKey,
        "Owner's Equity",
        "Your stake in the business—the difference between assets and liabilities. This is what's left after paying all debts.",
      ),
      _createTarget(
        "Revenue",
        revenueKey,
        "Revenue",
        "Income from sales and services. This is where your business earns money.",
      ),
      _createTarget(
        "Expenses",
        expensesKey,
        "Expenses",
        "Costs of running your business—supplies, rent, salaries. These reduce your net profit.",
        isLastStep: true,
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: _walkthroughShadow,
      opacityShadow: 0.9,
      textSkip: "SKIP",
      beforeFocus: (target) => _scrollToTarget(target),
      onFinish: () {
        _markWalkthroughComplete('ledger'); // COMMENTED OUT
      },
      onSkip: () {
        _markWalkthroughComplete('ledger'); // COMMENTED OUT
        return true;
      },
    ).show(context: context);
  }

  // REPORTS TOUR
  static Future<void> showReportsTour(
    BuildContext context, {
    required GlobalKey incomeStatementKey,
    required GlobalKey balanceSheetKey,
    required GlobalKey cashFlowKey,
  }) async {
    if (await _hasCompletedWalkthrough('reports')) return; // COMMENTED OUT
    List<TargetFocus> targets = [
      _createTarget(
        "IncomeStatement",
        incomeStatementKey,
        "Income Statement",
        "Shows your revenue, expenses, and net profit over a period. Essential for understanding how profitable your business is.",
      ),
      _createTarget(
        "BalanceSheet",
        balanceSheetKey,
        "Balance Sheet",
        "A snapshot of your assets, liabilities, and equity at a point in time. Shows what you own and what you owe.",
      ),
      _createTarget(
        "CashFlow",
        cashFlowKey,
        "Cash Flow",
        "Tracks cash coming in and going out. Helps you see if you have enough liquidity to cover operations and growth.",
        isLastStep: true,
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: _walkthroughShadow,
      opacityShadow: 0.9,
      textSkip: "SKIP",
      beforeFocus: (target) => _scrollToTarget(target),
      onFinish: () {
        _markWalkthroughComplete('reports'); // COMMENTED OUT
      },
      onSkip: () {
        _markWalkthroughComplete('reports'); // COMMENTED OUT
        return true;
      },
    ).show(context: context);
  }

  // ACCOUNTS TOUR
  static Future<void> showAccountsTour(
    BuildContext context, {
    required GlobalKey searchKey,
    required GlobalKey listKey,
    required GlobalKey fabKey,
  }) async {
    if (await _hasCompletedWalkthrough('accounts')) return; // COMMENTED OUT
    List<TargetFocus> targets = [
      _createTarget(
        "Search",
        searchKey,
        "Search & Filter",
        "Find accounts by name or code. Use the filters to show All, Debit (DR), or Credit (CR) accounts.",
      ),
      _createTarget(
        "AccountList",
        listKey,
        "Your Chart of Accounts",
        "All your accounts are organized by category. Tap any account to view details.",
        contentAlign: ContentAlign.bottom,
      ),
      _createTarget(
        "AddAccount",
        fabKey,
        "Add New Account",
        "Create accounts for your business—cash, inventory, expenses, and more. TsekBooks keeps the double-entry logic correct.",
        contentAlign: ContentAlign.top,
        isLastStep: true,
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: _walkthroughShadow,
      opacityShadow: 0.9,
      textSkip: "SKIP",
      beforeFocus: (target) => _scrollToTarget(target),
      onFinish: () {
        _markWalkthroughComplete('accounts'); // COMMENTED OUT
      },
      onSkip: () {
        _markWalkthroughComplete('accounts'); // COMMENTED OUT
        return true;
      },
    ).show(context: context);
  }

  static Future<void> _scrollToTarget(TargetFocus target) async {
    final context = target.keyTarget?.currentContext;
    if (context != null) {
      await Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        alignment: 0.5,
        curve: Curves.easeInOut,
      );
    }
  }

  static TargetFocus _createTarget(
    String id,
    GlobalKey currentKey,
    String title,
    String text, {
    ContentAlign contentAlign = ContentAlign.bottom,
    bool isLastStep = false,
  }) {
    return TargetFocus(
      identify: id,
      keyTarget: currentKey,
      alignSkip: Alignment.topRight,
      shape: ShapeLightFocus.RRect,
      radius: 16,
      contents: [
        TargetContent(
          align: contentAlign,
          builder: (context, controller) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _walkthroughOnShadow,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text,
                  style: TextStyle(
                    color: _walkthroughOnShadow,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    controller.next();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _walkthroughButtonBg,
                    foregroundColor: _walkthroughButtonFg,
                  ),
                  child: Text(
                    isLastStep ? "Finish" : "Next",
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

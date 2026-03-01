import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/theme/app_theme.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/widgets/balance_sheet_card.dart';
import 'package:bookkeeping/core/widgets/report_control_bar.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BalanceSheetScreen extends StatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen> {
  ReportPeriod _currentPeriod = ReportPeriod.daily;

  // Track range for the UI header
  late DateTime _startDate;
  late DateTime _endDate;

  Future<BalanceSheet>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _updateDateRange(_currentPeriod);
    _fetchReport();
  }

  void _updateDateRange(ReportPeriod period) {
    final range = AccountingDateHelper.getRangeForPeriod(period);
    _startDate = range.start;
    _endDate = range.end;
  }

  void _fetchReport() {
    setState(() {
      // The Balance Sheet displays the cumulative position "As of" the end date
      _reportFuture = appDb.reportsDao.getBalanceSheet(date: _endDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: const CustomAppBar(title: "Balance Sheet", showBackButton: true),
      backgroundColor: theme.extension<AppColors>()!.surfaceContainer,
      body: SafeArea(
        child: FutureBuilder<BalanceSheet>(
          future: _reportFuture,
          builder: (context, snapshot) {
            final report = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ReportControlBar(
                    selectedPeriod: _currentPeriod,
                    currentData: report,
                    startDate: _startDate,
                    endDate: _endDate,
                    onPeriodChanged: (p) {
                      setState(() {
                        _currentPeriod = p;
                        _updateDateRange(p);
                        _fetchReport();
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- HEADER SECTION ---
                  Text(
                    report?.businessName ?? "Business Name",
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: theme.extension<AppColors>()!.reportPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "BALANCE SHEET",
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: theme.extension<AppColors>()!.reportSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "For the Period: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontSize: 13,
                      color: theme.extension<AppColors>()!.reportSecondaryText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.extension<AppColors>()!.reportDivider),
                  const SizedBox(height: 20),

                  // --- DYNAMIC CONTENT ---
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (snapshot.hasError)
                    Center(child: Text("Error: ${snapshot.error}"))
                  else if (report != null)
                    BalanceSheetCard(data: report)
                  else
                    const Center(child: Text("No financial data found.")),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

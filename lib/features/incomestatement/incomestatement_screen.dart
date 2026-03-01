import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/widgets/income_statement_card.dart';
import 'package:bookkeeping/core/widgets/report_control_bar.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'income_statement.dart';

class IncomeStatementScreen extends StatefulWidget {
  const IncomeStatementScreen({super.key});

  @override
  State<IncomeStatementScreen> createState() => _IncomeStatementScreenState();
}

class _IncomeStatementScreenState extends State<IncomeStatementScreen> {
  ReportPeriod _currentPeriod = ReportPeriod.monthly;
  late DateTime _startDate;
  late DateTime _endDate;
  Future<IncomeStatement>? _statementFuture;

  @override
  void initState() {
    super.initState();
    _updateDateRange(_currentPeriod);
    _fetchReportData(); // Cleaned up init
  }

  void _updateDateRange(ReportPeriod period) {
    final range = AccountingDateHelper.getRangeForPeriod(period);
    _startDate = range.start;
    _endDate = range.end;
  }

  void _fetchReportData() {
    setState(() {
      // FIX: Removed businessName parameter as it is now handled internally by ReportsDao
      _statementFuture = appDb.reportsDao.getIncomeStatement(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    final theme = Theme.of(context);
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Income Statement",
        showBackButton: true,
      ),
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: FutureBuilder<IncomeStatement>(
          future: _statementFuture,
          builder: (context, snapshot) {
            final reportData = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  ReportControlBar(
                    selectedPeriod: _currentPeriod,
                    currentData: reportData,
                    onPeriodChanged: (newPeriod) {
                      setState(() {
                        _currentPeriod = newPeriod;
                        _updateDateRange(newPeriod);
                        _fetchReportData();
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // --- REPORT HEADER ---
                  Text(
                    reportData?.businessName ?? "Business Name",
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "INCOME STATEMENT",
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "For the Period: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}",
                    style: theme.textTheme.bodyMedium!.copyWith(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: theme.colorScheme.outlineVariant),

                  // --- DYNAMIC CONTENT ---
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text("Error: ${snapshot.error}"),
                    )
                  else if (reportData != null)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: IncomeStatementCard(data: reportData),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: Text("No transactions recorded for this period."),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

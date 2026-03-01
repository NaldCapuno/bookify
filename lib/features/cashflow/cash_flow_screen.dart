import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:bookkeeping/core/widgets/cash_flow_card.dart';
import 'package:bookkeeping/core/widgets/report_control_bar.dart';
import 'package:bookkeeping/features/cashflow/cash_flow_statement.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CashFlowStatementScreen extends StatefulWidget {
  const CashFlowStatementScreen({super.key});

  @override
  State<CashFlowStatementScreen> createState() =>
      _CashFlowStatementScreenState();
}

class _CashFlowStatementScreenState extends State<CashFlowStatementScreen> {
  ReportPeriod _currentPeriod = ReportPeriod.monthly; // Default to monthly

  late DateTime _startDate;
  late DateTime _endDate;

  Future<CashFlowStatement>? _statementFuture;

  @override
  void initState() {
    super.initState();
    _updateDateRange(_currentPeriod);
    _fetchReportData();
  }

  void _updateDateRange(ReportPeriod period) {
    final range = AccountingDateHelper.getRangeForPeriod(period);
    _startDate = range.start;
    _endDate = range.end;
  }

  void _fetchReportData() {
    setState(() {
      // Calls our newly created DAO method!
      _statementFuture = appDb.reportsDao.getCashFlowStatement(
        startDate: _startDate,
        endDate: _endDate,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Cash Flow Statement",
        showBackButton: true,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: FutureBuilder<CashFlowStatement>(
          future: _statementFuture,
          builder: (context, snapshot) {
            final reportData = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // --- REUSABLE CONTROL BAR ---
                  ReportControlBar(
                    selectedPeriod: _currentPeriod,
                    currentData:
                        reportData, // Passes data to the Download button
                    startDate: _startDate,
                    endDate: _endDate,
                    onPeriodChanged: (newPeriod) {
                      setState(() {
                        _currentPeriod = newPeriod;
                        _updateDateRange(newPeriod);
                        _fetchReportData();
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- REPORT HEADER ---
                  Text(
                    reportData?.businessName ?? "Business Name",
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "STATEMENT OF CASH FLOWS",
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text("Error: ${snapshot.error}"),
                      ),
                    )
                  else if (reportData != null)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: CashFlowStatementCard(data: reportData),
                      ),
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Text("No financial data found."),
                      ),
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

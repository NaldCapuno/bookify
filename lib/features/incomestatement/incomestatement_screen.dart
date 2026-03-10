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
  ReportPeriod _currentPeriod = ReportPeriod.yearly;
  late DateTime _startDate;
  late DateTime _endDate;
  Future<IncomeStatement>? _statementFuture;
  User? _businessOwner;

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

  Future<void> _fetchReportData() async {
    // 1. Fetch the user profile for the formal header
    final user = await appDb.select(appDb.users).getSingleOrNull();

    // 2. Fetch the report data
    final statementFuture = appDb.reportsDao.getIncomeStatement(
      startDate: _startDate,
      endDate: _endDate,
    );

    setState(() {
      _businessOwner = user;
      _statementFuture = statementFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Format to match "For the Year Ended December 31, 2021"
    final String periodLabel = _currentPeriod == ReportPeriod.yearly
        ? "For the Year Ended ${DateFormat('MMMM dd, yyyy').format(_endDate)}"
        : "For the Period Ended ${DateFormat('MMMM dd, yyyy').format(_endDate)}";

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Income Statement",
        showBackButton: true,
      ),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      body: SafeArea(
        child: FutureBuilder<IncomeStatement>(
          future: _statementFuture,
          builder: (context, snapshot) {
            final reportData = snapshot.data;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  ReportControlBar(
                    selectedPeriod: _currentPeriod,
                    currentData: reportData,
                    businessOwner: _businessOwner, // <-- ADD THIS LINE
                    onPeriodChanged: (newPeriod) {
                      setState(() {
                        _currentPeriod = newPeriod;
                        _updateDateRange(newPeriod);
                        _fetchReportData();
                      });
                    },
                  ),
                  const SizedBox(height: 40),

                  // --- FORMAL REPORT HEADER ---
                  if (_businessOwner != null) ...[
                    Text(
                      (_businessOwner!.username).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      (_businessOwner!.business ?? 'BUSINESS NAME')
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      _businessOwner!.businessAddress ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Text(
                    "STATEMENT OF INCOME",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    periodLabel,
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 24),
                  Divider(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    thickness: 1.5,
                  ),
                  const SizedBox(height: 16),

                  // --- DYNAMIC CONTENT ---
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.only(top: 60.0),
                      child: CircularProgressIndicator(),
                    )
                  else if (snapshot.hasError)
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0),
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: TextStyle(color: theme.colorScheme.onSurface),
                      ),
                    )
                  else if (reportData != null)
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 700),
                        child: IncomeStatementCard(data: reportData),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Text(
                        "No transactions recorded for this period.",
                        style: TextStyle(color: theme.colorScheme.onSurface),
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

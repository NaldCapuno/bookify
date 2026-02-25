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

    return Scaffold(
      appBar: const CustomAppBar(
        title: "Income Statement",
        showBackButton: true,
      ),
      backgroundColor: Colors.white,
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
                    // Pulls business name from the Users table via the model
                    reportData?.businessName ?? "Business Name",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001F3F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "INCOME STATEMENT",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6C757D),
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "For the Period: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6C757D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFFE0E0E0)),

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

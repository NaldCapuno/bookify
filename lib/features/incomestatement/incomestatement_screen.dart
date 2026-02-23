import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/widgets/income_statement_card.dart';
import 'package:bookkeeping/core/widgets/report_control_bar.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

// Ensure these paths match your actual project structure
// Standardized path
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
    _initAndFetch();
  }

  void _updateDateRange(ReportPeriod period) {
    final range = AccountingDateHelper.getRangeForPeriod(period);
    _startDate = range.start;
    _endDate = range.end;
  }

  // --- NEW: SEED & FETCH LOGIC ---
  Future<void> _initAndFetch() async {
    // 1. Seed the data first so we have something to see
    // await _seedTestData();

    // 2. Fetch the report

    _fetchReportData();
  }

  void _fetchReportData() {
    setState(() {
      _statementFuture = appDb.reportsDao.getIncomeStatement(
        startDate: _startDate,
        endDate: _endDate,
        businessName: "Palawan iHub", // Personalized for your project
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
                  // --- CONTROL BAR (Always Visible) ---
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
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
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

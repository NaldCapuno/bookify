import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/widgets/income_statement_card.dart';
import 'package:bookkeeping/core/widgets/report_control_bar.dart';
import 'package:bookkeeping/features/incomestatement/financial_item.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:bookkeeping/core/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IncomeStatementScreen extends StatefulWidget {
  const IncomeStatementScreen({super.key});

  @override
  State<IncomeStatementScreen> createState() => _IncomeStatementScreenState();
}

class _IncomeStatementScreenState extends State<IncomeStatementScreen> {
  ReportPeriod _currentPeriod = ReportPeriod.monthly;
  late DateTime _startDate;
  late DateTime _endDate;
  late Future<IncomeStatement> _statementFuture;

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
    _statementFuture = appDb.reportsDao.getIncomeStatement(
      startDate: _startDate,
      endDate: _endDate,
      businessName: "My Awesome Business",
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // --- ASYNCHRONOUS CONTENT ---
              FutureBuilder<IncomeStatement>(
                future: _statementFuture,
                builder: (context, snapshot) {
                  // While waiting for data
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        // Control bar is disabled (no data) during loading
                        ReportControlBar(
                          selectedPeriod: _currentPeriod,
                          onPeriodChanged: (p) {},
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 100.0),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  }

                  // If data is successfully loaded
                  if (snapshot.hasData) {
                    final reportData = snapshot.data!;

                    return Column(
                      children: [
                        // Now we pass the reportData to the control bar so the PDF button works
                        ReportControlBar(
                          selectedPeriod: _currentPeriod,
                          currentData: reportData, // Passing data for PDF
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
                          reportData.businessName,
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

                        // --- THE ACTUAL STATEMENT CARD ---
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: IncomeStatementCard(data: reportData),
                          ),
                        ),
                      ],
                    );
                  }

                  // Error Handling
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

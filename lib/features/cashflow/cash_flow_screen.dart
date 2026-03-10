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
  ReportPeriod _currentPeriod = ReportPeriod.yearly;

  late DateTime _startDate;
  late DateTime _endDate;

  Future<CashFlowStatement>? _statementFuture;
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
    final user = await appDb.select(appDb.users).getSingleOrNull();
    final statementFuture = appDb.reportsDao.getCashFlowStatement(
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
                    currentData: reportData,
                    startDate: _startDate,
                    endDate: _endDate,
                    businessOwner: _businessOwner, // Pass to Control Bar
                    onPeriodChanged: (newPeriod) {
                      setState(() {
                        _currentPeriod = newPeriod;
                        _updateDateRange(newPeriod);
                        _fetchReportData();
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- FORMAL REPORT HEADER ---
                  if (_businessOwner != null) ...[
                    Text(
                      (_businessOwner!.username).toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      (_businessOwner!.business ?? 'BUSINESS NAME')
                          .toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (_businessOwner!.businessAddress != null &&
                        _businessOwner!.businessAddress!.isNotEmpty)
                      Text(
                        _businessOwner!.businessAddress!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13),
                      ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    "STATEMENT OF CASH FLOWS",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "For the Period: ${dateFormat.format(_startDate)} - ${dateFormat.format(_endDate)}",
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.black, thickness: 1.5),
                  const SizedBox(height: 16),

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

import 'package:bookkeeping/core/database/app_database.dart';
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
  ReportPeriod _currentPeriod = ReportPeriod.yearly;

  // Track range for the UI header
  late DateTime _startDate;
  late DateTime _endDate;

  Future<BalanceSheet>? _reportFuture;
  User? _businessOwner;

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

  Future<void> _fetchReport() async {
    // Fetch user for the formal header
    final user = await appDb.select(appDb.users).getSingleOrNull();
    // The Balance Sheet displays the cumulative position "As of" the end date
    final reportFuture = appDb.reportsDao.getBalanceSheet(date: _endDate);

    setState(() {
      _businessOwner = user;
      _reportFuture = reportFuture;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: const CustomAppBar(title: "Balance Sheet", showBackButton: true),
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                    businessOwner: _businessOwner, // Passes data to PDF Export
                    onPeriodChanged: (p) {
                      setState(() {
                        _currentPeriod = p;
                        _updateDateRange(p);
                        _fetchReport();
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
                    Text(
                      _businessOwner!.businessAddress ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                  ],

                  const Text(
                    "BALANCE SHEET",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "As of ${dateFormat.format(_endDate)}",
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

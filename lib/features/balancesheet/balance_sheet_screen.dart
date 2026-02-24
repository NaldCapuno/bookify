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
  ReportPeriod _currentPeriod = ReportPeriod.daily;
  DateTime _asOfDate = DateTime.now();
  Future<BalanceSheet>? _reportFuture;

  @override
  void initState() {
    super.initState();
    _initAndFetch();
  }

  Future<void> _initAndFetch() async {
    _fetchReport();
  }

  void _fetchReport() {
    setState(() {
      _reportFuture = appDb.reportsDao.getBalanceSheet(
        date: _asOfDate,
        businessName: "Palawan iHub", //
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd, yyyy');

    return Scaffold(
      appBar: const CustomAppBar(title: "Balance Sheet", showBackButton: true),
      backgroundColor: const Color(0xFFF8F9FA),
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
                    onPeriodChanged: (p) {
                      setState(() {
                        _currentPeriod = p;
                        _asOfDate = AccountingDateHelper.getRangeForPeriod(
                          p,
                        ).end;
                        _fetchReport();
                      });
                    },
                  ),
                  const SizedBox(height: 30),

                  // --- HEADER ---
                  Text(
                    report?.businessName ?? "Business Name",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    "BALANCE SHEET",
                    style: TextStyle(letterSpacing: 1.5, fontSize: 12),
                  ),
                  Text(
                    "As of: ${dateFormat.format(_asOfDate)}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  // --- DYNAMIC CONTENT ---
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(child: CircularProgressIndicator())
                  else if (snapshot.hasError)
                    Center(child: Text("Error: ${snapshot.error}"))
                  else if (report != null)
                    BalanceSheetCard(data: report),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

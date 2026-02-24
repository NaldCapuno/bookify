import 'package:bookkeeping/core/database/app_database.dart';
import 'package:bookkeeping/core/utils/date_utils.dart';
import 'package:bookkeeping/core/widgets/balance_sheet_card.dart';
import 'package:bookkeeping/core/widgets/report_control_bar.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/core/widgets/appbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:drift/drift.dart' as drift;

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
    // 1. Seed data for testing the balance
    await _seedBalanceSheetData();
    // 2. Initial fetch
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

  // --- SEED DATA (Balances Asset = Liability + Equity) ---
  Future<void> _seedBalanceSheetData() async {
    final existing = await appDb.select(appDb.journals).get();
    if (existing.isNotEmpty) return;

    Future<int> getAccountId(int code) async {
      final acc = await (appDb.select(
        appDb.accounts,
      )..where((t) => t.code.equals(code))).getSingle();
      return acc.id;
    }

    // 1. Initial Investment (Debit Cash 102, Credit Capital 340)
    final j1 = await appDb
        .into(appDb.journals)
        .insert(
          JournalsCompanion.insert(
            date: _asOfDate,
            description: 'Initial Investment',
          ),
        );
    await appDb
        .into(appDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            journalId: j1,
            accountId: await getAccountId(102),
            debit: const drift.Value(20004812.0),
          ),
        );
    await appDb
        .into(appDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            journalId: j1,
            accountId: await getAccountId(340),
            credit: const drift.Value(20004812.0),
          ),
        );

    // 2. Buy Equipment (Debit 157, Credit Cash 102)
    final j2 = await appDb
        .into(appDb.journals)
        .insert(
          JournalsCompanion.insert(
            date: _asOfDate,
            description: 'Buy Office Equipment',
          ),
        );
    await appDb
        .into(appDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            journalId: j2,
            accountId: await getAccountId(157),
            debit: const drift.Value(1030000.0),
          ),
        );
    await appDb
        .into(appDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            journalId: j2,
            accountId: await getAccountId(102),
            credit: const drift.Value(1030000.0),
          ),
        );

    // 3. Current Liability (Debit Cash 102, Credit SSS Payable 210)
    final j3 = await appDb
        .into(appDb.journals)
        .insert(
          JournalsCompanion.insert(
            date: _asOfDate,
            description: 'Loan for SSS',
          ),
        );
    await appDb
        .into(appDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            journalId: j3,
            accountId: await getAccountId(102),
            debit: const drift.Value(20000000.0),
          ),
        );
    await appDb
        .into(appDb.transactions)
        .insert(
          TransactionsCompanion.insert(
            journalId: j3,
            accountId: await getAccountId(210),
            credit: const drift.Value(20000000.0),
          ),
        );
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

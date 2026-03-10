import 'package:bookkeeping/features/cashflow/cash_flow_statement.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';

class PdfExportService {
  static final dateFormat = DateFormat('MMMM dd, yyyy');

  // Used for Balance Sheet & Cash Flow
  static String _formatAccounting(double amount, {bool showSymbol = false}) {
    if (amount == 0 && !showSymbol) return '-';
    final formatter = NumberFormat('#,##0', 'en_US');
    String formatted = formatter.format(amount.abs());
    if (amount < 0) formatted = '($formatted)';
    if (showSymbol) formatted = 'P  $formatted';
    return formatted;
  }

  // Strict formatter for Income Statement (with .00 decimals)
  static String _formatFormalAccounting(double val) {
    if (val == 0) return '-';
    final formatter = NumberFormat('#,##0.00', 'en_US');
    String formatted = formatter.format(val.abs());
    return val < 0 ? '($formatted)' : formatted;
  }

  static double _sumList(List items) {
    return items.fold(0.0, (sum, item) => sum + (item.amount as double));
  }

  // ==========================================
  // --- INCOME STATEMENT EXPORT ---
  // ==========================================
  static Future<void> exportIncomeStatement(
    IncomeStatement data, {
    String ownerName = '',
    String address = '',
    bool isYearly = true,
  }) async {
    final double totalRevenue = _sumList(data.revenues);
    final double costOfSales = _sumList(data.costOfSales);
    final double grossIncome = totalRevenue - costOfSales;
    final double operatingExpenses =
        _sumList(data.operatingExpenses) + _sumList(data.otherExpenses);
    final double netIncomeLoss = grossIncome - operatingExpenses;
    final double taxProvision = _sumList(data.taxExpenses);
    final double netIncomeAfterTax = netIncomeLoss - taxProvision;

    final periodLabel = isYearly
        ? "For the Year Ended ${dateFormat.format(data.periodEnd)}"
        : "For the Period Ended ${dateFormat.format(data.periodEnd)}";

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();
        pdf.addPage(
          pw.MultiPage(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(50),
            build: (pw.Context context) => [
              _buildReportHeader(
                ownerName: ownerName,
                biz: data.businessName,
                address: address,
                title: "STATEMENT OF INCOME",
                periodLabel: periodLabel,
              ),
              pw.SizedBox(height: 10),
              _buildFormalRow(
                label: "REVENUE",
                amount: totalRevenue,
                isBold: true,
                showCurrencySymbol: true,
              ),
              pw.SizedBox(height: 12),
              _buildFormalRow(
                label: "LESS: COST OF SALES",
                amount: costOfSales,
                isUnderlined: true,
              ),
              pw.SizedBox(height: 12),
              _buildFormalRow(
                label: "GROSS INCOME",
                amount: grossIncome,
                showCurrencySymbol: true,
                isBold: true,
              ),
              pw.SizedBox(height: 12),
              _buildFormalRow(
                label: "LESS: OPERATING EXPENSES",
                amount: operatingExpenses,
                isUnderlined: true,
              ),
              pw.SizedBox(height: 12),
              _buildFormalRow(
                label: "NET INCOME/(LOSS)",
                amount: netIncomeLoss,
                showCurrencySymbol: true,
                isBold: true,
                isUnderlined: true,
              ),
              pw.SizedBox(height: 12),
              _buildFormalRow(
                label: "LESS: PROVISION FOR INCOME TAX",
                amount: taxProvision,
                isUnderlined: true,
              ),
              pw.SizedBox(height: 12),
              _buildFormalRow(
                label: "NET INCOME AFTER INCOME TAX",
                amount: netIncomeAfterTax,
                showCurrencySymbol: true,
                isBold: true,
                isDoubleUnderlined: true,
              ),
            ],
          ),
        );
        return pdf.save();
      },
    );
  }

  // ==========================================
  // --- BALANCE SHEET EXPORT ---
  // ==========================================
  static Future<void> exportBalanceSheet(
    BalanceSheet data,
    DateTime start,
    DateTime end, {
    String ownerName = '',
    String address = '',
  }) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();
        pdf.addPage(
          pw.MultiPage(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) => [
              _buildReportHeader(
                ownerName: ownerName,
                biz: data.businessName,
                address: address,
                title: "BALANCE SHEET",
                periodLabel: "As of ${dateFormat.format(end)}",
              ),

              // --- ASSETS SECTION ---
              pw.Center(
                child: pw.Text(
                  "Assets",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              if (data.currentAssets.isNotEmpty) ...[
                pw.Text(
                  "Current Assets",
                  style: const pw.TextStyle(fontSize: 11),
                ),
                ...data.currentAssets
                    .map(
                      (item) => _buildFinancialRow(
                        label: item.name,
                        amount: _formatAccounting(item.amount),
                        indent: 20,
                      ),
                    )
                    .toList(),
                _buildFinancialRow(
                  label: "Total Current Assets",
                  amount: _formatAccounting(data.totalCurrentAssets),
                  hasTopBorder: true,
                ),
              ],
              pw.SizedBox(height: 10),
              if (data.nonCurrentAssets.isNotEmpty) ...[
                pw.Text(
                  "Long-term Assets",
                  style: const pw.TextStyle(fontSize: 11),
                ),
                ...data.nonCurrentAssets
                    .map(
                      (item) => _buildFinancialRow(
                        label: item.name,
                        amount: _formatAccounting(item.amount),
                        indent: 20,
                      ),
                    )
                    .toList(),
                _buildFinancialRow(
                  label: "Total Long-term Assets",
                  amount: _formatAccounting(data.totalNonCurrentAssets),
                  hasTopBorder: true,
                ),
              ],
              _buildFinancialRow(
                label: "Total Assets:",
                amount: _formatAccounting(data.totalAssets),
                isBold: true,
              ),

              pw.SizedBox(height: 30),

              // --- LIABILITIES & EQUITY SECTION ---
              pw.Center(
                child: pw.Text(
                  "Liabilities & Owner's Equity",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),

              if (data.currentLiabilities.isNotEmpty) ...[
                pw.Text(
                  "Current Liabilities",
                  style: const pw.TextStyle(fontSize: 11),
                ),
                ...data.currentLiabilities
                    .map(
                      (item) => _buildFinancialRow(
                        label: item.name,
                        amount: _formatAccounting(item.amount),
                        indent: 20,
                      ),
                    )
                    .toList(),
                _buildFinancialRow(
                  label: "Total Current Liabilities",
                  amount: _formatAccounting(data.totalCurrentLiabilities),
                  hasTopBorder: true,
                ),
              ],
              pw.SizedBox(height: 10),
              if (data.nonCurrentLiabilities.isNotEmpty) ...[
                pw.Text(
                  "Long-term Liabilities",
                  style: const pw.TextStyle(fontSize: 11),
                ),
                ...data.nonCurrentLiabilities
                    .map(
                      (item) => _buildFinancialRow(
                        label: item.name,
                        amount: _formatAccounting(item.amount),
                        indent: 20,
                      ),
                    )
                    .toList(),
                _buildFinancialRow(
                  label: "Total Long-term Liabilities",
                  amount: _formatAccounting(data.totalNonCurrentLiabilities),
                  hasTopBorder: true,
                ),
              ],
              _buildFinancialRow(
                label: "Total Liabilities",
                amount: _formatAccounting(data.totalLiabilities),
                isBold: true,
                hasTopBorder: true,
              ),

              pw.SizedBox(height: 20),

              pw.Text(
                "Owner's Equity",
                style: const pw.TextStyle(fontSize: 11),
              ),
              ...data.equityItems
                  .map(
                    (item) => _buildFinancialRow(
                      label: item.name,
                      amount: _formatAccounting(item.amount),
                      indent: 20,
                    ),
                  )
                  .toList(),
              _buildFinancialRow(
                label: "Retained Earnings (Net Income)",
                amount: _formatAccounting(data.netIncome),
                indent: 20,
              ),
              _buildFinancialRow(
                label: "Total Owner's Equity",
                amount: _formatAccounting(data.totalOwnerEquity),
                isBold: true,
                hasTopBorder: true,
              ),

              pw.SizedBox(height: 10),
              _buildFinancialRow(
                label: "Total Liabilities and Owner's Equity",
                amount: _formatAccounting(data.totalLiabilitiesAndEquity),
                isGrandTotal: true,
              ),
            ],
          ),
        );
        return pdf.save();
      },
    );
  }

  // ==========================================
  // --- CASH FLOW EXPORT ---
  // ==========================================
  static Future<void> exportCashFlowStatement(
    CashFlowStatement data, {
    String ownerName = '',
    String address = '',
  }) async {
    String flowLabel(String cat, double amt) =>
        amt >= 0 ? "NET CASH PROVIDED BY $cat" : "NET CASH USED IN $cat";

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();
        pdf.addPage(
          pw.MultiPage(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) => [
              _buildReportHeader(
                ownerName: ownerName,
                biz: data.businessName,
                address: address,
                title: "STATEMENT OF CASH FLOWS",
                periodLabel:
                    "For the Period: ${dateFormat.format(data.startDate)} - ${dateFormat.format(data.endDate)}",
              ),

              // 2. OPERATING ACTIVITIES
              pw.Text(
                "CASH FLOWS FROM OPERATING ACTIVITIES",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              _buildFinancialRow(
                label: "Net income",
                amount: _formatAccounting(data.netIncome, showSymbol: true),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 16, top: 4, bottom: 4),
                child: pw.Text(
                  "Adjustments to reconcile net income to net cash:",
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              if (data.depreciationExpense > 0)
                _buildFinancialRow(
                  label: "Depreciation on fixed assets",
                  amount: _formatAccounting(data.depreciationExpense),
                  indent: 32,
                ),
              ...data.operatingAssetChanges
                  .map(
                    (item) => _buildFinancialRow(
                      label: item.name,
                      amount: _formatAccounting(item.amount),
                      indent: 32,
                    ),
                  )
                  .toList(),
              ...data.operatingLiabilityChanges
                  .map(
                    (item) => _buildFinancialRow(
                      label: item.name,
                      amount: _formatAccounting(item.amount),
                      indent: 32,
                    ),
                  )
                  .toList(),
              _buildFinancialRow(
                label: flowLabel(
                  "OPERATING ACTIVITIES",
                  data.netCashFromOperating,
                ),
                amount: _formatAccounting(data.netCashFromOperating),
                isBold: true,
                hasTopBorder: true,
              ),
              pw.SizedBox(height: 15),

              // 3. INVESTING ACTIVITIES
              pw.Text(
                "CASH FLOWS FROM INVESTING ACTIVITIES",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              ...data.investingActivities
                  .map(
                    (item) => _buildFinancialRow(
                      label: item.name,
                      amount: _formatAccounting(item.amount),
                      indent: 16,
                    ),
                  )
                  .toList(),
              _buildFinancialRow(
                label: flowLabel(
                  "INVESTING ACTIVITIES",
                  data.netCashFromInvesting,
                ),
                amount: _formatAccounting(data.netCashFromInvesting),
                isBold: true,
                hasTopBorder: true,
              ),
              pw.SizedBox(height: 15),

              // 4. FINANCING ACTIVITIES
              pw.Text(
                "CASH FLOWS FROM FINANCING ACTIVITIES",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              ...data.financingLiabilities
                  .map(
                    (item) => _buildFinancialRow(
                      label: item.name,
                      amount: _formatAccounting(item.amount),
                      indent: 16,
                    ),
                  )
                  .toList(),
              ...data.financingEquity
                  .map(
                    (item) => _buildFinancialRow(
                      label: item.name,
                      amount: _formatAccounting(item.amount),
                      indent: 16,
                    ),
                  )
                  .toList(),
              _buildFinancialRow(
                label: flowLabel(
                  "FINANCING ACTIVITIES",
                  data.netCashFromFinancing,
                ),
                amount: _formatAccounting(data.netCashFromFinancing),
                isBold: true,
                hasTopBorder: true,
              ),
              pw.SizedBox(height: 15),

              // 5. SUMMARY RECONCILIATION
              _buildFinancialRow(
                label: "NET INCREASE (DECREASE) IN CASH",
                amount: _formatAccounting(data.netIncreaseInCash),
                indent: 32,
                isBold: true,
              ),
              pw.SizedBox(height: 8),
              _buildFinancialRow(
                label: "BEGINNING CASH BALANCE",
                amount: _formatAccounting(data.beginningCashBalance),
                isBold: false,
              ),
              _buildFinancialRow(
                label: "ENDING CASH BALANCE",
                amount: _formatAccounting(
                  data.endingCashBalance,
                  showSymbol: true,
                ),
                isGrandTotal: true,
              ),
            ],
          ),
        );
        return pdf.save();
      },
    );
  }

  // ==========================================
  // --- SHARED HELPERS ---
  // ==========================================

  static pw.Widget _buildReportHeader({
    required String ownerName,
    required String biz,
    required String address,
    required String title,
    required String periodLabel,
  }) {
    return pw.Column(
      children: [
        if (ownerName.isNotEmpty)
          pw.Center(
            child: pw.Text(
              ownerName.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#000000'),
              ),
            ),
          ),
        pw.Center(
          child: pw.Text(
            biz.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#000000'),
            ),
          ),
        ),
        if (address.isNotEmpty)
          pw.Center(
            child: pw.Text(
              address,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColor.fromHex('#000000'),
              ),
            ),
          ),
        pw.SizedBox(height: 12),
        pw.Center(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#000000'),
            ),
          ),
        ),
        pw.Center(
          child: pw.Text(
            periodLabel,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColor.fromHex('#000000'),
            ),
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#000000')),
        pw.SizedBox(height: 15),
      ],
    );
  }

  // Row specifically for the strict Income Statement layout
  static pw.Widget _buildFormalRow({
    required String label,
    required double amount,
    bool showCurrencySymbol = false,
    bool isUnderlined = false,
    bool isDoubleUnderlined = false,
    bool isBold = false,
  }) {
    final textStyle = pw.TextStyle(
      fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
      fontSize: 10,
    );

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Expanded(child: pw.Text(label, style: textStyle)),
        pw.Container(
          width: 20,
          child: pw.Text(
            showCurrencySymbol ? 'P' : '',
            style: textStyle,
            textAlign: pw.TextAlign.right,
          ),
        ),
        pw.SizedBox(width: 5),
        pw.Container(
          width: 80,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                _formatFormalAccounting(amount),
                style: textStyle,
                textAlign: pw.TextAlign.right,
              ),
              if (isUnderlined || isDoubleUnderlined) ...[
                pw.SizedBox(height: 1.5),
                pw.Container(height: 0.5, color: PdfColors.black),
              ],
              if (isDoubleUnderlined) ...[
                pw.SizedBox(height: 1.5),
                pw.Container(height: 0.5, color: PdfColors.black),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Original row used for Balance Sheet and Cash Flow
  static pw.Widget _buildFinancialRow({
    required String label,
    required String amount,
    double indent = 0,
    bool isBold = false,
    bool hasTopBorder = false,
    bool isGrandTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.only(left: indent),
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: isBold || isGrandTotal
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
          ),
          pw.Container(
            width: 100,
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: (hasTopBorder || isGrandTotal)
                    ? const pw.BorderSide(width: 0.5)
                    : pw.BorderSide.none,
                bottom: isGrandTotal
                    ? const pw.BorderSide(width: 0.5)
                    : pw.BorderSide.none,
              ),
            ),
            padding: pw.EdgeInsets.only(top: 2, bottom: isGrandTotal ? 1 : 0),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: isGrandTotal
                      ? const pw.BorderSide(width: 0.5)
                      : pw.BorderSide.none,
                ),
              ),
              child: pw.Text(
                amount,
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: isBold || isGrandTotal
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
                textAlign: pw.TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

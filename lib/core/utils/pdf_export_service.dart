import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';

class PdfExportService {
  static final dateFormat = DateFormat('MMMM dd, yyyy');

  // Shared Helper: Formats numbers for both reports
  // Uses 'P' for the symbol as it renders safely across all default PDF fonts
  static String _formatAccounting(double amount, {bool showSymbol = false}) {
    if (amount == 0 && !showSymbol) return '-';
    final formatter = NumberFormat('#,##0', 'en_US');
    String formatted = formatter.format(amount.abs());

    if (showSymbol) {
      formatted = 'P  $formatted';
    }

    if (amount < 0) return '($formatted)';
    return formatted;
  }

  // ==========================================
  // --- INCOME STATEMENT EXPORT (Single-Step)
  // ==========================================
  static Future<void> exportIncomeStatement(IncomeStatement data) async {
    // Flatten all expenses into a single list for the Single-Step format
    final allExpenses = [
      ...data.costOfSales,
      ...data.operatingExpenses,
      ...data.otherExpenses,
      ...data.taxExpenses,
    ];

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: format, // Adapts to A4, Legal, etc.
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return [
                // 1. HEADER
                _buildReportHeader(
                  data.businessName,
                  "INCOME STATEMENT",
                  data.periodStart,
                  data.periodEnd,
                ),

                // 2. REVENUES
                pw.Text(
                  "Revenues",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 8),

                ...data.revenues.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  bool isFirst = idx == 0;
                  bool isLast = idx == data.revenues.length - 1;

                  return _buildIncomeStatementRow(
                    label: item.name,
                    innerAmount: _formatAccounting(
                      item.amount,
                      showSymbol: isFirst,
                    ),
                    hasInnerBottomBorder: isLast,
                    indent: 24,
                  );
                }),

                // Total Revenues
                _buildIncomeStatementRow(
                  label: "Total Revenues:",
                  outerAmount: _formatAccounting(
                    data.totalRevenue,
                    showSymbol: true,
                  ),
                ),

                pw.SizedBox(height: 24),

                // 3. EXPENSES
                pw.Text(
                  "Expenses",
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 8),

                ...allExpenses.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  bool isLast = idx == allExpenses.length - 1;

                  return _buildIncomeStatementRow(
                    label: item.name,
                    innerAmount: _formatAccounting(item.amount),
                    hasInnerBottomBorder: isLast,
                    indent: 24,
                  );
                }),

                // Total Expenses
                _buildIncomeStatementRow(
                  label: "Total Expenses:",
                  outerAmount: _formatAccounting(data.totalExpenses),
                  hasOuterBottomBorder: true,
                ),

                pw.SizedBox(height: 16),

                // 4. NET INCOME
                _buildIncomeStatementRow(
                  label: "Net Income",
                  outerAmount: _formatAccounting(
                    data.netIncome,
                    showSymbol: true,
                  ),
                  isBold: true,
                  hasDoubleUnderline: true,
                ),
              ];
            },
          ),
        );
        return pdf.save();
      },
    );
  }

  // ==========================================
  // --- BALANCE SHEET EXPORT (Screen Match) ---
  // ==========================================
  static Future<void> exportBalanceSheet(
    BalanceSheet data,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        final pdf = pw.Document();

        pdf.addPage(
          pw.MultiPage(
            pageFormat: format,
            margin: const pw.EdgeInsets.all(40),
            build: (pw.Context context) {
              return [
                // 1. HEADER SECTION
                _buildReportHeader(
                  data.businessName,
                  "BALANCE SHEET",
                  startDate,
                  endDate,
                ),

                // 2. ASSETS SECTION
                pw.Center(
                  child: pw.Text(
                    "Assets",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),

                if (data.totalAssets == 0)
                  pw.Text(
                    "No asset transactions recorded.",
                    style: const pw.TextStyle(color: PdfColors.grey),
                  )
                else ...[
                  if (data.currentAssets.isNotEmpty) ...[
                    pw.Text(
                      "Current Assets",
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    ..._buildBalanceSheetRows(data.currentAssets),
                    _buildBalanceSheetRow(
                      label: "Total Current Assets",
                      amount: _formatAccounting(data.totalCurrentAssets),
                      isTotal: true,
                    ),
                  ],
                  pw.SizedBox(height: 16),
                  if (data.nonCurrentAssets.isNotEmpty) ...[
                    pw.Text(
                      "Long-term Assets",
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    ..._buildBalanceSheetRows(data.nonCurrentAssets),
                    _buildBalanceSheetRow(
                      label: "Total Long-term Assets",
                      amount: _formatAccounting(data.totalNonCurrentAssets),
                      isTotal: true,
                    ),
                  ],
                  pw.SizedBox(height: 20),
                  _buildBalanceSheetRow(
                    label: "Total Assets:",
                    amount: _formatAccounting(data.totalAssets),
                    isGrandTotal: true,
                  ),
                ],

                pw.SizedBox(height: 40),

                // 3. LIABILITIES & EQUITY SECTION
                pw.Center(
                  child: pw.Text(
                    "Liabilities",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                pw.SizedBox(height: 16),

                if (data.totalLiabilitiesAndEquity == 0)
                  pw.Text(
                    "No liability or equity entries found.",
                    style: const pw.TextStyle(color: PdfColors.grey),
                  )
                else ...[
                  if (data.currentLiabilities.isNotEmpty) ...[
                    pw.Text(
                      "Current Liabilities",
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    ..._buildBalanceSheetRows(data.currentLiabilities),
                    _buildBalanceSheetRow(
                      label: "Total Current Liabilities",
                      amount: _formatAccounting(data.totalCurrentLiabilities),
                      isTotal: true,
                    ),
                  ],
                  pw.SizedBox(height: 16),
                  if (data.nonCurrentLiabilities.isNotEmpty) ...[
                    pw.Text(
                      "Long-term Liabilities",
                      style: const pw.TextStyle(fontSize: 14),
                    ),
                    ..._buildBalanceSheetRows(data.nonCurrentLiabilities),
                    _buildBalanceSheetRow(
                      label: "Total Long-term Liabilities",
                      amount: _formatAccounting(
                        data.totalNonCurrentLiabilities,
                      ),
                      isTotal: true,
                    ),
                  ],
                  if (data.totalLiabilities > 0) ...[
                    pw.SizedBox(height: 10),
                    _buildBalanceSheetRow(
                      label: "Total Liabilities",
                      amount: _formatAccounting(data.totalLiabilities),
                      isTotal: true,
                    ),
                  ],

                  pw.SizedBox(height: 24),

                  if (data.totalOwnerEquity != 0 || data.netIncome != 0) ...[
                    pw.Center(
                      child: pw.Text(
                        "Owner's Equity",
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 16),

                    ...() {
                      final rows = <pw.Widget>[];
                      for (int i = 0; i < data.equityItems.length; i++) {
                        bool isLast =
                            (i == data.equityItems.length - 1) &&
                            (data.netIncome == 0);
                        rows.add(
                          _buildBalanceSheetRow(
                            label: data.equityItems[i].name,
                            amount: _formatAccounting(
                              data.equityItems[i].amount,
                            ),
                            indent: 24,
                            isLastInGroup: isLast,
                          ),
                        );
                      }
                      if (data.netIncome != 0) {
                        rows.add(
                          _buildBalanceSheetRow(
                            label: "Retained Earnings (Net Income)",
                            amount: _formatAccounting(data.netIncome),
                            indent: 24,
                            isLastInGroup: true,
                          ),
                        );
                      }
                      return rows;
                    }(),

                    _buildBalanceSheetRow(
                      label: "Total Owner's Equity",
                      amount: _formatAccounting(data.totalOwnerEquity),
                      isTotal: true,
                    ),
                  ],

                  pw.SizedBox(height: 20),

                  _buildBalanceSheetRow(
                    label: "Total Liabilities and Owner's Equity",
                    amount: _formatAccounting(data.totalLiabilitiesAndEquity),
                    isGrandTotal: true,
                  ),
                ],
              ];
            },
          ),
        );
        return pdf.save();
      },
    );
  }

  // ==========================================
  // --- SHARED REPORT HEADER ---------------
  // ==========================================
  static pw.Widget _buildReportHeader(
    String biz,
    String title,
    DateTime start,
    DateTime end,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          biz,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#001F3F'),
          ),
        ),
        pw.SizedBox(height: 6),
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: PdfColor.fromHex('#6C757D'),
            letterSpacing: 1.2,
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          "For the Period: ${dateFormat.format(start)} - ${dateFormat.format(end)}",
          style: pw.TextStyle(fontSize: 13, color: PdfColor.fromHex('#6C757D')),
        ),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColor.fromHex('#E0E0E0')),
        pw.SizedBox(height: 20),
      ],
    );
  }

  // ==========================================
  // --- HELPER: INCOME STATEMENT ROWS ------
  // ==========================================
  static pw.Widget _buildIncomeStatementRow({
    required String label,
    String? innerAmount,
    String? outerAmount,
    bool isBold = false,
    bool hasInnerBottomBorder = false,
    bool hasOuterBottomBorder = false,
    bool hasDoubleUnderline = false,
    double indent = 0,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.only(left: indent, right: 12),
              child: pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ),
          ),
          // INNER NUMBER COLUMN
          pw.Container(
            width: 70,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  innerAmount ?? "",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: isBold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
                if (hasInnerBottomBorder)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 2),
                    height: 1,
                    color: PdfColors.black,
                  ),
              ],
            ),
          ),
          pw.SizedBox(width: 16),
          // OUTER NUMBER COLUMN
          pw.Container(
            width: 80,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (hasDoubleUnderline) // Top line of double underline
                  pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 2),
                    height: 1,
                    color: PdfColors.black,
                  ),

                pw.Text(
                  outerAmount ?? "",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: isBold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),

                if (hasOuterBottomBorder)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 2),
                    height: 1,
                    color: PdfColors.black,
                  ),
                if (hasDoubleUnderline) // Bottom line of double underline
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 2),
                    height: 1,
                    color: PdfColors.black,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- HELPER: BALANCE SHEET ROWS ---------
  // ==========================================
  static List<pw.Widget> _buildBalanceSheetRows(List<dynamic> items) {
    if (items.isEmpty) return [];
    List<pw.Widget> rows = [];
    for (int i = 0; i < items.length; i++) {
      bool isLast = i == items.length - 1;
      rows.add(
        _buildBalanceSheetRow(
          label: items[i].name,
          amount: _formatAccounting(items[i].amount),
          indent: 24,
          isLastInGroup: isLast,
        ),
      );
    }
    return rows;
  }

  static pw.Widget _buildBalanceSheetRow({
    required String label,
    required String amount,
    bool isTotal = false,
    bool isGrandTotal = false,
    bool isLastInGroup = false,
    double indent = 0,
  }) {
    pw.FontWeight weight = pw.FontWeight.normal;
    double fontSize = 12;

    if (isGrandTotal) {
      weight = pw.FontWeight.bold;
      fontSize = 13;
    } else if (isTotal) {
      weight = pw.FontWeight.normal;
    }

    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Expanded(
            child: pw.Padding(
              padding: pw.EdgeInsets.only(left: indent, right: 12),
              child: pw.Text(
                label,
                style: pw.TextStyle(fontSize: fontSize, fontWeight: weight),
              ),
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(vertical: 2),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                bottom: isLastInGroup
                    ? const pw.BorderSide(width: 1)
                    : pw.BorderSide.none,
                top: isGrandTotal
                    ? const pw.BorderSide(width: 1)
                    : pw.BorderSide.none,
              ),
            ),
            child: pw.Text(
              amount,
              style: pw.TextStyle(fontSize: fontSize, fontWeight: weight),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:bookkeeping/features/incomestatement/income_statement.dart';
import 'package:bookkeeping/features/balancesheet/balance_sheet.dart';

class PdfExportService {
  static final currencyFormat = NumberFormat.currency(
    locale: 'en_PH',
    symbol: 'P',
  );
  static final dateFormat = DateFormat('MMMM dd, yyyy');

  // --- INCOME STATEMENT EXPORT ---
  static Future<void> exportIncomeStatement(IncomeStatement data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(
                data.businessName,
                "INCOME STATEMENT",
                "For the Period: ${dateFormat.format(data.periodStart)} - ${dateFormat.format(data.periodEnd)}",
              ),

              _buildSectionHeader("REVENUE"),
              ...data.revenues.map(
                (item) => _buildLineItem(
                  item.name,
                  currencyFormat.format(item.amount),
                ),
              ),
              pw.Divider(),
              _buildLineItem(
                "Total Revenue",
                currencyFormat.format(data.totalRevenue),
                isBold: true,
              ),
              _buildLineItem(
                "Less Cost of Sales",
                currencyFormat.format(data.totalCostOfSales),
              ),
              _buildLineItem(
                "Gross Profit",
                currencyFormat.format(data.grossProfit),
                isBold: true,
                hasDoubleUnderline: true,
              ),

              pw.SizedBox(height: 20),
              _buildSectionHeader("EXPENSES"),
              if (data.costOfSales.isNotEmpty) ...[
                pw.Text(
                  "Cost of Sales",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                ...data.costOfSales.map(
                  (item) => _buildLineItem(
                    item.name,
                    currencyFormat.format(item.amount),
                    indent: 10,
                  ),
                ),
              ],
              if (data.operatingExpenses.isNotEmpty) ...[
                pw.Text(
                  "Operating Expenses",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                ...data.operatingExpenses.map(
                  (item) => _buildLineItem(
                    item.name,
                    currencyFormat.format(item.amount),
                    indent: 10,
                  ),
                ),
              ],
              pw.Divider(),
              _buildLineItem(
                data.netIncomeLabel,
                currencyFormat.format(data.netIncome),
                isBold: true,
                hasDoubleUnderline: true,
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // --- BALANCE SHEET EXPORT ---
  static Future<void> exportBalanceSheet(BalanceSheet data) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            children: [
              _buildHeader(
                data.businessName,
                "BALANCE SHEET",
                "As of: ${dateFormat.format(data.date)}",
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Left Side: Assets
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("ASSETS"),
                        pw.Text(
                          "Current Assets",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        ...data.currentAssets.map(
                          (e) => _buildLineItem(
                            e.name,
                            currencyFormat.format(e.amount),
                            indent: 10,
                          ),
                        ),
                        _buildLineItem(
                          "Total Current Assets",
                          currencyFormat.format(data.totalCurrentAssets),
                          isBold: true,
                        ),
                        pw.SizedBox(height: 10),
                        pw.Text(
                          "Non-Current Assets",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        ...data.nonCurrentAssets.map(
                          (e) => _buildLineItem(
                            e.name,
                            currencyFormat.format(e.amount),
                            indent: 10,
                          ),
                        ),
                        pw.Divider(),
                        _buildLineItem(
                          "TOTAL ASSETS",
                          currencyFormat.format(data.totalAssets),
                          isBold: true,
                          hasDoubleUnderline: true,
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  // Right Side: Liabilities & Equity
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader("LIABILITIES & EQUITY"),
                        pw.Text(
                          "Liabilities",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        ...data.currentLiabilities.map(
                          (e) => _buildLineItem(
                            e.name,
                            currencyFormat.format(e.amount),
                            indent: 10,
                          ),
                        ),
                        _buildLineItem(
                          "Total Liabilities",
                          currencyFormat.format(data.totalLiabilities),
                          isBold: true,
                        ),
                        pw.SizedBox(height: 15),
                        pw.Text(
                          "Owner's Equity",
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        ...data.equityItems.map(
                          (e) => _buildLineItem(
                            e.name,
                            currencyFormat.format(e.amount),
                            indent: 10,
                          ),
                        ),
                        _buildLineItem(
                          "Net Income",
                          currencyFormat.format(data.netIncome),
                          indent: 10,
                        ),
                        pw.Divider(),
                        _buildLineItem(
                          "TOTAL LIABILITIES & EQUITY",
                          currencyFormat.format(data.totalLiabilitiesAndEquity),
                          isBold: true,
                          hasDoubleUnderline: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  // --- SHARED PDF HELPERS ---
  static pw.Widget _buildHeader(String biz, String title, String period) {
    return pw.Center(
      child: pw.Column(
        children: [
          pw.Text(
            biz.toUpperCase(),
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(title, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(period, style: const pw.TextStyle(fontSize: 10)),
          pw.Divider(),
        ],
      ),
    );
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _buildLineItem(
    String label,
    String amount, {
    bool isBold = false,
    double indent = 0,
    bool hasDoubleUnderline = false,
  }) {
    return pw.Column(
      children: [
        pw.Padding(
          padding: pw.EdgeInsets.only(left: indent, top: 2, bottom: 2),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  label,
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: isBold
                        ? pw.FontWeight.bold
                        : pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.Text(
                amount,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: isBold
                      ? pw.FontWeight.bold
                      : pw.FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        if (hasDoubleUnderline)
          pw.Container(
            margin: const pw.EdgeInsets.only(top: 1),
            height: 2,
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(width: 1, style: pw.BorderStyle.solid),
              ),
            ),
          ),
      ],
    );
  }
}
